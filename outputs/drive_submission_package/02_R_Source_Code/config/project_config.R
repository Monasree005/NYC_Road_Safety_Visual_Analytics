# ==============================================================================
# PROJECT CONFIGURATION: NYC Road Safety Visual Analytics
# Course: CSI3005 Advanced Data Visualization - University Assessment
# ==============================================================================

# Guard against re-definition conflicts
if (!exists(".PROJECT_CONFIG_LOADED")) {
  .PROJECT_CONFIG_LOADED <- TRUE

  # Project Root Detection
  # Supports execution from project root, R/ folder, or RStudio session
  find_project_root <- function() {
    candidate <- getwd()
    for (i in 1:4) {
      if (file.exists(file.path(candidate, "NYC_Road_Safety_Visual_Analytics.Rproj")) ||
          dir.exists(file.path(candidate, "config"))) {
        return(normalizePath(candidate, winslash = "/"))
      }
      candidate <- dirname(candidate)
    }
    # Fallback to default user document path
    default_path <- "C:/Users/nivet/Documents/NYC_Road_Safety_Visual_Analytics"
    if (dir.exists(default_path)) {
      return(normalizePath(default_path, winslash = "/"))
    }
    return(normalizePath(getwd(), winslash = "/"))
  }

  PROJECT_ROOT <- find_project_root()

  # Path Definitions
  CONFIG_DIR     <- file.path(PROJECT_ROOT, "config")
  DATA_RAW_DIR   <- file.path(PROJECT_ROOT, "data", "raw")
  DATA_PROC_DIR  <- file.path(PROJECT_ROOT, "data", "processed")
  DATA_AUDIT_DIR <- file.path(PROJECT_ROOT, "data", "audit")
  R_CODE_DIR     <- file.path(PROJECT_ROOT, "R")
  REPORTS_DIR    <- file.path(PROJECT_ROOT, "reports")
  OUTPUTS_DIR    <- file.path(PROJECT_ROOT, "outputs")
  FIGURES_DIR    <- file.path(PROJECT_ROOT, "outputs", "figures")
  TABLES_DIR     <- file.path(PROJECT_ROOT, "outputs", "tables")
  OUT_REP_DIR    <- file.path(PROJECT_ROOT, "outputs", "reports")
  LOGS_DIR       <- file.path(PROJECT_ROOT, "outputs", "logs")
  TESTS_DIR      <- file.path(PROJECT_ROOT, "tests")
  APP_DIR        <- file.path(PROJECT_ROOT, "app")

  # Primary Raw CSV Path
  RAW_CSV_PATH <- file.path(DATA_RAW_DIR, "export.csv")
  if (!file.exists(RAW_CSV_PATH)) {
    # Check alternate fallback location
    alt_path <- "C:/Users/nivet/Downloads/export.csv"
    if (file.exists(alt_path)) {
      RAW_CSV_PATH <- alt_path
    }
  }

  # Processed and Summary File Paths
  PROCESSED_DATA_PATH   <- file.path(DATA_PROC_DIR, "crashes_cleaned.rds")
  PROCESSED_SAMPLE_PATH <- file.path(DATA_PROC_DIR, "crashes_spatial_sample.rds")
  AUDIT_METRICS_PATH    <- file.path(DATA_AUDIT_DIR, "dataset_audit_metrics.json")
  AUDIT_SUMMARY_CSV     <- file.path(DATA_AUDIT_DIR, "column_missingness_audit.csv")

  # Spatial Extent Boundaries for NYC (WGS84 EPSG:4326)
  # Standard bounding box for NYC metropolitan region validation
  NYC_BBOX <- list(
    lat_min = 40.48,
    lat_max = 40.93,
    lon_min = -74.28,
    lon_max = -73.68
  )

  # Five NYC Boroughs
  NYC_BOROUGHS <- c("BRONX", "BROOKLYN", "MANHATTAN", "QUEENS", "STATEN ISLAND")

  # Analytical Parameters
  RANDOM_SEED <- 3005 # Aligned with course code CSI3005
  DPI_DEFAULT <- 300
  DPI_HIGH    <- 600

  # Color Palette Definitions (Perceptually Uniform & Colorblind Safe)
  PALETTES <- list(
    boroughs = c(
      "BRONX"         = "#3B528B", # Viridis deep blue
      "BROOKLYN"      = "#21908C", # Viridis teal
      "MANHATTAN"     = "#5DC863", # Viridis green
      "QUEENS"        = "#FDE725", # Viridis yellow
      "STATEN ISLAND" = "#E66101"  # Accent burnt orange
    ),
    severity = c(
      "No Injury"     = "#440154", # Dark purple
      "Injury Only"   = "#21908C", # Teal
      "Fatal Crash"   = "#D95F02"  # Highlight vermilion
    ),
    continuous = "viridis",
    heatmap    = "magma"
  )

  cat(sprintf("[CONFIG] Project root set to: %s\n", PROJECT_ROOT))
  cat(sprintf("[CONFIG] Raw CSV path: %s (Exists: %s)\n", RAW_CSV_PATH, file.exists(RAW_CSV_PATH)))
}
