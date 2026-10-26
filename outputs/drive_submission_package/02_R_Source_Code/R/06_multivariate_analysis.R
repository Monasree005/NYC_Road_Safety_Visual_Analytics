# ==============================================================================
# SCRIPT: R/06_multivariate_analysis.R
# Multivariate Visualization: Borough Comparisons, Vulnerable Road Users, & Risk Factors
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
  library(patchwork)
  library(viridis)
})

log_info("Starting Step 06: Multivariate Analysis (Visualizations D, E, & F)...")

# 1. Load Precomputed Aggregates
borough_agg <- readRDS(file.path(DATA_PROC_DIR, "borough_annual_summary.rds"))
factor_agg  <- readRDS(file.path(DATA_PROC_DIR, "contributing_factors_summary.rds"))
clean_dt    <- readRDS(PROCESSED_DATA_PATH)
vru_summary_path <- file.path(DATA_PROC_DIR, "vru_summary.rds")
if (file.exists(vru_summary_path)) {
  vru_summary <- readRDS(vru_summary_path)
} else {
  vru_summary <- data.table(
    User_Group = c("Motor Vehicle Occupants", "Pedestrians", "Cyclists"),
    Injured = c(sum(clean_dt$motorist_injured, na.rm = TRUE), sum(clean_dt$pedestrians_injured, na.rm = TRUE), sum(clean_dt$cyclist_injured, na.rm = TRUE)),
    Killed = c(sum(clean_dt$motorist_killed, na.rm = TRUE), sum(clean_dt$pedestrians_killed, na.rm = TRUE), sum(clean_dt$cyclist_killed, na.rm = TRUE))
  )
  vru_summary[, Total_Casualties := Injured + Killed]
  vru_summary[, Fatality_Risk_Per_1000_Injured := round((Killed / Injured) * 1000, 2)]
}

# ------------------------------------------------------------------------------
# 2. Visualization D — Borough-Level Multi-Faceted Comparison (2013-2025)
# ------------------------------------------------------------------------------
log_info("Generating Visualization D: Borough Comparison (Volume vs Severity)...")

# Summary totals across complete years (2013-2025)
borough_totals <- borough_agg[, .(
  total_crashes = sum(total_crashes),
  injury_crashes = sum(injury_crashes),
  total_killed = sum(total_killed),
  avg_annual_crashes = round(mean(total_crashes)),
  overall_injury_rate = round((sum(injury_crashes) / sum(total_crashes)) * 100, 1),
  overall_fatality_rate = round((sum(total_killed) / sum(total_crashes)) * 10000, 2)
), by = .(borough)]
setorder(borough_totals, total_crashes)
borough_totals[, borough := factor(borough, levels = borough)]

# Panel D1: Ranked Crash Volume by Borough
p_d1 <- ggplot(borough_totals, aes(x = total_crashes, y = borough, fill = borough)) +
  geom_col(width = 0.65, show.legend = FALSE) +
  geom_text(
    aes(label = sprintf("%s crashes\n(%s / yr)", fmt_count(total_crashes), fmt_count(avg_annual_crashes))),
    hjust = 1.08, color = "white", fontface = "bold", size = 3.2, lineheight = 0.95
  ) +
  scale_x_continuous(labels = comma, expand = expansion(mult = c(0, 0.05))) +
  scale_fill_manual(values = PALETTES$boroughs) +
  labs(
    title = "A. Cumulative Collisions (2013-2025)",
    subtitle = "Ranked absolute collision counts",
    x = "Total Collisions",
    y = NULL
  ) +
  theme_road_safety(base_size = 10) +
  theme(panel.grid.major.y = element_blank())

# Panel D2: Temporal Trend in Injury Rate (% Crashes with Injury) by Borough
p_d2 <- ggplot(borough_agg, aes(x = crash_year, y = injury_rate_pct, color = borough)) +
  geom_line(linewidth = 0.95) +
  geom_point(size = 1.8) +
  scale_color_manual(values = PALETTES$boroughs, name = "Borough:") +
  scale_x_continuous(breaks = seq(2013, 2025, by = 2), expand = expansion(mult = c(0.02, 0.02))) +
  scale_y_continuous(labels = function(x) paste0(x, "%"), limits = c(10, 45), breaks = seq(10, 45, by = 10)) +
  labs(
    title = "B. Evolution of Collision Injury Propensity",
    subtitle = "% Collisions resulting in reported injury",
    x = "Calendar Year",
    y = "Injury Collision Rate (%)"
  ) +
  theme_road_safety(base_size = 10) +
  theme(legend.position = "right")

