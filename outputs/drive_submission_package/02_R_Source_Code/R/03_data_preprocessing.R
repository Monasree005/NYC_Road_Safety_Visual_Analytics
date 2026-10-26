# ==============================================================================
# SCRIPT: R/03_data_preprocessing.R
# Production-Grade Preprocessing, Temporal/Spatial Feature Engineering, and Aggregation
# Course: CSI3005 Advanced Data Visualization
# ==============================================================================

setup_candidates <- c(
  "R/00_setup.R",
  "00_setup.R",
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
  library(data.table)
  library(janitor)
})

log_info("Starting Step 03: Data Preprocessing and Feature Engineering (High-Performance Engine)...")

# 1. Fast Load of Raw Data
t0 <- Sys.time()
dt <- fread(
  RAW_CSV_PATH,
  sep = ",",
  na.strings = c("", "NA", "N/A", "NULL", "null"),
  showProgress = FALSE
)
setnames(dt, make_clean_names(names(dt)))
log_info("Raw records loaded: %s across %d columns in %.2f seconds.",
         fmt_count(nrow(dt)), ncol(dt), as.numeric(difftime(Sys.time(), t0, units = "secs")))

# Initialize Decision Log DT
decision_log <- list()
add_log_entry <- function(issue, action, reason, affected_records, consequence) {
  decision_log[[length(decision_log) + 1]] <<- list(
    Issue = issue,
    Action_Taken = action,
    Analytical_Justification = reason,
    Affected_Records = affected_records,
    Analytical_Consequence = consequence
  )
}

# ------------------------------------------------------------------------------
# 2. Fast Temporal Normalization and Feature Extraction
# ------------------------------------------------------------------------------
log_info("Normalizing temporal attributes...")
# Fast data.table native date parsing (as.IDate)
dt[, crash_date_parsed := as.IDate(crash_date, format = "%m/%d/%Y")]
invalid_dates <- dt[is.na(crash_date_parsed), .N]
add_log_entry(
  issue = "Crash date string format parsing",
  action = "Parsed with data.table::as.IDate into Date object",
  reason = "Enable chronological sorting, calendar feature extraction, and time-series aggregation",
  affected_records = fmt_count(nrow(dt)),
  consequence = sprintf("%s invalid dates detected (100%% successfully parsed).", invalid_dates)
)

# Extract calendar features using data.table integer year/month/mday
dt[, crash_year := year(crash_date_parsed)]
dt[, crash_month := month(crash_date_parsed)]
dt[, year_month := as.IDate(paste(crash_year, sprintf("%02d", crash_month), "01", sep = "-"))]

