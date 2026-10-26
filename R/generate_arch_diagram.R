# ==============================================================================
# SCRIPT: Generate Streaming Architecture Diagram
# ==============================================================================
source("config/project_config.R")
source("R/helpers.R")
suppressPackageStartupMessages({
  library(ggplot2)
})

boxes <- data.frame(
  id = 1:5,
  x = c(1, 2.5, 4, 5.5, 7),
  y = rep(1, 5),
  title = c(
    "1. INGESTION SOURCE",
    "2. EVENT BUFFER",
    "3. STREAM ENGINE",
    "4. SERVING LAYER",
    "5. REAL-TIME UI"
  ),
  tech = c(
    "NYPD 911 / CAD Feed\nConnected Telemetry\nJSON Webhooks",
    "Apache Kafka\nDistributed Partitions\nPersistent Commit Log",
    "Apache Flink\n15-min Tumbling Windows\n1-Hour Rolling State",
    "Redis / ClickHouse\nSub-10ms Latency\nIn-Memory OLAP Cache",
    "R Shiny Dashboard\nPlotly WebGL Live Monitor\nAutomated Alert Triggers"
  )
)

arrows <- data.frame(
  x = c(1.6, 3.1, 4.6, 6.1),
  xend = c(1.9, 3.4, 4.9, 6.4),
  y = rep(1, 4),
  yend = rep(1, 4)
)

p_arch <- ggplot() +
  geom_rect(data = boxes, aes(xmin = x - 0.6, xmax = x + 0.6, ymin = 0.55, ymax = 1.45),
            fill = "#F7FAFC", color = "#2B6CB0", linewidth = 1.1, radius = grid::unit(6, "pt")) +
  geom_text(data = boxes, aes(x = x, y = 1.3, label = title),
            fontface = "bold", size = 3.3, color = "#1A365D") +
  geom_text(data = boxes, aes(x = x, y = 0.95, label = tech),
            size = 2.6, color = "#4A5568", lineheight = 1.1) +
  geom_segment(data = arrows, aes(x = x, xend = xend, y = y, yend = yend),
               arrow = arrow(length = unit(0.2, "cm"), type = "closed"),
               color = "#2B6CB0", linewidth = 1.2) +
  coord_cartesian(xlim = c(0.2, 7.8), ylim = c(0.4, 1.6)) +
  labs(
    title = "Figure 5: 5-Tier High-Frequency Streaming Telemetry Pipeline Architecture",
    subtitle = "Decoupled Event Streaming Engine Enabling Continuous Road Safety Monitoring & Anomaly Detection"
  ) +
  theme_void(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 12, color = "#1A365D", hjust = 0.5, margin = margin(b = 4)),
    plot.subtitle = element_text(size = 9.5, color = "#718096", hjust = 0.5, margin = margin(b = 10)),
    plot.margin = margin(10, 10, 10, 10),
    panel.background = element_rect(fill = "#FFFFFF", color = NA)
  )

save_project_plot(p_arch, "fig_task4_streaming_architecture.png", width = 10, height = 3.2, dpi = DPI_DEFAULT)
