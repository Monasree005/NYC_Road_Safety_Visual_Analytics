# ==============================================================================
# SCRIPT: R/04_temporal_analysis.R
# Longitudinal Trend Decomposition and Diurnal Rhythm Visual Analytics
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

log_info("Starting Step 04: Temporal Analysis (Visualizations B & C)...")

# 1. Load Precomputed Aggregates
monthly_agg <- readRDS(file.path(DATA_PROC_DIR, "temporal_monthly_aggregate.rds"))
weekday_hour_agg <- readRDS(file.path(DATA_PROC_DIR, "temporal_weekday_hour_aggregate.rds"))

# ------------------------------------------------------------------------------
# 2. Visualization B — Longitudinal Monthly Trend Analysis (2012 - 2026)
# ------------------------------------------------------------------------------
log_info("Generating Visualization B: Longitudinal Monthly Crash & Injury Trends...")

# Identify key historical inflection points
covid_date <- as.Date("2020-03-01")
vision_zero_date <- as.Date("2014-01-01")

# Annotate monthly peaks and troughs
pre_covid_mean <- monthly_agg[year_month >= as.Date("2015-01-01") & year_month < as.Date("2020-01-01"), mean(total_crashes)]
covid_trough <- monthly_agg[year_month == as.Date("2020-04-01"), total_crashes]
pct_drop_covid <- round((1 - (covid_trough / pre_covid_mean)) * 100, 1)

# Panel 1: Monthly Crash Volume
p_vol <- ggplot(monthly_agg, aes(x = as.Date(year_month), y = total_crashes)) +
  annotate(
    "rect",
    xmin = as.Date("2012-07-01"), xmax = as.Date("2012-12-31"), ymin = -Inf, ymax = Inf,
    fill = "#EDF2F7", alpha = 0.5
  ) +
  annotate(
    "rect",
    xmin = as.Date("2026-01-01"), xmax = as.Date("2026-06-11"), ymin = -Inf, ymax = Inf,
    fill = "#EDF2F7", alpha = 0.5
  ) +
  geom_line(color = "#2B6CB0", linewidth = 0.85) +
  geom_point(color = "#2B6CB0", size = 1.2, alpha = 0.6) +
  geom_vline(xintercept = covid_date, linetype = "dashed", color = "#E53E3E", linewidth = 0.7) +
  geom_vline(xintercept = vision_zero_date, linetype = "dotted", color = "#4A5568", linewidth = 0.7) +
  annotate(
    "text", x = as.Date("2014-03-01"), y = 20500,
    label = "Vision Zero Initiated (Jan 2014)", hjust = 0, size = 3.2, color = "#2D3748", fontface = "italic"
  ) +
  annotate(
    "text", x = as.Date("2020-05-01"), y = 6000,
    label = sprintf("COVID-19 Lockdown\n(-%.1f%% volume)", pct_drop_covid),
    hjust = 0, size = 3.2, color = "#C53030", fontface = "bold"
  ) +
  annotate(
    "text", x = as.Date("2012-09-01"), y = 5000,
    label = "Partial Year\n(2012)", size = 2.7, color = "#718096"
  ) +
  annotate(
    "text", x = as.Date("2026-03-01"), y = 5000,
    label = "Partial Year\n(2026)", size = 2.7, color = "#718096"
  ) +
  scale_y_continuous(labels = comma, limits = c(0, 23000), expand = expansion(mult = c(0, 0.05))) +
  scale_x_date(
    date_breaks = "2 years",
    date_labels = "%Y",
    expand = expansion(mult = c(0.01, 0.01))
  ) +
  labs(
    title = "Visualization B: Longitudinal Evolution of Reported Traffic Collisions in New York City",
    subtitle = "Monthly collision volume and injury proportion across 14 years (July 2012 - June 2026)",
    x = NULL,
    y = "Reported Collisions / Month"
  ) +
  theme_road_safety(base_size = 11) +
  theme(plot.margin = margin(b = 2))

# Panel 2: Injury Rate Evolution (% Collisions with >=1 Injury)
p_rate <- ggplot(monthly_agg, aes(x = as.Date(year_month), y = injury_rate_pct)) +
  geom_line(color = "#C53030", linewidth = 0.85) +
  geom_point(color = "#C53030", size = 1.1, alpha = 0.5) +
  geom_smooth(method = "loess", span = 0.2, color = "#2D3748", linetype = "solid", linewidth = 0.6, se = FALSE) +
  geom_vline(xintercept = covid_date, linetype = "dashed", color = "#E53E3E", linewidth = 0.7) +
  scale_y_continuous(
    labels = function(x) paste0(x, "%"),
    limits = c(10, 50),
    breaks = seq(10, 50, by = 10)
  ) +
  scale_x_date(
    date_breaks = "2 years",
    date_labels = "%Y",
    expand = expansion(mult = c(0.01, 0.01))
  ) +
  labs(
    x = "Calendar Year",
    y = "% Crashes with Injury",
    caption = "Source: NYPD Motor Vehicle Collisions (NYC Open Data). Shaded zones indicate partial years. LOESS trend line shown in dark grey."
  ) +
  theme_road_safety(base_size = 11) +
  theme(plot.margin = margin(t = 2))

