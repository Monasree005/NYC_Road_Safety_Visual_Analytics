# ==============================================================================
# SCRIPT: app/app.R
# Interactive Shiny & Plotly Dashboard: Spatiotemporal Visual Analytics
# Course: CSI3005 Advanced Data Visualization - Case Study Lab Assessment
# ==============================================================================

# Find project root and dependencies
find_app_root <- function() {
  candidate <- getwd()
  for (i in 1:4) {
    if (file.exists(file.path(candidate, "NYC_Road_Safety_Visual_Analytics.Rproj")) ||
        dir.exists(file.path(candidate, "config"))) {
      return(normalizePath(candidate, winslash = "/"))
    }
    candidate <- dirname(candidate)
  }
  return("C:/Users/nivet/Documents/NYC_Road_Safety_Visual_Analytics")
}

APP_ROOT <- find_app_root()
setwd(APP_ROOT)

suppressPackageStartupMessages({
  library(shiny)
  library(data.table)
  library(ggplot2)
  library(plotly)
  library(scales)
  library(viridis)
})

# Source helpers
if (file.exists("R/helpers.R")) source("R/helpers.R")

# Fast load of precomputed analytical datasets
monthly_agg      <- readRDS("data/processed/temporal_monthly_aggregate.rds")
weekday_hour_agg <- readRDS("data/processed/temporal_weekday_hour_aggregate.rds")
borough_agg      <- readRDS("data/processed/borough_annual_summary.rds")
factor_agg       <- readRDS("data/processed/contributing_factors_summary.rds")
spatial_sample   <- readRDS("data/processed/crashes_spatial_sample.rds")

# UI Definition
ui <- fluidPage(
  theme = bslib::bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#1A365D",
    secondary = "#2B6CB0"
  ),

  titlePanel(
    windowTitle = "NYC Road Safety Visual Analytics (CSI3005)",
    title = div(
      h2("Beyond Crash Counts: Spatiotemporal Road-Safety Analytics", style = "font-weight: 700; color: #1A365D; margin-bottom: 2px;"),
      h5("CSI3005 Advanced Data Visualization — Interactive Case Study Explorer", style = "color: #4A5568; margin-top: 0px;")
    )
  ),

  sidebarLayout(
    sidebarPanel(
      width = 3,
      h4("Analytical Filters", style = "font-weight: 600; color: #2D3748;"),
      p("Interactively filter the verified NYC collision database across temporal and administrative dimensions.", style = "font-size: 0.88rem; color: #718096;"),

      sliderInput(
        "year_range",
        label = "Calendar Year Range:",
        min = 2012,
        max = 2026,
        value = c(2013, 2025),
        step = 1,
        sep = ""
      ),

      selectInput(
        "borough_sel",
        label = "Borough:",
        choices = c("All Boroughs", "BRONX", "BROOKLYN", "MANHATTAN", "QUEENS", "STATEN ISLAND"),
        selected = "All Boroughs"
      ),

      selectInput(
        "severity_sel",
        label = "Severity Tier:",
        choices = c("All Severities", "Fatal Crash", "Injury Only", "No Injury"),
        selected = "All Severities"
      ),

      hr(),
      h5("Dataset Coverage", style = "font-weight: 600;"),
      tags$ul(
        style = "font-size: 0.85rem; padding-left: 18px; color: #4A5568;",
        tags$li("Total Ingested Crashes: 2,269,187"),
        tags$li("Valid Geocoded Records: 2,020,640"),
        tags$li("Time Span: July 2012 to June 2026"),
        tags$li("Source: NYPD / NYC Open Data")
      ),
      hr(),
      actionButton("reset_btn", "Reset Filters", class = "btn-secondary btn-sm w-100")
    ),

    mainPanel(
      width = 9,
      # KPI Value Boxes
      fluidRow(
        column(3, div(class = "card p-3 text-center shadow-sm", style = "border-top: 4px solid #2B6CB0;",
                      h6("TOTAL CRASHES", style = "color: #718096; font-size: 0.75rem; font-weight: 700;"),
                      h3(textOutput("kpi_crashes"), style = "color: #1A365D; font-weight: 700; margin: 0;"))),
        column(3, div(class = "card p-3 text-center shadow-sm", style = "border-top: 4px solid #D69E2E;",
                      h6("TOTAL INJURED", style = "color: #718096; font-size: 0.75rem; font-weight: 700;"),
                      h3(textOutput("kpi_injured"), style = "color: #B7791F; font-weight: 700; margin: 0;"))),
        column(3, div(class = "card p-3 text-center shadow-sm", style = "border-top: 4px solid #E53E3E;",
                      h6("TOTAL KILLED", style = "color: #718096; font-size: 0.75rem; font-weight: 700;"),
                      h3(textOutput("kpi_killed"), style = "color: #C53030; font-weight: 700; margin: 0;"))),
        column(3, div(class = "card p-3 text-center shadow-sm", style = "border-top: 4px solid #319795;",
                      h6("INJURY COLLISION RATE", style = "color: #718096; font-size: 0.75rem; font-weight: 700;"),
                      h3(textOutput("kpi_rate"), style = "color: #234E52; font-weight: 700; margin: 0;")))
      ),
      br(),

      # Navigation Tabs
      tabsetPanel(
        id = "tabs",
        tabPanel(
          "Longitudinal Trends",
          br(),
          plotlyOutput("plot_temporal", height = "450px"),
          p("Monthly collision counts and injury proportion across the selected period. Notice structural pandemic dip in March-April 2020.", style = "font-size: 0.85rem; color: #718096; margin-top: 6px;")
        ),
        tabPanel(
          "Diurnal Weekday x Hour",
          br(),
          plotlyOutput("plot_diurnal", height = "450px"),
          p("Crash frequency matrix across days of week and 24-hour cycle. Darker colors denote elevated collision concentration.", style = "font-size: 0.85rem; color: #718096; margin-top: 6px;")
        ),
        tabPanel(
          "Borough Comparisons",
          br(),
          plotlyOutput("plot_borough", height = "450px"),
          p("Comparative annual crash volume across the five administrative boroughs of New York City.", style = "font-size: 0.85rem; color: #718096; margin-top: 6px;")
        ),
        tabPanel(
          "Geospatial Sample Hotspots",
          br(),
          plotlyOutput("plot_spatial", height = "450px"),
          p("Interactive spatial point distribution (100,000 representative collision sample, seed=3005) colored by severity tier.", style = "font-size: 0.85rem; color: #718096; margin-top: 6px;")
        ),
        tabPanel(
          "Contributing Behavioral Factors",
          br(),
          plotlyOutput("plot_factors", height = "450px"),
          p("Top contributing factors ranked by collision frequency and observed injury propensity.", style = "font-size: 0.85rem; color: #718096; margin-top: 6px;")
        )
      )
    )
  )
)

