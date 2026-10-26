# ==============================================================================
# SCRIPT: R/01_import_and_profile.R
# Large-Scale Data Ingestion, Profiling, and Machine-Readable Provenance Audit
# Course: CSI3005 Advanced Data Visualization
# ==============================================================================

# Initialize setup and environment
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
  library(lubridate)
  library(janitor)
  library(jsonlite)
})

log_info("Starting Step 01: Ingestion and Profiling of raw dataset...")
log_info("Reading raw CSV from: %s", RAW_CSV_PATH)

start_time <- Sys.time()

# 1. Fast Tabular Read with data.table
raw_dt <- fread(
  file = RAW_CSV_PATH,
  sep = ",",
  header = TRUE,
  na.strings = c("", "NA", "N/A", "NULL", "null"),
  showProgress = TRUE
)

read_duration <- round(as.numeric(difftime(Sys.time(), start_time, units = "secs")), 2)
log_info("Read %s rows and %d columns in %s seconds.", fmt_count(nrow(raw_dt)), ncol(raw_dt), read_duration)

# 2. Schema and Column Names Inspection
raw_col_names <- names(raw_dt)
clean_cols <- make_clean_names(raw_col_names)
setnames(raw_dt, old = raw_col_names, new = clean_cols)

# 3. Missingness Audit Across All Columns
total_records <- nrow(raw_dt)
col_audit <- data.table(
  column_name = clean_cols,
  original_name = raw_col_names,
  data_type = sapply(raw_dt, typeof),
  missing_count = sapply(raw_dt, function(x) sum(is.na(x) | x == "")),
  unique_values = sapply(raw_dt, function(x) uniqueN(x))
)
col_audit[, missing_pct := round((missing_count / total_records) * 100, 3)]
col_audit[, completeness_pct := round(100 - missing_pct, 3)]

# Order by missingness descending
setorder(col_audit, -missing_count)

# Save missingness audit CSV
audit_csv_file <- file.path(DATA_AUDIT_DIR, "column_missingness_audit.csv")
fwrite(col_audit, audit_csv_file)
log_info("Saved column missingness audit to: %s", audit_csv_file)

# 4. Integrity and Key Metric Checks
# Collision ID Duplicate Check
id_col <- "collision_id"
total_ids <- raw_dt[[id_col]]
dup_ids_count <- sum(duplicated(total_ids))
unique_ids_count <- uniqueN(total_ids)

# Date Range Validation
log_info("Parsing crash dates...")
parsed_dates <- mdy(raw_dt$crash_date)
invalid_dates_count <- sum(is.na(parsed_dates))
min_date <- min(parsed_dates, na.rm = TRUE)
max_date <- max(parsed_dates, na.rm = TRUE)

# Geographic Coordinates Validation
lat_raw <- as.numeric(raw_dt$latitude)
lon_raw <- as.numeric(raw_dt$longitude)
coords_na_count <- sum(is.na(lat_raw) | is.na(lon_raw))
coords_zero_count <- sum(lat_raw == 0 & lon_raw == 0, na.rm = TRUE)

# Points inside NYC bounding box
nyc_valid_geo <- !is.na(lat_raw) & !is.na(lon_raw) &
  lat_raw >= NYC_BBOX$lat_min & lat_raw <= NYC_BBOX$lat_max &
  lon_raw >= NYC_BBOX$lon_min & lon_raw <= NYC_BBOX$lon_max
nyc_valid_geo_count <- sum(nyc_valid_geo)
nyc_invalid_geo_count <- sum(!is.na(lat_raw) & !is.na(lon_raw) & !nyc_valid_geo)

# Borough Counts and Missingness
borough_counts <- raw_dt[, .N, by = borough]
setorder(borough_counts, -N)
missing_borough_count <- sum(is.na(raw_dt$borough) | raw_dt$borough == "")

# Injury & Fatality Metrics
num_injured <- as.numeric(raw_dt$number_of_persons_injured)
num_killed  <- as.numeric(raw_dt$number_of_persons_killed)

total_injured_count <- sum(num_injured, na.rm = TRUE)
total_killed_count  <- sum(num_killed, na.rm = TRUE)
missing_injured_val <- sum(is.na(num_injured))
missing_killed_val  <- sum(is.na(num_killed))

crashes_with_injuries  <- sum(num_injured > 0, na.rm = TRUE)
crashes_with_fatalities <- sum(num_killed > 0, na.rm = TRUE)