# Composite Visualization B using Patchwork
p_vis_b <- p_vol / p_rate + plot_layout(heights = c(1.4, 1.0))
save_project_plot(p_vis_b, "fig_b_temporal_monthly_trend.png", width = 10, height = 7.5, dpi = DPI_DEFAULT)

# ------------------------------------------------------------------------------
# 3. Visualization C — Weekday-by-Hour Heat Map Matrix
# ------------------------------------------------------------------------------
log_info("Generating Visualization C: Weekday-by-Hour Diurnal Matrix...")

# Weekday labels formatting
weekday_order <- c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
weekday_hour_agg[, crash_weekday := factor(crash_weekday, levels = rev(weekday_order))]

# Peak cell calculation
peak_cell <- weekday_hour_agg[which.max(total_crashes)]

p_vis_c <- ggplot(weekday_hour_agg, aes(x = crash_hour, y = crash_weekday, fill = total_crashes)) +
  geom_tile(color = "white", linewidth = 0.4) +
  scale_fill_viridis_c(
    option = "magma",
    labels = comma,
    direction = -1,
    name = "Total Collisions:"
  ) +
  scale_x_continuous(
    breaks = 0:23,
    labels = sprintf("%02d:00", 0:23),
    expand = c(0, 0)
  ) +
  scale_y_discrete(expand = c(0, 0)) +
  # Highlight the absolute peak window
  geom_rect(
    data = peak_cell,
    aes(xmin = crash_hour - 0.5, xmax = crash_hour + 0.5,
        ymin = as.numeric(crash_weekday) - 0.5, ymax = as.numeric(crash_weekday) + 0.5),
    fill = NA, color = "#00FFCC", linewidth = 1.2, inherit.aes = FALSE
  ) +
  annotate(
    "text", x = 17, y = 2.5,
    label = "Weekday Evening Rush Peak\n(16:00 - 18:00)",
    color = "white", fontface = "bold", size = 3.2, hjust = 0.5
  ) +
  annotate(
    "text", x = 3.5, y = 1.2,
    label = "Weekend Early AM\nHigh-Severity Window",
    color = "#FBD38D", fontface = "italic", size = 2.9, hjust = 0.5
  ) +
  labs(
    title = "Visualization C: Diurnal and Weekly Rhythm of NYC Traffic Collisions",
    subtitle = sprintf("Aggregated distribution across %s recorded crash hours (2012-2026)", fmt_count(sum(weekday_hour_agg$total_crashes))),
    x = "Hour of Day (24-Hour Military Time)",
    y = "Day of Week",
    caption = "Source: NYC Open Data / NYPD. Cyan border indicates global empirical peak: Friday 16:00-17:00."
  ) +
  theme_road_safety(base_size = 11) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8.5),
    panel.grid = element_blank(),
    legend.position = "right",
    legend.key.height = unit(1.2, "cm")
  )

save_project_plot(p_vis_c, "fig_c_weekday_hour_heatmap.png", width = 11, height = 5.8, dpi = DPI_DEFAULT)

# ------------------------------------------------------------------------------
# 4. Save Temporal Analytical Findings Table
# ------------------------------------------------------------------------------
findings_temporal <- data.table(
  Metric = c(
    "Pre-COVID Average Monthly Crashes (2015-2019)",
    "COVID-19 Lockdown Minimum Monthly Crashes (April 2020)",
    "Volume Reduction During COVID-19 Lockdown",
    "Post-Lockdown Average Monthly Crashes (2021-2025)",
    "Historical Pre-COVID Injury Collision Rate (2013-2019 Average)",
    "Post-COVID Injury Collision Rate (2021-2025 Average)",
    "Structural Injury Rate Shift (Percentage Point Increase)",
    "Absolute Peak Collision Hour in NYC",
    "Lowest Volume Collision Hour in NYC"
  ),
  Value = c(
    fmt_count(round(pre_covid_mean)),
    fmt_count(covid_trough),
    paste0("-", pct_drop_covid, "%"),
    fmt_count(round(monthly_agg[crash_year >= 2021 & crash_year <= 2025, mean(total_crashes)])),
    fmt_pct(monthly_agg[crash_year >= 2013 & crash_year <= 2019, sum(injury_crashes) / sum(total_crashes)]),
    fmt_pct(monthly_agg[crash_year >= 2021 & crash_year <= 2025, sum(injury_crashes) / sum(total_crashes)]),
    sprintf("+%.1f percentage points",
            (monthly_agg[crash_year >= 2021 & crash_year <= 2025, sum(injury_crashes) / sum(total_crashes)] -
             monthly_agg[crash_year >= 2013 & crash_year <= 2019, sum(injury_crashes) / sum(total_crashes)]) * 100),
    sprintf("%s at %02d:00 (%s collisions)", as.character(peak_cell$crash_weekday), peak_cell$crash_hour, fmt_count(peak_cell$total_crashes)),
    sprintf("%s at 04:00 (%s collisions)", as.character(weekday_hour_agg[which.min(total_crashes)]$crash_weekday), fmt_count(weekday_hour_agg[which.min(total_crashes)]$total_crashes))
  )
)

fwrite(findings_temporal, file.path(TABLES_DIR, "table_08_temporal_findings.csv"))
log_info("Saved temporal findings table to: %s", file.path(TABLES_DIR, "table_08_temporal_findings.csv"))
print(findings_temporal)

log_info("Step 04 completed successfully.")