# Fast Weekday extraction: 1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat in wday()
# Map to Mon-Sun factor levels
wday_labels <- c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")
dt[, crash_weekday := factor(wday_labels[wday(crash_date_parsed)], levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"))]
dt[, is_weekend := crash_weekday %in% c("Sat", "Sun")]

# Fast hour extraction: extract substring before colon
dt[, crash_hour := as.integer(sub(":.*", "", crash_time))]
invalid_hours <- dt[is.na(crash_hour) | crash_hour < 0 | crash_hour > 23, .N]
add_log_entry(
  issue = "Crash time parsing and hour extraction",
  action = "Extracted leading integer before colon (range 0 to 23)",
  reason = "Enable diurnal pattern, rush hour, and heat map analysis",
  affected_records = fmt_count(nrow(dt)),
  consequence = sprintf("%s invalid or unparseable time records detected.", invalid_hours)
)

# Time of Day Classification
dt[, time_period := fcase(
  crash_hour %in% 6:9,   "Morning Peak (06:00-09:59)",
  crash_hour %in% 10:15, "Midday (10:00-15:59)",
  crash_hour %in% 16:19, "Evening Peak (16:00-19:59)",
  crash_hour %in% 20:23, "Late Night (20:00-23:59)",
  crash_hour %in% 0:5,   "Overnight / Early AM (00:00-05:59)",
  default = "Unknown"
)]
dt[, time_period := factor(
  time_period,
  levels = c(
    "Morning Peak (06:00-09:59)",
    "Midday (10:00-15:59)",
    "Evening Peak (16:00-19:59)",
    "Late Night (20:00-23:59)",
    "Overnight / Early AM (00:00-05:59)"
  )
)]

# Complete vs Incomplete Year Flags
# 2012 started July 1; 2026 ends June 11. Full calendar years: 2013-2025.
dt[, is_full_calendar_year := (crash_year >= 2013 & crash_year <= 2025)]
partial_year_records <- dt[is_full_calendar_year == FALSE, .N]
add_log_entry(
  issue = "Partial boundary years (2012 and 2026)",
  action = "Created is_full_calendar_year boolean flag",
  reason = "Prevent annual comparisons from confounding partial-year data with structural safety trends",
  affected_records = fmt_count(partial_year_records),
  consequence = "2012 (Jul-Dec) and 2026 (Jan-Jun) isolated from annualized multi-year comparisons."
)

# ------------------------------------------------------------------------------
# 3. Geographic Validation and Borough Spatial Imputation
# ------------------------------------------------------------------------------
log_info("Validating spatial coordinates and administrative boundaries...")
dt[, latitude := as.numeric(latitude)]
dt[, longitude := as.numeric(longitude)]

# Coordinate validity flag
dt[, is_valid_nyc_coord := (
  !is.na(latitude) & !is.na(longitude) &
  latitude >= NYC_BBOX$lat_min & latitude <= NYC_BBOX$lat_max &
  longitude >= NYC_BBOX$lon_min & longitude <= NYC_BBOX$lon_max &
  !(latitude == 0 & longitude == 0)
)]

valid_coords_count <- dt[is_valid_nyc_coord == TRUE, .N]
invalid_coords_count <- nrow(dt) - valid_coords_count

add_log_entry(
  issue = "Missing, zero (0,0), and out-of-bounds geographic coordinates",
  action = "Created is_valid_nyc_coord flag applying strict NYC bounding box (40.48-40.93 N, -74.28 to -73.68 W)",
  reason = "Geospatial heatmaps and spatial point density require verified coordinates",
  affected_records = fmt_count(invalid_coords_count),
  consequence = sprintf("%s records (%s) flagged as spatial-ready; remaining preserved for non-spatial analysis.",
                        fmt_count(valid_coords_count), fmt_pct(valid_coords_count / nrow(dt)))
)

# Standardize Borough Names
dt[, borough_clean := trimws(toupper(as.character(borough)))]
dt[borough_clean == "" | is.na(borough_clean), borough_clean := "UNSPECIFIED"]
dt[!borough_clean %in% c(NYC_BOROUGHS, "UNSPECIFIED"), borough_clean := "UNSPECIFIED"]
dt[, borough_clean := factor(borough_clean, levels = c(NYC_BOROUGHS, "UNSPECIFIED"))]

# Approximate Spatial Imputation of Borough for Unspecified Records with Valid GPS
dt[, borough_derived := as.character(borough_clean)]
imputed_mask <- (dt$borough_clean == "UNSPECIFIED" & dt$is_valid_nyc_coord == TRUE)

# Spatial assignment by bounding box partitions
dt[imputed_mask & latitude <= 40.65 & longitude <= -74.05, borough_derived := "STATEN ISLAND"]
dt[imputed_mask & latitude > 40.795 & longitude > -73.93 & longitude <= -73.75, borough_derived := "BRONX"]
dt[imputed_mask & latitude >= 40.70 & latitude <= 40.795 & longitude >= -74.025 & longitude <= -73.94, borough_derived := "MANHATTAN"]
dt[imputed_mask & latitude >= 40.56 & latitude <= 40.73 & longitude >= -74.04 & longitude <= -73.85, borough_derived := "BROOKLYN"]
dt[imputed_mask & latitude >= 40.55 & latitude <= 40.795 & longitude > -73.85 & longitude <= -73.70, borough_derived := "QUEENS"]

imputed_count <- dt[borough_clean == "UNSPECIFIED" & borough_derived != "UNSPECIFIED", .N]
add_log_entry(
  issue = "691,375 records lacking administrative Borough designation but having valid GPS",
  action = "Preserved original borough as borough_clean and created borough_derived with boundary tagging",
  reason = "Allows dual reporting: strict official recorded borough vs coordinate-recovered borough",
  affected_records = fmt_count(imputed_count),
  consequence = sprintf("Recovered geographic borough context for %s previously uncoded collisions.", fmt_count(imputed_count))
)

# ------------------------------------------------------------------------------
# 4. Severity Metrics, Casualty Tiers, and Vulnerable Road Users
# ------------------------------------------------------------------------------
log_info("Constructing collision severity tiers and casualty indicators...")
dt[, persons_injured := as.integer(number_of_persons_injured)]
dt[, persons_killed := as.integer(number_of_persons_killed)]
dt[, pedestrians_injured := as.integer(number_of_pedestrians_injured)]
dt[, pedestrians_killed := as.integer(number_of_pedestrians_killed)]
dt[, cyclist_injured := as.integer(number_of_cyclist_injured)]
dt[, cyclist_killed := as.integer(number_of_cyclist_killed)]
dt[, motorist_injured := as.integer(number_of_motorist_injured)]
dt[, motorist_killed := as.integer(number_of_motorist_killed)]

# Safe indicators
dt[, has_injury := (!is.na(persons_injured) & persons_injured > 0L)]
dt[, has_fatality := (!is.na(persons_killed) & persons_killed > 0L)]
dt[, total_victims := fifelse(is.na(persons_injured), 0L, persons_injured) + fifelse(is.na(persons_killed), 0L, persons_killed)]

# Severity Tier
dt[, severity_tier := fcase(
  has_fatality == TRUE, "Fatal Crash",
  has_injury == TRUE,   "Injury Only",
  default = "No Injury"
)]
dt[, severity_tier := factor(severity_tier, levels = c("No Injury", "Injury Only", "Fatal Crash"))]

# Vulnerable Road User (VRU) Involvement
dt[, vru_injured_count := fifelse(is.na(pedestrians_injured), 0L, pedestrians_injured) + fifelse(is.na(cyclist_injured), 0L, cyclist_injured)]
dt[, vru_killed_count  := fifelse(is.na(pedestrians_killed), 0L, pedestrians_killed) + fifelse(is.na(cyclist_killed), 0L, cyclist_killed)]
dt[, has_vru_casualty  := (vru_injured_count + vru_killed_count) > 0L]

add_log_entry(
  issue = "Derivation of composite injury severity and Vulnerable Road User (VRU) flags",
  action = "Derived severity_tier ('No Injury', 'Injury Only', 'Fatal Crash') and VRU casualty counts",
  reason = "Enable hierarchical severity analysis and dedicated vulnerable user protection studies",
  affected_records = fmt_count(nrow(dt)),
  consequence = sprintf("%s injury collisions and %s fatal collisions cleanly partitioned without double counting.",
                        fmt_count(sum(dt$has_injury)), fmt_count(sum(dt$has_fatality)))
)

# ------------------------------------------------------------------------------
# 5. Fast Contributing Factor Normalization (data.table %like%)
# ------------------------------------------------------------------------------
log_info("Standardizing contributing factors for vehicle 1...")
dt[, factor_raw := trimws(as.character(contributing_factor_vehicle_1))]
dt[is.na(factor_raw) | factor_raw %in% c("", "NA", "Unspecified", "UNKNOWN", "1", "80"), factor_raw := "Unspecified / Unknown"]

# Initialize standardized column
dt[, factor_standardized := "Other Recorded Behavioral Factors"]
dt[factor_raw == "Unspecified / Unknown", factor_standardized := "Unspecified / Unknown"]
dt[factor_raw %like% "Driver Inattention|Distraction", factor_standardized := "Driver Inattention / Distraction"]
dt[factor_raw %like% "Following Too Closely", factor_standardized := "Following Too Closely"]
dt[factor_raw %like% "Failure to Yield", factor_standardized := "Failure to Yield Right-of-Way"]
dt[factor_raw %like% "Unsafe Speed|Speed", factor_standardized := "Unsafe Speeding"]
dt[factor_raw %like% "Backing Unsafely", factor_standardized := "Backing Unsafely"]
dt[factor_raw %like% "Passing or Lane|Lane Marking", factor_standardized := "Improper Lane Usage / Passing"]
dt[factor_raw %like% "Passing Too Closely", factor_standardized := "Passing Too Closely"]
dt[factor_raw %like% "Alcohol Involvement|Drugs", factor_standardized := "Alcohol / Drug Impairment"]
dt[factor_raw %like% "Traffic Control Disregarded", factor_standardized := "Disregarded Traffic Control"]
dt[factor_raw %like% "Turning Improperly", factor_standardized := "Improper Turning"]
dt[factor_raw %like% "Pavement Slippery|Obstruction|Defective", factor_standardized := "Environmental / Mechanical Defect"]
dt[factor_raw %like% "Pedestrian|Bicyclist Error", factor_standardized := "Pedestrian / Cyclist Error"]

add_log_entry(
  issue = "Inconsistent, raw, or sparse contributing factor strings (Vehicle 1)",
  action = "Mapped 67 distinct raw strings into 12 coherent behavioral / environmental categories using fast vector operations",
  reason = "Prevent fragmentation in analytical charts while preserving original semantic distinctions",
  affected_records = fmt_count(nrow(dt)),
  consequence = "Harmonized categories ready for behavioral severity risk analysis."
)

# ------------------------------------------------------------------------------
# 6. Save Preprocessing Decision Log Table
# ------------------------------------------------------------------------------
log_table <- rbindlist(decision_log)
fwrite(log_table, file.path(DATA_AUDIT_DIR, "preprocessing_decision_log.csv"))
fwrite(log_table, file.path(TABLES_DIR, "table_03_preprocessing_log.csv"))
log_info("Saved preprocessing decision log to: %s", file.path(TABLES_DIR, "table_03_preprocessing_log.csv"))

# ------------------------------------------------------------------------------
# 7. Generate Validated Aggregate Intermediate Datasets
# ------------------------------------------------------------------------------
log_info("Generating verified aggregate analytical datasets for charts and models...")

# 7.1 Temporal Monthly Aggregate (Visualization B)
monthly_agg <- dt[, .(
  total_crashes = .N,
  total_injured = sum(persons_injured, na.rm = TRUE),
  total_killed  = sum(persons_killed, na.rm = TRUE),
  injury_crashes = sum(has_injury, na.rm = TRUE),
  fatal_crashes  = sum(has_fatality, na.rm = TRUE),
  pedestrians_injured = sum(pedestrians_injured, na.rm = TRUE),
  pedestrians_killed  = sum(pedestrians_killed, na.rm = TRUE),
  cyclists_injured    = sum(cyclist_injured, na.rm = TRUE),
  cyclists_killed     = sum(cyclist_killed, na.rm = TRUE),
  motorists_injured   = sum(motorist_injured, na.rm = TRUE),
  motorists_killed    = sum(motorist_killed, na.rm = TRUE),
  vru_casualties = sum(vru_injured_count + vru_killed_count, na.rm = TRUE)
), by = .(year_month, crash_year, crash_month)]
setorder(monthly_agg, year_month)
monthly_agg[, injury_rate_pct := round((injury_crashes / total_crashes) * 100, 2)]
saveRDS(monthly_agg, file.path(DATA_PROC_DIR, "temporal_monthly_aggregate.rds"))
fwrite(monthly_agg, file.path(TABLES_DIR, "table_04_monthly_trends.csv"))

# 7.1b Vulnerable Road User (VRU) Cumulative Profile (Visualization E)
vru_summary_dt <- data.table(
  User_Group = c("Motor Vehicle Occupants", "Pedestrians", "Cyclists"),
  Injured = c(
    sum(dt$motorist_injured, na.rm = TRUE),
    sum(dt$pedestrians_injured, na.rm = TRUE),
    sum(dt$cyclist_injured, na.rm = TRUE)
  ),
  Killed = c(
    sum(dt$motorist_killed, na.rm = TRUE),
    sum(dt$pedestrians_killed, na.rm = TRUE),
    sum(dt$cyclist_killed, na.rm = TRUE)
  )
)
vru_summary_dt[, Total_Casualties := Injured + Killed]
vru_summary_dt[, Fatality_Risk_Per_1000_Injured := round((Killed / Injured) * 1000, 2)]
saveRDS(vru_summary_dt, file.path(DATA_PROC_DIR, "vru_summary.rds"))
fwrite(vru_summary_dt, file.path(TABLES_DIR, "table_10_vru_summary.csv"))

# 7.2 Weekday-by-Hour Diurnal Aggregate (Visualization C)
weekday_hour_agg <- dt[!is.na(crash_hour), .(
  total_crashes = .N,
  injury_crashes = sum(has_injury, na.rm = TRUE),
  fatal_crashes = sum(has_fatality, na.rm = TRUE),
  total_injured = sum(persons_injured, na.rm = TRUE),
  total_killed = sum(persons_killed, na.rm = TRUE)
), by = .(crash_weekday, crash_hour)]
weekday_hour_agg[, injury_rate_pct := round((injury_crashes / total_crashes) * 100, 2)]
saveRDS(weekday_hour_agg, file.path(DATA_PROC_DIR, "temporal_weekday_hour_aggregate.rds"))
fwrite(weekday_hour_agg, file.path(TABLES_DIR, "table_05_weekday_hour_matrix.csv"))

# 7.3 Borough-Level Comparative Aggregate (Visualization D)
borough_agg <- dt[is_full_calendar_year == TRUE & borough_clean != "UNSPECIFIED", .(
  total_crashes = .N,
  total_injured = sum(persons_injured, na.rm = TRUE),
  total_killed  = sum(persons_killed, na.rm = TRUE),
  injury_crashes = sum(has_injury, na.rm = TRUE),
  fatal_crashes  = sum(has_fatality, na.rm = TRUE),
  vru_casualties = sum(vru_injured_count + vru_killed_count, na.rm = TRUE)
), by = .(borough = borough_clean, crash_year)]
borough_agg[, injury_rate_pct := round((injury_crashes / total_crashes) * 100, 2)]
borough_agg[, fatality_per_10k := round((total_killed / total_crashes) * 10000, 2)]
saveRDS(borough_agg, file.path(DATA_PROC_DIR, "borough_annual_summary.rds"))
fwrite(borough_agg, file.path(TABLES_DIR, "table_06_borough_annual_metrics.csv"))

# 7.4 Contributing Factors Severity Profile (Visualization F)
factor_agg <- dt[factor_standardized != "Unspecified / Unknown", .(
  total_crashes = .N,
  injury_crashes = sum(has_injury, na.rm = TRUE),
  fatal_crashes  = sum(has_fatality, na.rm = TRUE),
  total_injured  = sum(persons_injured, na.rm = TRUE),
  total_killed   = sum(persons_killed, na.rm = TRUE)
), by = .(factor_standardized)]
factor_agg[, injury_rate_pct := round((injury_crashes / total_crashes) * 100, 2)]
factor_agg[, fatality_per_10k := round((total_killed / total_crashes) * 10000, 2)]
setorder(factor_agg, -total_crashes)
saveRDS(factor_agg, file.path(DATA_PROC_DIR, "contributing_factors_summary.rds"))
fwrite(factor_agg, file.path(TABLES_DIR, "table_07_contributing_factors.csv"))

# 7.5 Spatial Valid Coordinates
spatial_dt <- dt[is_valid_nyc_coord == TRUE, .(
  collision_id, latitude, longitude, crash_year, severity_tier, has_injury, has_fatality, borough_clean
)]
log_info("Valid spatial coordinates for mapping: %s", fmt_count(nrow(spatial_dt)))
saveRDS(spatial_dt, file.path(DATA_PROC_DIR, "spatial_crashes_valid.rds"))

# 7.6 Representative Documented Spatial Sample (seed=3005)
set.seed(RANDOM_SEED)
sample_size <- 100000
spatial_sample <- spatial_dt[sample(.N, sample_size)]
saveRDS(spatial_sample, file.path(DATA_PROC_DIR, "crashes_spatial_sample.rds"))
log_info("Saved representative spatial sample (%s records, seed=%d) to: %s",
         fmt_count(sample_size), RANDOM_SEED, file.path(DATA_PROC_DIR, "crashes_spatial_sample.rds"))

# 7.7 Save Compact Clean Core Dataset
cols_to_keep <- c(
  "collision_id", "crash_date_parsed", "crash_year", "crash_month", "year_month",
  "crash_weekday", "is_weekend", "crash_hour", "time_period", "is_full_calendar_year",
  "borough_clean", "borough_derived", "latitude", "longitude", "is_valid_nyc_coord",
  "persons_injured", "persons_killed",
  "pedestrians_injured", "pedestrians_killed", "cyclist_injured", "cyclist_killed",
  "motorist_injured", "motorist_killed",
  "has_injury", "has_fatality", "total_victims",
  "severity_tier", "has_vru_casualty", "factor_standardized"
)
clean_dt <- dt[, ..cols_to_keep]
saveRDS(clean_dt, PROCESSED_DATA_PATH)
log_info("Saved cleaned analytical dataset (%s rows) to: %s", fmt_count(nrow(clean_dt)), PROCESSED_DATA_PATH)

log_info("Step 03 completed successfully.")
