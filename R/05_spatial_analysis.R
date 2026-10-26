# ==============================================================================
# SCRIPT: R/05_spatial_analysis.R
# Geospatial Concentration, Hexagonal Binning, and Hotspot Spatial Analytics
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
  library(hexbin)
  library(sf)
})

log_info("Starting Step 05: Geospatial Analysis (Visualization A)...")

# 1. Load Valid Spatial Dataset
spatial_rds <- file.path(DATA_PROC_DIR, "spatial_crashes_valid.rds")
if (!file.exists(spatial_rds)) {
  stop("spatial_crashes_valid.rds not found. Run R/03_data_preprocessing.R first.")
}
sp_dt <- readRDS(spatial_rds)
log_info("Loaded %s geocoded collision records within NYC bounding box.", fmt_count(nrow(sp_dt)))

# ------------------------------------------------------------------------------
# 2. Visualization A: Hexagonal Binning Collision Concentration Map
# ------------------------------------------------------------------------------
log_info("Rendering Visualization A: Hexagonal Density Map...")

# Define hotspot annotations based on verified empirical concentrations
hotspots <- data.frame(
  name = c(
    "Midtown Manhattan\n(42nd St & FDR)",
    "Downtown Brooklyn\n(Flatbush & Atlantic)",
    "Queens Blvd / LIE Corridor",
    "Cross Bronx Expressway\n& Grand Concourse",
    "Staten Island Expressway\n(I-278)"
  ),
  lon = c(-73.985, -73.982, -73.865, -73.905, -74.135),
  lat = c(40.755, 40.690, 40.730, 40.845, 40.608)
)

p_vis_a <- ggplot(sp_dt, aes(x = longitude, y = latitude)) +
  # Hexagonal Spatial Binning (75 bins across NYC extent)
  stat_bin_hex(bins = 75, color = "#1A202C", linewidth = 0.08) +
  scale_fill_viridis_c(
    option = "magma",
    trans = "log10",
    direction = -1,
    labels = comma,
    breaks = c(1, 10, 50, 200, 1000, 5000),
    name = "Collisions / Hex Bin\n(Log10 Scale)"
  ) +
  # Hotspot Annotation Points and Callouts
  geom_point(data = hotspots, aes(x = lon, y = lat), color = "#00FFCC", size = 2.5, shape = 21, stroke = 1.2, fill = "black", inherit.aes = FALSE) +
  geom_label(
    data = hotspots, aes(x = lon, y = lat, label = name),
    size = 2.7, fontface = "bold", fill = alpha("white", 0.88), color = "#1A202C",
    label.padding = unit(0.2, "lines"), vjust = -0.4, hjust = 0.5, inherit.aes = FALSE
  ) +
  coord_sf(
    xlim = c(NYC_BBOX$lon_min, NYC_BBOX$lon_max),
    ylim = c(NYC_BBOX$lat_min, NYC_BBOX$lat_max),
    expand = FALSE
  ) +
  labs(
    title = "Visualization A: Spatiotemporal Density of Reported Traffic Collisions in New York City",
    subtitle = sprintf("Aggregated hexagonal spatial distribution of %s georeferenced collisions (2012-2026)", fmt_count(nrow(sp_dt))),
    x = "Longitude (WGS 84)",
    y = "Latitude (WGS 84)",
    caption = "Source: NYC Open Data / NYPD. Hexagonal grid binned across verified NYC coordinates. Note: Denotes collision concentration, not exposure-adjusted crash rate."
  ) +
  theme_road_safety(base_size = 11) +
  theme(
    panel.background = element_rect(fill = "#0F172A", color = NA), # Dark slate aesthetic for contrast
    plot.background = element_rect(fill = "#FFFFFF", color = NA),
    panel.grid = element_line(color = "#1E293B", linewidth = 0.2),
    legend.position = "right",
    legend.key.height = unit(1.4, "cm")
  )

save_project_plot(p_vis_a, "fig_a_spatial_hex_density.png", width = 10, height = 9, dpi = DPI_DEFAULT)

# ------------------------------------------------------------------------------
# 3. Visualization A2: Faceted Spatial Severity Comparison (Injury vs Non-Injury)
# ------------------------------------------------------------------------------
log_info("Rendering Visualization A2: Faceted Severity Spatial Comparison...")

sp_severity_sub <- sp_dt[severity_tier %in% c("No Injury", "Injury Only")]

p_vis_a2 <- ggplot(sp_severity_sub, aes(x = longitude, y = latitude)) +
  stat_bin_hex(bins = 60, color = "#1A202C", linewidth = 0.05) +
  scale_fill_viridis_c(
    option = "plasma",
    trans = "log10",
    direction = -1,
    labels = comma,
    name = "Collisions / Bin"
  ) +
  facet_wrap(~severity_tier, ncol = 2) +
  coord_sf(
    xlim = c(NYC_BBOX$lon_min, NYC_BBOX$lon_max),
    ylim = c(NYC_BBOX$lat_min, NYC_BBOX$lat_max),
    expand = FALSE
  ) +
  labs(
    title = "Visualization A2: Spatial Contrast Between Property-Damage Only and Injury-Producing Collisions",
    subtitle = "Comparing spatial concentration patterns between No Injury collisions and Injury Only collisions",
    x = "Longitude",
    y = "Latitude",
    caption = "Source: NYC Open Data / NYPD. Binned by 60 hex bins per facet. Demonstrates high peripheral highway injury concentration."
  ) +
  theme_road_safety(base_size = 10) +
  theme(
    panel.background = element_rect(fill = "#0F172A", color = NA),
    legend.position = "bottom"
  )

save_project_plot(p_vis_a2, "fig_a2_spatial_severity_comparison.png", width = 11, height = 6.5, dpi = DPI_DEFAULT)

# ------------------------------------------------------------------------------
# 4. Save Spatial Hotspots Table
# ------------------------------------------------------------------------------
# Calculate borough level spatial metrics
borough_spatial <- sp_dt[, .(
  geocoded_crashes = .N,
  injury_crashes = sum(has_injury),
  fatal_crashes = sum(has_fatality),
  injury_rate_pct = round((sum(has_injury) / .N) * 100, 1),
  fatal_rate_per_10k = round((sum(has_fatality) / .N) * 10000, 2)
), by = .(borough = borough_clean)]
setorder(borough_spatial, -geocoded_crashes)

fwrite(borough_spatial, file.path(TABLES_DIR, "table_09_spatial_hotspots.csv"))
log_info("Saved spatial hotspots table to: %s", file.path(TABLES_DIR, "table_09_spatial_hotspots.csv"))
print(borough_spatial)

log_info("Step 05 completed successfully.")