# Server Logic
server <- function(input, output, session) {

  # Reset button observer
  observeEvent(input$reset_btn, {
    updateSliderInput(session, "year_range", value = c(2013, 2025))
    updateSelectInput(session, "borough_sel", selected = "All Boroughs")
    updateSelectInput(session, "severity_sel", selected = "All Severities")
  })

  # Filtered Monthly Data
  filtered_monthly <- reactive({
    m <- monthly_agg[crash_year >= input$year_range[1] & crash_year <= input$year_range[2]]
    return(m)
  })

  # Filtered Spatial Sample Data
  filtered_spatial <- reactive({
    s <- spatial_sample[crash_year >= input$year_range[1] & crash_year <= input$year_range[2]]
    if (input$borough_sel != "All Boroughs") {
      s <- s[borough_clean == input$borough_sel]
    }
    if (input$severity_sel != "All Severities") {
      s <- s[severity_tier == input$severity_sel]
    }
    return(s)
  })

  # KPI Outputs
  output$kpi_crashes <- renderText({
    m <- filtered_monthly()
    fmt_count(sum(m$total_crashes))
  })

  output$kpi_injured <- renderText({
    m <- filtered_monthly()
    fmt_count(sum(m$total_injured))
  })

  output$kpi_killed <- renderText({
    m <- filtered_monthly()
    fmt_count(sum(m$total_killed))
  })

  output$kpi_rate <- renderText({
    m <- filtered_monthly()
    tot <- sum(m$total_crashes)
    if (tot == 0) return("0.0%")
    fmt_pct(sum(m$injury_crashes) / tot)
  })

  # Tab 1: Longitudinal Plot
  output$plot_temporal <- renderPlotly({
    m <- filtered_monthly()
    if (nrow(m) == 0) return(NULL)

    p <- ggplot(m, aes(x = as.Date(year_month), y = total_crashes, text = sprintf("Date: %s<br>Crashes: %s<br>Injured: %s", format(as.Date(year_month), "%B %Y"), fmt_count(total_crashes), fmt_count(total_injured)))) +
      geom_line(color = "#2B6CB0", linewidth = 0.8) +
      geom_point(color = "#2B6CB0", size = 1.2) +
      scale_y_continuous(labels = comma) +
      scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
      labs(x = "Year", y = "Monthly Collisions", title = "Monthly Reported Traffic Collisions in NYC") +
      theme_minimal()

    ggplotly(p, tooltip = "text")
  })

  # Tab 2: Diurnal Heat Map Plot
  output$plot_diurnal <- renderPlotly({
    w_agg <- weekday_hour_agg
    p <- ggplot(w_agg, aes(x = crash_hour, y = crash_weekday, fill = total_crashes,
                           text = sprintf("Day: %s<br>Hour: %02d:00<br>Crashes: %s", crash_weekday, crash_hour, fmt_count(total_crashes)))) +
      geom_tile(color = "white") +
      scale_fill_viridis_c(option = "magma", direction = -1, labels = comma, name = "Crashes") +
      scale_x_continuous(breaks = seq(0, 23, by = 2), labels = sprintf("%02d:00", seq(0, 23, by = 2))) +
      labs(x = "Hour of Day", y = "Day of Week", title = "Diurnal Rhythm of Collisions by Weekday & Hour") +
      theme_minimal()

    ggplotly(p, tooltip = "text")
  })

  # Tab 3: Borough Comparison Plot
  output$plot_borough <- renderPlotly({
    b_agg <- borough_agg[crash_year >= input$year_range[1] & crash_year <= input$year_range[2]]
    if (input$borough_sel != "All Boroughs") {
      b_agg <- b_agg[borough == input$borough_sel]
    }
    if (nrow(b_agg) == 0) return(NULL)

    p <- ggplot(b_agg, aes(x = crash_year, y = total_crashes, color = borough,
                           text = sprintf("Borough: %s<br>Year: %d<br>Crashes: %s", borough, crash_year, fmt_count(total_crashes)))) +
      geom_line(linewidth = 0.9) +
      geom_point(size = 1.5) +
      scale_y_continuous(labels = comma) +
      scale_x_continuous(breaks = seq(input$year_range[1], input$year_range[2], by = 2)) +
      scale_color_manual(values = PALETTES$boroughs) +
      labs(x = "Year", y = "Annual Collisions", title = "Annual Collision Trends Across NYC Boroughs") +
      theme_minimal()

    ggplotly(p, tooltip = "text")
  })

  # Tab 4: Geospatial Point Sample Plot
  output$plot_spatial <- renderPlotly({
    s <- filtered_spatial()
    if (nrow(s) == 0) return(NULL)
    # Take responsive slice for smooth webGL rendering
    s_sub <- s[sample(.N, min(.N, 5000))]

    p <- ggplot(s_sub, aes(x = longitude, y = latitude, color = severity_tier,
                           text = sprintf("ID: %s<br>Borough: %s<br>Severity: %s", collision_id, borough_clean, severity_tier))) +
      geom_point(alpha = 0.45, size = 1) +
      scale_color_manual(values = PALETTES$severity, name = "Severity") +
      coord_quickmap(xlim = c(NYC_BBOX$lon_min, NYC_BBOX$lon_max), ylim = c(NYC_BBOX$lat_min, NYC_BBOX$lat_max)) +
      labs(x = "Longitude", y = "Latitude", title = "Spatial Distribution of Collisions (Responsive Sample)") +
      theme_minimal()

    ggplotly(p, tooltip = "text")
  })

  # Tab 5: Contributing Factors Plot
  output$plot_factors <- renderPlotly({
    f_dt <- factor_agg[total_crashes >= 5000]
    p <- ggplot(f_dt, aes(x = injury_rate_pct, y = reorder(factor_standardized, injury_rate_pct),
                          fill = fatality_per_10k,
                          text = sprintf("Factor: %s<br>Total Crashes: %s<br>Injury Rate: %.1f%%<br>Fatality Rate: %.1f / 10k",
                                         factor_standardized, fmt_count(total_crashes), injury_rate_pct, fatality_per_10k))) +
      geom_col(width = 0.65) +
      scale_fill_viridis_c(option = "magma", direction = -1, name = "Fatalities / 10k") +
      scale_x_continuous(labels = function(x) paste0(x, "%")) +
      labs(x = "Injury Collision Rate (%)", y = NULL, title = "Contributing Behavioral Factors & Observed Injury Rate") +
      theme_minimal()

    ggplotly(p, tooltip = "text")
  })
}

# Run app if called directly
if (interactive() || !exists(".RUNNING_AS_APP")) {
  shinyApp(ui = ui, server = server)
}