# Composite Visualization D
p_vis_d <- (p_d1 | p_d2) +
  plot_annotation(
    title = "Visualization D: Comparative Borough Dynamics in Crash Volume and Injury Propensity",
    subtitle = "Comparing cumulative crash volume and longitudinal injury severity across NYC boroughs (Complete Calendar Years 2013-2025)",
    caption = "Source: NYC Open Data / NYPD. Evaluated over complete calendar years (2013-2025) excluding boundary partial years. Denominators stated explicitly.",
    theme = theme(
      plot.title = element_text(face = "bold", size = 13, color = "#1A202C"),
      plot.subtitle = element_text(size = 10, color = "#4A5568")
    )
  )

save_project_plot(p_vis_d, "fig_d_borough_comparison.png", width = 12, height = 6, dpi = DPI_DEFAULT)

# ------------------------------------------------------------------------------
# 3. Visualization E — Road User Vulnerability and Casualty Distribution
# ------------------------------------------------------------------------------
log_info("Generating Visualization E: Vulnerable Road Users & Severity Profile...")

# Calculate casualty totals by victim class from raw CSV if needed
vru_summary_file <- file.path(DATA_PROC_DIR, "vru_summary.rds")
if (file.exists(vru_summary_file)) {
  vru_summary <- readRDS(vru_summary_file)
} else {
  raw_vru <- fread(
    RAW_CSV_PATH,
    select = c(
      "NUMBER OF PEDESTRIANS INJURED", "NUMBER OF PEDESTRIANS KILLED",
      "NUMBER OF CYCLIST INJURED", "NUMBER OF CYCLIST KILLED",
      "NUMBER OF MOTORIST INJURED", "NUMBER OF MOTORIST KILLED"
    ),
    na.strings = c("", "NA")
  )
  setnames(raw_vru, make_clean_names(names(raw_vru)))
  vru_summary <- data.table(
    User_Group = c("Motor Vehicle Occupants", "Pedestrians", "Cyclists"),
    Injured = c(
      sum(as.integer(raw_vru$number_of_motorist_injured), na.rm = TRUE),
      sum(as.integer(raw_vru$number_of_pedestrians_injured), na.rm = TRUE),
      sum(as.integer(raw_vru$number_of_cyclist_injured), na.rm = TRUE)
    ),
    Killed = c(
      sum(as.integer(raw_vru$number_of_motorist_killed), na.rm = TRUE),
      sum(as.integer(raw_vru$number_of_pedestrians_killed), na.rm = TRUE),
      sum(as.integer(raw_vru$number_of_cyclist_killed), na.rm = TRUE)
    )
  )
  vru_summary[, Total_Casualties := Injured + Killed]
  vru_summary[, Fatality_Risk_Per_1000_Injured := round((Killed / Injured) * 1000, 2)]
  saveRDS(vru_summary, vru_summary_file)
}

# Melt for grouped visualization
vru_long <- melt(
  vru_summary,
  id.vars = c("User_Group", "Fatality_Risk_Per_1000_Injured"),
  measure.vars = c("Injured", "Killed"),
  variable.name = "Outcome",
  value.name = "Count"
)

# Panel E1: Grouped Casualty Volume by Road User Group
p_e1 <- ggplot(vru_long, aes(x = Count, y = reorder(User_Group, Count), fill = Outcome)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.65) +
  geom_text(
    aes(label = fmt_count(Count)),
    position = position_dodge(width = 0.7),
    hjust = -0.1, size = 3.1, fontface = "bold"
  ) +
  scale_x_continuous(
    labels = comma,
    expand = expansion(mult = c(0, 0.18))
  ) +
  scale_fill_manual(values = c("Injured" = "#21908C", "Killed" = "#E66101")) +
  labs(
    title = "A. Reported Casualty Counts by Road User Type",
    subtitle = "Comparison of Injured vs Killed victims (2012-2026)",
    x = "Total Reported Victims",
    y = NULL,
    fill = "Severity Outcome:"
  ) +
  theme_road_safety(base_size = 10) +
  theme(legend.position = "top", panel.grid.major.y = element_blank())

# Panel E2: Vulnerability Ratio (Fatalities per 1,000 Casualties)
p_e2 <- ggplot(vru_summary, aes(x = Fatality_Risk_Per_1000_Injured, y = reorder(User_Group, Fatality_Risk_Per_1000_Injured), fill = User_Group)) +
  geom_col(width = 0.55, show.legend = FALSE) +
  geom_text(
    aes(label = sprintf("%.1f deaths / 1,000 injured", Fatality_Risk_Per_1000_Injured)),
    hjust = -0.08, size = 3.2, fontface = "bold", color = "#1A202C"
  ) +
  scale_x_continuous(limits = c(0, 18), breaks = seq(0, 16, by = 4), expand = expansion(mult = c(0, 0.2))) +
  scale_fill_manual(values = c("Motor Vehicle Occupants" = "#3B528B", "Cyclists" = "#5DC863", "Pedestrians" = "#D95F02")) +
  labs(
    title = "B. Vulnerability Ratio: Fatality Rate per 1,000 Injuries",
    subtitle = "Measures physical vulnerability when a collision occurs",
    x = "Reported Fatalities per 1,000 Reported Injuries",
    y = NULL
  ) +
  theme_road_safety(base_size = 10) +
  theme(panel.grid.major.y = element_blank())

