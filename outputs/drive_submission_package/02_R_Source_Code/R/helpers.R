# ==============================================================================
# SCRIPT: R/helpers.R
# Helper Functions, Theming, and Utilities for NYC Road Safety Visual Analytics
# Course: CSI3005 Advanced Data Visualization
# ==============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(scales)
  library(viridis)
})

# ------------------------------------------------------------------------------
# 1. Custom Publication-Grade ggplot2 Theme
# ------------------------------------------------------------------------------
theme_road_safety <- function(base_size = 11, base_family = "sans") {
  theme_minimal(base_size = base_size, base_family = base_family) +
    theme(
      # Plot Titles and Captions
      plot.title = element_text(
        face = "bold",
        size = rel(1.25),
        color = "#1A202C",
        margin = margin(b = 6)
      ),
      plot.subtitle = element_text(
        size = rel(0.95),
        color = "#4A5568",
        margin = margin(b = 12),
        lineheight = 1.2
      ),
      plot.caption = element_text(
        size = rel(0.75),
        color = "#718096",
        hjust = 0,
        margin = margin(t = 10)
      ),
      plot.title.position = "plot",
      plot.caption.position = "plot",

      # Panel and Background
      panel.background = element_rect(fill = "#FAFAFA", color = NA),
      plot.background = element_rect(fill = "#FFFFFF", color = NA),
      panel.grid.major = element_line(color = "#E2E8F0", linewidth = 0.4),
      panel.grid.minor = element_blank(),

      # Axes
      axis.title = element_text(face = "bold", size = rel(0.9), color = "#2D3748"),
      axis.title.x = element_text(margin = margin(t = 8)),
      axis.title.y = element_text(margin = margin(r = 8)),
      axis.text = element_text(size = rel(0.85), color = "#4A5568"),
      axis.ticks = element_line(color = "#CBD5E0", linewidth = 0.4),

      # Legend
      legend.position = "bottom",
      legend.title = element_text(face = "bold", size = rel(0.85), color = "#2D3748"),
      legend.text = element_text(size = rel(0.8), color = "#4A5568"),
      legend.background = element_blank(),
      legend.box.background = element_blank(),
      legend.key = element_blank(),
      legend.margin = margin(t = 6),

      # Facet Strips
      strip.background = element_rect(fill = "#EDF2F7", color = NA),
      strip.text = element_text(
        face = "bold",
        size = rel(0.9),
        color = "#2D3748",
        margin = margin(t = 4, b = 4)
      ),

      # Margins
      plot.margin = margin(t = 14, r = 16, b = 14, l = 14)
    )
}

# ------------------------------------------------------------------------------
# 2. Plot Export Helper
# ------------------------------------------------------------------------------
save_project_plot <- function(plot_obj, filename, width = 9, height = 6, dpi = 300) {
  if (!exists("FIGURES_DIR")) {
    fig_dir <- file.path("outputs", "figures")
  } else {
    fig_dir <- FIGURES_DIR
  }
  if (!dir.exists(fig_dir)) {
    dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
  }

  target_path <- file.path(fig_dir, filename)
  ggsave(
    filename = target_path,
    plot = plot_obj,
    width = width,
    height = height,
    dpi = dpi,
    device = "png"
  )
  message(sprintf("[PLOT SAVED] %s (Dimensions: %sx%s in, DPI: %s)", target_path, width, height, dpi))
  invisible(target_path)
}

# ------------------------------------------------------------------------------
# 3. Formatting Helpers
# ------------------------------------------------------------------------------
fmt_count <- function(x) {
  format(x, big.mark = ",", scientific = FALSE, trim = TRUE)
}

fmt_pct <- function(x, decimals = 1) {
  paste0(format(round(x * 100, decimals), nsmall = decimals, trim = TRUE), "%")
}

# ------------------------------------------------------------------------------
# 4. Logger Helper
# ------------------------------------------------------------------------------
log_info <- function(msg, ...) {
  formatted <- sprintf(msg, ...)
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  cat(sprintf("[%s] [INFO] %s\n", timestamp, formatted))
}

log_warn <- function(msg, ...) {
  formatted <- sprintf(msg, ...)
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  cat(sprintf("[%s] [WARN] %s\n", timestamp, formatted))
}

log_error <- function(msg, ...) {
  formatted <- sprintf(msg, ...)
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  cat(sprintf("[%s] [ERROR] %s\n", timestamp, formatted))
}
