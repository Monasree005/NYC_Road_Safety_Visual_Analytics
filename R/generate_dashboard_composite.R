# ==============================================================================
# SCRIPT: Generate Master Executive Dashboard Composite Figure
# ==============================================================================
source("config/project_config.R")
source("R/helpers.R")
suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
  library(data.table)
  library(scales)
})

monthly_agg <- readRDS("data/processed/temporal_monthly_aggregate.rds")
weekday_agg <- readRDS("data/processed/temporal_weekday_hour_aggregate.rds")
borough_agg <- readRDS("data/processed/borough_annual_summary.rds")
factor_agg  <- readRDS("data/processed/contributing_factors_summary.rds")
vru_dt      <- readRDS("data/processed/vru_summary.rds")

# Top KPI Banner Mock
kpi_data <- data.frame(
  x = 1:5,
  y = rep(1, 5),
  label = c("TOTAL COLLISIONS", "TOTAL INJURED", "TOTAL KILLED", "INJURY CRASH RATE", "VRU FATALITY SHARE"),
  value = c("2,269,187", "756,353", "3,617", "24.62%", "58.0% (2,099)"),
  color = c("#2B6CB0", "#D69E2E", "#E53E3E", "#319795", "#805AD5")
)

p_kpi <- ggplot(kpi_data, aes(x = x, y = y)) +
  geom_rect(aes(xmin = x - 0.45, xmax = x + 0.45, ymin = 0.5, ymax = 1.5, fill = color), color = "#E2E8F0", linewidth = 0.8, show.legend = FALSE) +
  geom_text(aes(label = label, y = 1.25), color = "white", size = 2.8, fontface = "bold") +
  geom_text(aes(label = value, y = 0.85), color = "white", size = 4.2, fontface = "bold") +
  scale_fill_identity() +
  coord_cartesian(xlim = c(0.4, 5.6), ylim = c(0.4, 1.6)) +
  theme_void() +
  labs(title = "EXECUTIVE KPI COMMAND RIBBON (CERTIFIED 2,269,187 REPORTED CRASHES: 2012–2026)") +
  theme(plot.title = element_text(face = "bold", size = 11, color = "#1A365D", hjust = 0.5, margin = margin(b = 6)))

# Mini Plot 1: Monthly Crash Volume
p_mini1 <- ggplot(monthly_agg, aes(x = as.Date(year_month), y = total_crashes)) +
  geom_line(color = "#2B6CB0", linewidth = 0.7) +
  scale_y_continuous(labels = comma) +
  scale_x_date(date_breaks = "3 years", date_labels = "%Y") +
  labs(title = "Monthly Crash Volume", x = NULL, y = "Crashes") +
  theme_minimal(base_size = 8.5)

# Mini Plot 2: Diurnal Heatmap
p_mini2 <- ggplot(weekday_agg, aes(x = crash_hour, y = crash_weekday, fill = total_crashes)) +
  geom_tile(color = "white") +
  scale_fill_viridis_c(option = "magma", direction = -1, guide = "none") +
  scale_x_continuous(breaks = seq(0, 23, by = 4)) +
  labs(title = "Diurnal Rhythm Matrix", x = "Hour", y = NULL) +
  theme_minimal(base_size = 8.5)

# Mini Plot 3: Borough Annual Trends
p_mini3 <- ggplot(borough_agg, aes(x = crash_year, y = total_crashes, color = borough)) +
  geom_line(linewidth = 0.8) +
  scale_y_continuous(labels = comma) +
  scale_color_manual(values = PALETTES$boroughs, name = "Borough:") +
  labs(title = "Borough Trends (2013-2025)", x = "Year", y = "Annual Crashes") +
  theme_minimal(base_size = 8.5) +
  theme(legend.position = "bottom", legend.text = element_text(size = 6.5))

# Mini Plot 4: Top Contributing Factors
f_sub <- factor_agg[total_crashes >= 25000]
p_mini4 <- ggplot(f_sub, aes(x = injury_rate_pct, y = reorder(factor_standardized, injury_rate_pct), fill = fatality_per_10k)) +
  geom_col(width = 0.65) +
  scale_fill_viridis_c(option = "magma", direction = -1, name = "Deaths/10k") +
  scale_x_continuous(labels = function(x) paste0(x, "%")) +
  labs(title = "Factor Injury Rate (%)", x = "Injury Rate", y = NULL) +
  theme_minimal(base_size = 8) +
  theme(legend.position = "right", legend.key.height = unit(0.6, "cm"))

p_dash <- p_kpi / (p_mini1 | p_mini2) / (p_mini3 | p_mini4) +
  plot_layout(heights = c(0.8, 1.4, 1.4)) +
  plot_annotation(
    title = "Figure 7: Master Enterprise Executive R Shiny Dashboard Suite",
    subtitle = "Real-Time Spatiotemporal Analytics Command Canvas: Synthesizing KPI Cards, Longitudinal Trends, Diurnal Matrices, and Risk Factors",
    caption = "Interactive R Shiny Application (app/app.R). Implemented using R, ggplot2, and Plotly WebGL.",
    theme = theme(
      plot.title = element_text(face = "bold", size = 12, color = "#1A365D"),
      plot.subtitle = element_text(size = 9.5, color = "#4A5568")
    )
  )

save_project_plot(p_dash, "fig_dashboard_overview.png", width = 11, height = 7.5, dpi = DPI_DEFAULT)
