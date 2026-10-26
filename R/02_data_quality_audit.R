# ==============================================================================
# SCRIPT: R/02_data_quality_audit.R
# Comprehensive Data Quality Audit, Integrity Checks, and Uncertainty Analysis
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
  library(ggplot2)
  library(scales)
  library(viridis)
})

log_info("Starting Step 02: Data Quality & Missingness Audit...")

# 1. Load Missingness Audit Data
audit_csv_file <- file.path(DATA_AUDIT_DIR, "column_missingness_audit.csv")
if (!file.exists(audit_csv_file)) {
  stop("Missingness audit CSV not found. Run R/01_import_and_profile.R first.")
}
audit_dt <- fread(audit_csv_file)

# Select key analytical variables for visualization (excluding sparse secondary vehicles 3-5)
key_vars <- c(
  "collision_id", "crash_date", "crash_time",
  "number_of_persons_injured", "number_of_persons_killed",
  "number_of_pedestrians_injured", "number_of_cyclist_injured", "number_of_motorist_injured",
  "vehicle_type_code_1", "contributing_factor_vehicle_1",
  "latitude", "longitude", "on_street_name",
  "borough", "zip_code", "cross_street_name", "off_street_name"
)

plot_dt <- audit_dt[column_name %in% key_vars]

# Reorder factor by missing_pct ascending for horizontal bar chart
plot_dt[, column_label := factor(column_name, levels = plot_dt[order(missing_pct)]$column_name)]

# Create category tags
plot_dt[, category := fifelse(
  column_name %in% c("latitude", "longitude", "borough", "zip_code", "on_street_name", "cross_street_name", "off_street_name"),
  "Spatial & Location Attributes",
  fifelse(
    column_name %in% c("crash_date", "crash_time", "collision_id"),
    "Identifiers & Temporal",
    "Collision Severity & Dynamics"
  )
)]

# 2. Visualization G — Data Quality and Missingness Profile
p_missing <- ggplot(plot_dt, aes(x = missing_pct, y = column_label, fill = category)) +
  geom_col(width = 0.7, color = "#2D3748", linewidth = 0.2) +
  geom_text(
    aes(label = sprintf("%.1f%% (%s)", missing_pct, fmt_count(missing_count))),
    hjust = fifelse(plot_dt$missing_pct > 25, 1.05, -0.08),
    color = fifelse(plot_dt$missing_pct > 25, "white", "#1A202C"),
    size = 3.1,
    fontface = "bold"
  ) +
  scale_x_continuous(
    limits = c(0, 100),
    breaks = seq(0, 100, by = 20),
    labels = function(x) paste0(x, "%"),
    expand = expansion(mult = c(0, 0.08))
  ) +
  scale_fill_manual(
    values = c(
      "Identifiers & Temporal" = "#21908C",
      "Collision Severity & Dynamics" = "#3B528B",
      "Spatial & Location Attributes" = "#E66101"
    )
  ) +
  labs(
    title = "Visualization G: Column-Level Missingness and Completeness Audit",
    subtitle = sprintf("Analysis of %s reported collisions in NYC Open Data (July 2012 - June 2026)", fmt_count(audit_dt$unique_values[audit_dt$column_name == "collision_id"])),
    x = "Missing Records Percentage (%)",
    y = "Analytical Attribute",
    fill = "Variable Domain:",
    caption = "Source: NYC Open Data / NYPD Motor Vehicle Collisions. Calculations by CSI3005 Project Team."
  ) +
  theme_road_safety(base_size = 11) +
  theme(
    legend.position = "top",
    panel.grid.major.y = element_blank()
  )

# Save Visualization G
save_project_plot(p_missing, "fig_g_data_quality_missingness.png", width = 10, height = 7, dpi = DPI_DEFAULT)

# 3. Anomaly Analysis Table
# Inspect coordinates distribution from raw file
raw_dt <- fread(RAW_CSV_PATH, select = c("COLLISION_ID", "CRASH DATE", "LATITUDE", "LONGITUDE", "NUMBER OF PERSONS INJURED", "NUMBER OF PERSONS KILLED", "BOROUGH"))
setnames(raw_dt, make_clean_names(names(raw_dt)))

anomalies_summary <- data.table(
  Audit_Category = c(
    "Coordinate Null or Empty",
    "Coordinate Exactly (0, 0) / Null Island",
    "Coordinates Outside NYC Bounding Box",
    "Missing Borough (Uncoded Administrative Area)",
    "Missing Latitude but Borough Present",
    "Valid Latitude but Missing Borough",
    "Collisions with Injured Count > 10 (Mass Casualty Events)",
    "Collisions with Fatalities >= 3",
    "Reported Injured Count < 0 (Invalid Negatives)",
    "Reported Killed Count < 0 (Invalid Negatives)"
  ),
  Record_Count = c(
    sum(is.na(raw_dt$latitude) | is.na(raw_dt$longitude)),
    sum(raw_dt$latitude == 0 & raw_dt$longitude == 0, na.rm = TRUE),
    sum(!is.na(raw_dt$latitude) & !is.na(raw_dt$longitude) & (raw_dt$latitude < NYC_BBOX$lat_min | raw_dt$latitude > NYC_BBOX$lat_max | raw_dt$longitude < NYC_BBOX$lon_min | raw_dt$longitude > NYC_BBOX$lon_max)),
    sum(is.na(raw_dt$borough) | raw_dt$borough == ""),
    sum((is.na(raw_dt$latitude) | is.na(raw_dt$longitude)) & (!is.na(raw_dt$borough) & raw_dt$borough != "")),
    sum((!is.na(raw_dt$latitude) & !is.na(raw_dt$longitude)) & (is.na(raw_dt$borough) | raw_dt$borough == "")),
    sum(raw_dt$number_of_persons_injured > 10, na.rm = TRUE),
    sum(raw_dt$number_of_persons_killed >= 3, na.rm = TRUE),
    sum(raw_dt$number_of_persons_injured < 0, na.rm = TRUE),
    sum(raw_dt$number_of_persons_killed < 0, na.rm = TRUE)
  )
)
anomalies_summary[, Percentage := fmt_pct(Record_Count / nrow(raw_dt))]

# Save anomalies table
anomalies_file <- file.path(TABLES_DIR, "table_02_data_quality_anomalies.csv")
fwrite(anomalies_summary, anomalies_file)
log_info("Saved data quality anomalies audit to: %s", anomalies_file)

print(anomalies_summary)

log_info("Step 02 completed successfully.")
