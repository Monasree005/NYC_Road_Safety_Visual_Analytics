# ==============================================================================
# SCRIPT: R/07_visualizations.R
# Visualization Pipeline Coordinator & Visual Artifacts Catalog
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
})

log_info("Starting Step 07: Visual Analytics Verification and Catalog Generation...")

# Define Required Principal Visualizations and their design metadata
figure_catalog <- data.table(
  Figure_ID = c(
    "Visualization A",
    "Visualization A2",
    "Visualization B",
    "Visualization C",
    "Visualization D",
    "Visualization E",
    "Visualization F",
    "Visualization G"
  ),
  File_Name = c(
    "fig_a_spatial_hex_density.png",
    "fig_a2_spatial_severity_comparison.png",
    "fig_b_temporal_monthly_trend.png",
    "fig_c_weekday_hour_heatmap.png",
    "fig_d_borough_comparison.png",
    "fig_e_severity_vru_distribution.png",
    "fig_f_contributing_factors_risk.png",
    "fig_g_data_quality_missingness.png"
  ),
  Analytical_Question = c(
    "Q1: Where are reported collisions geographically concentrated?",
    "Q1 & Q6: How do spatial patterns diverge between property-damage and injury collisions?",
    "Q2: How do collision counts and reported injury outcomes vary across time?",
    "Q3: Which combinations of weekday and hour contain highest crash concentrations?",
    "Q4: How do collision volume and injury rates vary across boroughs over time?",
    "Q5 & Q6: How are injury and fatality burdens distributed across road user classes?",
    "Q6: Which recorded contributing factors are associated with disproportionate severity?",
    "Q7: How do missingness and coordinate gaps affect analytical uncertainty?"
  ),
  Visual_Encoding_Technique = c(
    "Hexagonal 2D Spatial Binning with Log10 Magma Palette & Geospatial Annotations",
    "Faceted Hexagonal Cartography (Property Damage vs Injury Collisions)",
    "Dual-Panel Longitudinal Time-Series Line Chart with Structural Policy Annotations",
    "7x24 Matrix Diurnal Heat Map with Magma Gradient and Empirical Peak Highlighting",
    "Dual-Faceted Ranked Horizontal Bar & Multi-Line Borough Trend Panel",
    "Divergent Grouped Bar & Vulnerability Ratio Metric Panel (Motorist vs VRU)",
    "Multivariate Bubble / Dumbbell Plot (Volume, Injury Rate, Fatality Intensity)",
    "Ranked Horizontal Stacked Bar Completeness Audit by Variable Domain"
  )
)

# Check existence and file sizes of all generated figures
figure_catalog[, Full_Path := file.path(FIGURES_DIR, File_Name)]
figure_catalog[, Exists := file.exists(Full_Path)]
figure_catalog[, File_Size_KB := fifelse(Exists, round(file.info(Full_Path)$size / 1024, 1), 0)]

# If any figure is missing, trigger the corresponding script
missing_figs <- figure_catalog[Exists == FALSE]
if (nrow(missing_figs) > 0) {
  log_warn("Detected %d missing figures. Triggering generation scripts...", nrow(missing_figs))
  if (any(missing_figs$Figure_ID == "Visualization G")) source("R/02_data_quality_audit.R")
  if (any(missing_figs$Figure_ID %in% c("Visualization B", "Visualization C"))) source("R/04_temporal_analysis.R")
  if (any(missing_figs$Figure_ID %in% c("Visualization A", "Visualization A2"))) source("R/05_spatial_analysis.R")
  if (any(missing_figs$Figure_ID %in% c("Visualization D", "Visualization E", "Visualization F"))) source("R/06_multivariate_analysis.R")

  # Re-check existence
  figure_catalog[, Exists := file.exists(Full_Path)]
  figure_catalog[, File_Size_KB := fifelse(Exists, round(file.info(Full_Path)$size / 1024, 1), 0)]
}

# Export catalog table
catalog_csv <- file.path(TABLES_DIR, "table_12_visualization_catalog.csv")
fwrite(figure_catalog[, .(Figure_ID, File_Name, Analytical_Question, Visual_Encoding_Technique, Exists, File_Size_KB)], catalog_csv)
log_info("Saved visual artifacts catalog to: %s", catalog_csv)

print(figure_catalog[, .(Figure_ID, File_Name, Exists, File_Size_KB)])

if (all(figure_catalog$Exists)) {
  log_info("All %d principal visualizations verified successfully on disk.", nrow(figure_catalog))
} else {
  stop("Some visualizations could not be verified!")
}

log_info("Step 07 completed successfully.")
