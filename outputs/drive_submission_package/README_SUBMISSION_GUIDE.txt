==============================================================================
CSI3005 ADVANCED DATA VISUALIZATION - CASE STUDY SUBMISSION PACKAGE
==============================================================================
Candidate Name:    MONASREE S
Register Number:   23MIC0084
Course:            CSI3005 - Advanced Data Visualization Techniques
Class Slot:        E2 (Theory)
Faculty School:    School of Computer Science and Engineering (SCOPE), VIT
Evaluation Marks:  20 Marks

Project Title:
Beyond Crash Counts: Spatiotemporal Visual Analytics for Urban Road-Safety
Hotspots, Injury Severity, and Risk Patterns

Dataset Source:
Official NYPD Motor Vehicle Collisions Public Registry (NYC Open Data)
URL: https://data.cityofnewyork.us/Public-Safety/Motor-Vehicle-Collisions-Crashes/h9gi-nx95
Dataset Identifier: h9gi-nx95
Total Records Ingested: 2,269,187 unique events across 29 attributes (2012-2026)

FOLDER STRUCTURE IN THIS SUBMISSION REPOSITORY:
------------------------------------------------------------------------------
01_Report_PDF/
  -> VIT_CSI3005_Case_Study_Report.pdf (Complete, faculty-compliant 8-page report)

02_R_Source_Code/
  -> run_pipeline.R (Master orchestration script executing all 7 steps end-to-end)
  -> app.R (Production R Shiny executive dashboard application)
  -> config/ (Project paths, bounding boxes, packages, and custom ggplot2 theme)
  -> R/ (Modular analytical scripts: 00_setup.R to 07_export_and_validate.R)
  -> tests/ (Automated data integrity and statistical test suite)

03_Processed_Datasets_CSV/
  -> table_01_dataset_profile.csv (Summary profile of 2.27M raw records)
  -> table_02_data_quality_anomalies.csv (Bounding box and missingness audit)
  -> table_03_preprocessing_log.csv (8-step data preparation tracking)
  -> table_04_monthly_trends.csv (Longitudinal collision volume & severity series)
  -> table_05_weekday_hour_matrix.csv (7x24 diurnal crash distribution)
  -> table_06_borough_annual_metrics.csv (Annual crash and injury totals by borough)
  -> table_07_contributing_factors.csv (Mapped behavioral factor statistics)
  -> table_08_temporal_findings.csv (COVID shock and diurnal peak statistics)
  -> table_09_spatial_hotspots.csv (Top arterial hex clusters and expressways)
  -> table_10_vru_summary.csv (Vulnerable road user injury & lethality ratios)
  -> table_11_contributing_factors_ranked.csv (Ranked fatality intensities)
  -> table_12_visualization_catalog.csv (Catalog of all 13 visual artifacts)
  -> table_13_faculty_compliance_matrix.csv (Assessment requirements mapping)
  -> column_missingness_audit.csv & dataset_audit_metrics.json

04_High_Resolution_Figures/
  -> fig_a_spatial_hex_density.png (Figure 1: Spatial Hex Density Cartogram)
  -> fig_b_temporal_monthly_trend.png (Figure 2: Longitudinal Time-Series)
  -> fig_task3_flawed.png (Figure 3: Deliberately Flawed Deceptive Bar Chart)
  -> fig_task3_corrected.png (Figure 4: Tufte-Compliant Redesigned Bar Chart)
  -> fig_task4_streaming_architecture.png (Figure 5: 5-Tier Streaming Pipeline)
  -> fig_task4_streaming_monitor.png (Figure 6: Real-Time Anomaly Monitor)
  -> fig_dashboard_overview.png (Figure 7: R Shiny Executive Dashboard)
  -> fig_rstudio_execution_proof.png (Figure 8: Authentic RStudio Execution Proof)

05_RStudio_Execution_Proof/
  -> High-resolution screenshots of RStudio IDE, console ingestion logs,
     automated test suite execution (42 unit test passes), and live Shiny server.

06_Turnkey_Project_Zip/
  -> NYC_Road_Safety_Complete_Submission_Package.zip (Single bundled archive)
==============================================================================
