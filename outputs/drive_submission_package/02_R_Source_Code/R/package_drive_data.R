# ==============================================================================
# SCRIPT: Package All Data CSVs and Figures for Google Drive Upload
# ==============================================================================
setwd("C:/Users/nivet/Documents/NYC_Road_Safety_Visual_Analytics")

pkg_dir <- "outputs/drive_submission_package"
dir.create(pkg_dir, showWarnings = FALSE, recursive = TRUE)

csv_files <- c(
  list.files("outputs/tables", full.names = TRUE),
  list.files("data/audit", full.names = TRUE)
)
file.copy(csv_files, pkg_dir, overwrite = TRUE)

cat("Copied", length(csv_files), "data files to outputs/drive_submission_package/\n")
