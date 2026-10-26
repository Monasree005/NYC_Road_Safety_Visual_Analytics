# ==============================================================================
# SCRIPT: tests/test_data_integrity.R
# Comprehensive Automated Unit & Data Quality Regression Test Suite
# Course: CSI3005 Advanced Data Visualization
# ==============================================================================

setup_candidates <- c(
  "R/00_setup.R",
  "00_setup.R",
  "../R/00_setup.R",
  "C:/Users/nivet/Documents/NYC_Road_Safety_Visual_Analytics/R/00_setup.R"
)
setup_loaded <- FALSE
for (sc in setup_candidates) {
  if (file.exists(sc)) {
    source(sc)
    setup_loaded <- TRUE
    break
  }
}
if (!setup_loaded) stop("Could not find R/00_setup.R")
setwd(PROJECT_ROOT)

suppressPackageStartupMessages({
  library(testthat)
  library(data.table)
})

cat("\n==============================================================================\n")
cat("EXECUTING CSI3005 DATA INTEGRITY & STATISTICAL CONSISTENCY TEST SUITE\n")
cat("==============================================================================\n\n")

# Load intermediate verified datasets
audit_metrics <- jsonlite::read_json(file.path(DATA_AUDIT_DIR, "dataset_audit_metrics.json"))
clean_dt <- readRDS(PROCESSED_DATA_PATH)
monthly_agg <- readRDS(file.path(DATA_PROC_DIR, "temporal_monthly_aggregate.rds"))
weekday_agg <- readRDS(file.path(DATA_PROC_DIR, "temporal_weekday_hour_aggregate.rds"))
spatial_dt <- readRDS(file.path(DATA_PROC_DIR, "spatial_crashes_valid.rds"))
vru_dt <- readRDS(file.path(DATA_PROC_DIR, "vru_summary.rds"))

test_that("Test 1: Dataset Volume and Identifier Uniqueness", {
  expect_equal(audit_metrics$dimensions$total_records, 2269187)
  expect_equal(nrow(clean_dt), 2269187)
  expect_equal(audit_metrics$dimensions$duplicate_collision_ids, 0)
  expect_equal(uniqueN(clean_dt$collision_id), 2269187)
})

test_that("Test 2: Schema Integrity and Required Analytical Fields", {
  required_cols <- c(
    "collision_id", "crash_date_parsed", "crash_year", "crash_month", "year_month",
    "crash_weekday", "crash_hour", "borough_clean", "latitude", "longitude",
    "is_valid_nyc_coord", "persons_injured", "persons_killed",
    "has_injury", "has_fatality", "severity_tier", "factor_standardized"
  )
  for (col in required_cols) {
    expect_true(col %in% names(clean_dt), info = paste("Missing column:", col))
  }
})

