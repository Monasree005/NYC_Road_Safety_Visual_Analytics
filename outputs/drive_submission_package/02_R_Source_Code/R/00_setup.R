# ==============================================================================
# SCRIPT: R/00_setup.R
# Environment Verification and Package Initialization
# Course: CSI3005 Advanced Data Visualization
# ==============================================================================

# Locate project configuration
find_and_source_config <- function() {
  candidates <- c(
    "config/project_config.R",
    "../config/project_config.R",
    "../../config/project_config.R",
    "C:/Users/nivet/Documents/NYC_Road_Safety_Visual_Analytics/config/project_config.R"
  )
  for (c in candidates) {
    if (file.exists(c)) {
      source(c)
      return(invisible(TRUE))
    }
  }
  stop("Unable to locate config/project_config.R")
}

find_and_source_config()

# Required CRAN Packages
REQUIRED_PACKAGES <- c(
  "data.table",
  "ggplot2",
  "dplyr",
  "tidyr",
  "lubridate",
  "janitor",
  "scales",
  "viridis",
  "hexbin",
  "patchwork",
  "sf",
  "testthat",
  "knitr",
  "rmarkdown",
  "yaml",
  "jsonlite"
)

# Optional Dashboard Packages
DASHBOARD_PACKAGES <- c("shiny", "plotly")

# Load and verify packages
verify_and_load_packages <- function(pkgs) {
  missing_pkgs <- pkgs[!(pkgs %in% installed.packages()[, "Package"])]
  if (length(missing_pkgs) > 0) {
    stop(sprintf("Missing required packages: %s. Run install.packages() first.", paste(missing_pkgs, collapse = ", ")))
  }
  for (p in pkgs) {
    suppressPackageStartupMessages(library(p, character.only = TRUE))
  }
  cat(sprintf("[SETUP] All %d core packages loaded successfully.\n", length(pkgs)))
}

verify_and_load_packages(REQUIRED_PACKAGES)

# Source helpers
helpers_path <- file.path(PROJECT_ROOT, "R", "helpers.R")
if (file.exists(helpers_path)) {
  source(helpers_path)
} else {
  stop("R/helpers.R not found!")
}

# Ensure directory structure exists
ensure_project_dirs <- function() {
  dirs <- c(
    DATA_RAW_DIR,
    DATA_PROC_DIR,
    DATA_AUDIT_DIR,
    FIGURES_DIR,
    TABLES_DIR,
    OUT_REP_DIR,
    LOGS_DIR,
    TESTS_DIR,
    APP_DIR
  )
  for (d in dirs) {
    if (!dir.exists(d)) {
      dir.create(d, recursive = TRUE, showWarnings = FALSE)
    }
  }
  cat("[SETUP] Project directory tree validated.\n")
}

ensure_project_dirs()

cat(sprintf("[SETUP] Setup complete. Ready for analysis pipeline.\n"))
