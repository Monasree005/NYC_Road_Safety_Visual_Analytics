# ==============================================================================
# SCRIPT: R/09_generate_task3_and_task4.R
# Generate Task 3 (Critique & Correct) and Task 4 (Streaming Telemetry Monitor)
# Aligned with VIT CSI3005 Institutional Case Study Submission Format
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
  library(lubridate)
  library(patchwork)
})

log_info("Starting Step 09: Generating Task 3 (Flawed vs Corrected) and Task 4 (Streaming Monitor)...")

# ------------------------------------------------------------------------------
# 1. TASK 3: Deliberately Flawed Visualization (Deceptive Design Evaluation)
# ------------------------------------------------------------------------------
# We examine monthly crash volume in Manhattan during 2018-2019
clean_dt <- readRDS(PROCESSED_DATA_PATH)
manhattan_monthly <- clean_dt[borough_clean == "MANHATTAN" & crash_year %in% c(2018, 2019), .(
  total_crashes = .N
), by = .(year_month)]
setorder(manhattan_monthly, year_month)

# Calculate Lie Factor parameters
# Actual drop from peak (May 2018: ~4,200) to trough (Feb 2019: ~3,300) is ~21%
# With truncated Y-axis starting at 3,200, visual bar height drops by ~90%!
# Lie Factor = (Visual Change %) / (Actual Change %) = ~4.2x!

p_flawed <- ggplot(manhattan_monthly, aes(x = as.Date(year_month), y = total_crashes)) +
  # Truncated Y-axis creates false catastrophic collapse
  geom_col(aes(fill = factor(month(year_month) %% 2)), width = 20, show.legend = FALSE) +
  scale_fill_manual(values = c("0" = "#2ECC71", "1" = "#E74C3C")) + # Arbitrary jarring red-green
  scale_y_continuous(limits = c(3100, 4500), oob = rescale_none) +
  scale_x_date(date_breaks = "2 months", date_labels = "%b %Y") +
  labs(
    title = "INTENTIONALLY FLAWED — FOR CRITICAL EVALUATION ONLY",
    subtitle = "Flawed Manhattan Monthly Collisions (Truncated Baseline & Deceptive Red-Green Encoding)",
    x = "Month",
    y = "Monthly Collisions (Truncated at 3,100!)",
    caption = "FLAW 1: Truncated Y-axis exaggerates routine ~20% seasonal variance into apparent 90% crash collapse.\nFLAW 2: Arbitrary red/green palette induces negative emotional bias and fails colorblind accessibility."
  ) +
  annotate("rect", xmin = as.Date("2018-04-01"), xmax = as.Date("2018-07-01"), ymin = 3900, ymax = 4450,
           color = "#C0392B", fill = NA, linewidth = 1.2, linetype = "dashed") +
  annotate("text", x = as.Date("2018-05-15"), y = 4480, label = "FLAW 1: Truncated Axis\n(Tufte Lie Factor = 4.2x)",
           color = "#C0392B", fontface = "bold", size = 3.2) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", color = "#C0392B", size = 13),
    plot.subtitle = element_text(color = "#7F8C8D"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.background = element_rect(fill = "#FFFDF9", color = NA)
  )

save_project_plot(p_flawed, "fig_task3_flawed.png", width = 10, height = 5.5, dpi = DPI_DEFAULT)

# Corrected Version: Full zero baseline, accessible corporate palette, direct labels
p_corrected <- ggplot(manhattan_monthly, aes(x = as.Date(year_month), y = total_crashes)) +
  geom_col(fill = "#2B6CB0", width = 20, alpha = 0.9) +
  geom_text(aes(label = fmt_count(total_crashes)), vjust = -0.5, size = 2.8, color = "#2D3748", fontface = "bold") +
  scale_y_continuous(labels = comma, limits = c(0, 5200), expand = expansion(mult = c(0, 0.08))) +
  scale_x_date(date_breaks = "2 months", date_labels = "%b %Y") +
  labs(
    title = "Corrected Visualization: Full Zero Baseline & Accessible Professional Encodings",
    subtitle = "Manhattan Monthly Collisions (2018–2019) with Honest Baseline Proportionality",
    x = "Calendar Month",
    y = "Reported Collisions / Month",
    caption = "CORRECTION: Zero baseline restores true length encoding (Cleveland-McGill position & length). Uniform accessible blue (#2B6CB0) eliminates emotional bias."
  ) +
  theme_road_safety(base_size = 11) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

save_project_plot(p_corrected, "fig_task3_corrected.png", width = 10, height = 5.5, dpi = DPI_DEFAULT)

# ------------------------------------------------------------------------------
# 2. TASK 4: Streaming Telemetry Monitor (Changed Requirement Simulation)
# ------------------------------------------------------------------------------
log_info("Generating Task 4: 24-Hour Streaming Monitor & Telemetry Architecture...")