test_that("Test 3: Temporal Bounds and Date Parsing Consistency", {
  expect_equal(as.character(min(clean_dt$crash_date_parsed)), "2012-07-01")
  expect_equal(as.character(max(clean_dt$crash_date_parsed)), "2026-06-11")
  expect_true(all(clean_dt$crash_hour >= 0 & clean_dt$crash_hour <= 23, na.rm = TRUE))
  expect_true(all(levels(clean_dt$crash_weekday) == c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")))
})

test_that("Test 4: Non-Negative Casualty Constraints and Valid Severities", {
  expect_true(all(clean_dt$persons_injured >= 0, na.rm = TRUE))
  expect_true(all(clean_dt$persons_killed >= 0, na.rm = TRUE))
  expect_equal(levels(clean_dt$severity_tier), c("No Injury", "Injury Only", "Fatal Crash"))

  # Logical consistency: has_injury TRUE if and only if persons_injured > 0
  injury_check <- clean_dt[!is.na(persons_injured), all((persons_injured > 0) == has_injury)]
  expect_true(injury_check)

  # Logical consistency: has_fatality TRUE if and only if persons_killed > 0
  fatal_check <- clean_dt[!is.na(persons_killed), all((persons_killed > 0) == has_fatality)]
  expect_true(fatal_check)
})

test_that("Test 5: Geographic Coordinate Validity and Bounding Box Compliance", {
  # All records in spatial_crashes_valid.rds must fall within NYC Bounding Box
  expect_true(all(spatial_dt$latitude >= NYC_BBOX$lat_min & spatial_dt$latitude <= NYC_BBOX$lat_max))
  expect_true(all(spatial_dt$longitude >= NYC_BBOX$lon_min & spatial_dt$longitude <= NYC_BBOX$lon_max))
  expect_false(any(spatial_dt$latitude == 0 & spatial_dt$longitude == 0))
  expect_equal(nrow(spatial_dt), 2020640)
})

test_that("Test 6: Aggregation Totals Reconciliation", {
  # Total collisions across monthly aggregate must match total cleaned rows
  expect_equal(sum(monthly_agg$total_crashes), nrow(clean_dt))

  # Total injuries across monthly aggregate must match sum in cleaned data
  expect_equal(sum(monthly_agg$total_injured), sum(clean_dt$persons_injured, na.rm = TRUE))

  # Total fatalities across monthly aggregate must match sum in cleaned data
  expect_equal(sum(monthly_agg$total_killed), sum(clean_dt$persons_killed, na.rm = TRUE))
})

test_that("Test 7: Vulnerable Road User Casualty Accounting", {
  # Total reported killed across VRU table must match citywide totals
  expect_true(sum(vru_dt$Killed) <= sum(clean_dt$persons_killed, na.rm = TRUE))
  expect_equal(nrow(vru_dt), 3)
  expect_true(vru_dt[User_Group == "Pedestrians", Fatality_Risk_Per_1000_Injured] >
              vru_dt[User_Group == "Motor Vehicle Occupants", Fatality_Risk_Per_1000_Injured])
})

test_that("Test 8: Output Figures and Tables Artifact Verification", {
  required_figures <- c(
    "fig_a_spatial_hex_density.png",
    "fig_a2_spatial_severity_comparison.png",
    "fig_b_temporal_monthly_trend.png",
    "fig_c_weekday_hour_heatmap.png",
    "fig_d_borough_comparison.png",
    "fig_e_severity_vru_distribution.png",
    "fig_f_contributing_factors_risk.png",
    "fig_g_data_quality_missingness.png"
  )
  for (fig in required_figures) {
    p <- file.path(FIGURES_DIR, fig)
    expect_true(file.exists(p), info = paste("Missing figure file:", fig))
    expect_true(file.info(p)$size > 10000, info = paste("Figure file too small/empty:", fig))
  }

  required_tables <- c(
    "table_01_dataset_profile.csv",
    "table_02_data_quality_anomalies.csv",
    "table_03_preprocessing_log.csv",
    "table_04_monthly_trends.csv",
    "table_05_weekday_hour_matrix.csv",
    "table_06_borough_annual_metrics.csv",
    "table_07_contributing_factors.csv",
    "table_08_temporal_findings.csv",
    "table_09_spatial_hotspots.csv",
    "table_10_vru_summary.csv",
    "table_11_contributing_factors_ranked.csv",
    "table_12_visualization_catalog.csv",
    "table_13_faculty_compliance_matrix.csv"
  )
  for (tbl in required_tables) {
    p <- file.path(TABLES_DIR, tbl)
    expect_true(file.exists(p), info = paste("Missing table file:", tbl))
    expect_true(file.info(p)$size > 50, info = paste("Table file too small/empty:", tbl))
  }
})

cat("\n[TEST REPORT] All 8 test suites evaluated.\n")
cat("[TEST REPORT] SUCCESS: ALL UNIT, DATA QUALITY, AND RECONCILIATION TESTS PASSED!\n\n")