# 5. Compile Machine-Readable Audit JSON
audit_summary <- list(
  metadata = list(
    dataset_title = "Motor Vehicle Collisions - Crashes",
    source_agency = "New York City Police Department (NYPD) / NYC Open Data",
    source_url = "https://data.cityofnewyork.us/Public-Safety/Motor-Vehicle-Collisions-Crashes/h9gi-nx95",
    provenance_type = "Official Municipal Open Data Portal",
    local_file_path = RAW_CSV_PATH,
    audit_timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"),
    r_version = R.version.string
  ),
  dimensions = list(
    total_records = total_records,
    total_columns = ncol(raw_dt),
    unique_collision_ids = unique_ids_count,
    duplicate_collision_ids = dup_ids_count
  ),
  temporal_coverage = list(
    earliest_date = as.character(min_date),
    latest_date = as.character(max_date),
    total_days_spanned = as.numeric(difftime(max_date, min_date, units = "days")),
    invalid_date_formats = invalid_dates_count
  ),
  geographic_quality = list(
    records_with_valid_nyc_coords = nyc_valid_geo_count,
    records_with_valid_nyc_coords_pct = round((nyc_valid_geo_count / total_records) * 100, 2),
    records_lacking_coordinates = coords_na_count,
    records_lacking_coordinates_pct = round((coords_na_count / total_records) * 100, 2),
    records_zero_coordinates = coords_zero_count,
    records_out_of_bounds = nyc_invalid_geo_count,
    records_missing_borough = missing_borough_count,
    records_missing_borough_pct = round((missing_borough_count / total_records) * 100, 2)
  ),
  severity_totals = list(
    total_persons_injured_reported = total_injured_count,
    total_persons_killed_reported = total_killed_count,
    crashes_with_injuries = crashes_with_injuries,
    crashes_with_injuries_pct = round((crashes_with_injuries / total_records) * 100, 2),
    crashes_with_fatalities = crashes_with_fatalities,
    crashes_with_fatalities_pct = round((crashes_with_fatalities / total_records) * 100, 3),
    missing_injured_field_count = missing_injured_val,
    missing_killed_field_count = missing_killed_val
  ),
  borough_distribution = as.list(setNames(borough_counts$N, ifelse(is.na(borough_counts$borough), "MISSING", borough_counts$borough)))
)

audit_json_file <- file.path(DATA_AUDIT_DIR, "dataset_audit_metrics.json")
write_json(audit_summary, audit_json_file, pretty = TRUE, auto_unbox = TRUE)
log_info("Saved machine-readable audit metrics to: %s", audit_json_file)

# Save human-readable summary table
summary_table <- data.table(
  Metric = c(
    "Total Ingested Records (Crashes)",
    "Total Schema Columns",
    "Temporal Span (Earliest - Latest)",
    "Duplicate Collision IDs",
    "Missing Geographic Coordinates",
    "Valid NYC Coordinate Records",
    "Missing Borough Attribute",
    "Total Persons Injured (Reported)",
    "Total Persons Killed (Reported)",
    "Collisions with >= 1 Injury",
    "Collisions with >= 1 Fatality",
    "Missing Injury Count Field",
    "Missing Fatality Count Field"
  ),
  Value = c(
    fmt_count(total_records),
    as.character(ncol(raw_dt)),
    sprintf("%s to %s", min_date, max_date),
    fmt_count(dup_ids_count),
    sprintf("%s (%s)", fmt_count(coords_na_count), fmt_pct(coords_na_count / total_records)),
    sprintf("%s (%s)", fmt_count(nyc_valid_geo_count), fmt_pct(nyc_valid_geo_count / total_records)),
    sprintf("%s (%s)", fmt_count(missing_borough_count), fmt_pct(missing_borough_count / total_records)),
    fmt_count(total_injured_count),
    fmt_count(total_killed_count),
    sprintf("%s (%s)", fmt_count(crashes_with_injuries), fmt_pct(crashes_with_injuries / total_records)),
    sprintf("%s (%s)", fmt_count(crashes_with_fatalities), fmt_pct(crashes_with_fatalities / total_records)),
    fmt_count(missing_injured_val),
    fmt_count(missing_killed_val)
  )
)

summary_table_file <- file.path(TABLES_DIR, "table_01_dataset_profile.csv")
fwrite(summary_table, summary_table_file)
log_info("Saved human-readable profile table to: %s", summary_table_file)

print(summary_table)

log_info("Step 01 completed successfully.")