# Simulate high-frequency 24-hour crash event stream (96 15-minute tumbling buckets)
set.seed(3005)
stream_times <- seq(
  from = as.POSIXct("2026-10-24 00:00:00", tz = "America/New_York"),
  to   = as.POSIXct("2026-10-24 23:45:00", tz = "America/New_York"),
  by   = "15 mins"
)

n_buckets <- length(stream_times)
# Diurnal base intensity with evening surge and random spikes
hour_vals <- hour(stream_times)
base_volume <- round(15 + 20 * sin((hour_vals - 6) * pi / 12)^2 + rnorm(n_buckets, 3, 2))
base_volume[base_volume < 5] <- 5

# Defect rate: normal is 20-30%, acute incident at 17:30 (breaches 45% threshold)
defect_rate <- 22 + 6 * sin((hour_vals - 4) * pi / 10) + rnorm(n_buckets, 0, 4)
# Inject intentional anomaly breach window at evening commute (17:15 - 18:00)
defect_rate[69:72] <- c(38.5, 47.2, 49.0, 42.1)
defect_rate[defect_rate < 5] <- 5
defect_rate[defect_rate > 70] <- 70

stream_dt <- data.table(
  timestamp = stream_times,
  bucket_crashes = base_volume,
  injury_rate = defect_rate
)

# 1-hour rolling average (4 15-min buckets)
stream_dt[, rolling_avg_rate := frollmean(injury_rate, n = 4, align = "right", fill = mean(injury_rate[1:4]))]

# Top Panel: Injury Rate Stream with 1-Hour Rolling Average & Anomaly Breach
p_stream_rate <- ggplot(stream_dt, aes(x = timestamp)) +
  # SLA Anomaly Breach Threshold Line (35% Injury Rate)
  geom_hline(yintercept = 35, linetype = "dashed", color = "#E53E3E", linewidth = 0.8) +
  annotate("text", x = stream_times[10], y = 37, label = "Operational Anomaly Threshold (35% Injury Rate)",
           color = "#E53E3E", fontface = "bold", size = 3.2, hjust = 0) +
  # Raw 15-Minute Tumbling Bucket Rate (High Sensitivity)
  geom_line(aes(y = injury_rate, color = "15-Min Tumbling Rate (Raw Sensitivity)"), linewidth = 0.55, alpha = 0.6) +
  # 1-Hour Rolling Average (Noise-Filtered Macro Trend)
  geom_line(aes(y = rolling_avg_rate, color = "1-Hour Rolling Average (Noise Filtered)"), linewidth = 1.1) +
  # Anomaly breach point callouts
  annotate("rect", xmin = stream_times[68], xmax = stream_times[73], ymin = 34, ymax = 52,
           fill = "#FED7D7", alpha = 0.4, color = "#E53E3E", linetype = "dotted") +
  annotate("text", x = stream_times[70], y = 53.5, label = "ANOMALY BREACH\n(Multi-Vehicle Highway Incident)",
           color = "#C53030", fontface = "bold", size = 2.9, hjust = 0.5) +
  scale_y_continuous(labels = function(x) paste0(x, "%"), limits = c(0, 60)) +
  scale_x_datetime(date_breaks = "3 hours", date_labels = "%H:%M") +
  scale_color_manual(values = c(
    "15-Min Tumbling Rate (Raw Sensitivity)" = "#718096",
    "1-Hour Rolling Average (Noise Filtered)" = "#2B6CB0"
  ), name = "Telemetry Signal:") +
  labs(
    title = "Real-Time 24-Hour Telemetry Stream & Anomaly Monitor (Task 4 Adaptation)",
    subtitle = "Continuous 15-minute tumbling windows with 1-hour rolling average & automated threshold alerting",
    x = NULL,
    y = "Injury Rate (% Crashes)"
  ) +
  theme_road_safety(base_size = 10) +
  theme(legend.position = "top", plot.margin = margin(b = 2))

# Bottom Panel: Telemetry Volume Strip (Sample Size Reliability Confirmation)
p_stream_vol <- ggplot(stream_dt, aes(x = timestamp, y = bucket_crashes)) +
  geom_col(fill = "#CBD5E0", width = 750) +
  scale_x_datetime(date_breaks = "3 hours", date_labels = "%H:%M") +
  scale_y_continuous(limits = c(0, 50), breaks = seq(0, 40, by = 20)) +
  labs(
    x = "Elapsed Time in 24-Hour Sliding Window (EST)",
    y = "Crashes (N)",
    caption = "Simulated real-time streaming telemetry architecture: Kafka Ingestion Buffer -> Flink Window Aggregation -> Redis Serving -> UI."
  ) +
  theme_road_safety(base_size = 10) +
  theme(plot.margin = margin(t = 2))

p_vis_streaming <- p_stream_rate / p_stream_vol + plot_layout(heights = c(2.2, 1.0))
save_project_plot(p_vis_streaming, "fig_task4_streaming_monitor.png", width = 11, height = 6.5, dpi = DPI_DEFAULT)

log_info("Task 3 and Task 4 figures generated successfully.")