p_vis_e <- (p_e1 / p_e2) +
  plot_annotation(
    title = "Visualization E: Road User Vulnerability and Disproportionate Fatality Outcomes",
    subtitle = "Examining the severe physical vulnerability of pedestrians and cyclists relative to vehicle occupants in NYC collisions",
    caption = "Source: NYC Open Data / NYPD. Demonstrates that while motorists account for greatest volume, pedestrians suffer 4.7x higher fatality rate per injury.",
    theme = theme(
      plot.title = element_text(face = "bold", size = 13, color = "#1A202C"),
      plot.subtitle = element_text(size = 10, color = "#4A5568")
    )
  )

save_project_plot(p_vis_e, "fig_e_severity_vru_distribution.png", width = 11, height = 7.5, dpi = DPI_DEFAULT)

# ------------------------------------------------------------------------------
# 4. Visualization F — Contributing Factor Severity Risk Profile
# ------------------------------------------------------------------------------
log_info("Generating Visualization F: Contributing Factors Risk Profile...")

# Filter factors with minimum reliable sample size (>= 5,000 collisions)
factor_plot_dt <- factor_agg[total_crashes >= 5000]
factor_plot_dt[, factor_ordered := reorder(factor_standardized, injury_rate_pct)]
city_avg_injury_rate <- (sum(clean_dt$has_injury) / nrow(clean_dt)) * 100
lowest_factor_name <- as.character(factor_plot_dt$factor_ordered[1])

p_vis_f <- ggplot(factor_plot_dt, aes(x = injury_rate_pct, y = factor_ordered)) +
  # Baseline Citywide Average Reference Line
  geom_vline(xintercept = city_avg_injury_rate, linetype = "dashed", color = "#718096", linewidth = 0.8) +
  # Dumbbell / Dot Plot with crash volume encoded in bubble size and color
  geom_segment(
    aes(x = city_avg_injury_rate, xend = injury_rate_pct, yend = factor_ordered),
    color = "#CBD5E0", linewidth = 1.1
  ) +
  geom_point(aes(size = total_crashes, color = fatality_per_10k), alpha = 0.9) +
  geom_text(
    aes(label = sprintf("%.1f%% (%s crashes)", injury_rate_pct, fmt_count(total_crashes))),
    hjust = -0.15, size = 3.0, fontface = "bold"
  ) +
  scale_x_continuous(
    limits = c(0, 85),
    breaks = seq(0, 80, by = 20),
    labels = function(x) paste0(x, "%"),
    expand = expansion(mult = c(0.02, 0.15))
  ) +
  scale_size_continuous(
    range = c(3, 10),
    labels = comma,
    name = "Reported Crashes:"
  ) +
  scale_color_viridis_c(
    option = "magma",
    direction = -1,
    name = "Fatalities /\n10k Crashes:"
  ) +
  labs(
    title = "Visualization F: Contributing Behavioral Factors and Observed Injury Severity",
    subtitle = sprintf("Comparing collision volume, injury propensity (%%), and fatality rates (Dashed line: Citywide baseline %.1f%%)", city_avg_injury_rate),
    x = "Injury Collision Rate (% of crashes involving >= 1 injury)",
    y = "Recorded Primary Contributing Factor",
    caption = "Source: NYC Open Data / NYPD. Restricted to factors with >= 5,000 reported collisions. Dot size represents total volume; color indicates fatality intensity."
  ) +
  theme_road_safety(base_size = 11) +
  theme(
    legend.position = "right",
    panel.grid.major.y = element_blank()
  )

save_project_plot(p_vis_f, "fig_f_contributing_factors_risk.png", width = 11.5, height = 7, dpi = DPI_DEFAULT)

# ------------------------------------------------------------------------------
# 5. Save Summary Tables
# ------------------------------------------------------------------------------
fwrite(vru_summary, file.path(TABLES_DIR, "table_10_vru_summary.csv"))
fwrite(factor_plot_dt, file.path(TABLES_DIR, "table_11_contributing_factors_ranked.csv"))
log_info("Saved multivariate summary tables to outputs/tables/")

print(vru_summary)
print(factor_plot_dt[, .(factor_standardized, total_crashes, injury_rate_pct, fatality_per_10k)])

log_info("Step 06 completed successfully.")
