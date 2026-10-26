# Beyond Crash Counts: Spatiotemporal Visual Analytics for Urban Road-Safety Hotspots, Injury Severity, and Risk Patterns

**Candidate Name:** Monasree S  
**Register Number:** 23MIC0084  
**Course Code & Title:** CSI3005 &mdash; Advanced Data Visualization Techniques  
**Class Slot:** E2 (Theory)  
**School:** School of Computer Science and Engineering (SCOPE), Vellore Institute of Technology  
**Assessment:** Case Study-Based Lab Assessment (Fall Semester 2026–27) &mdash; **20 Marks**  
**Development Environment:** RStudio (R Version 4.6.1 x64, Windows)  
**Official Dataset Source:** [NYC Open Data &mdash; Motor Vehicle Collisions Crashes (h9gi-nx95)](https://data.cityofnewyork.us/Public-Safety/Motor-Vehicle-Collisions-Crashes/h9gi-nx95)  
**Google Drive Submission:** [Google Drive Project Folder](https://drive.google.com/drive/folders/1CWogmGaTYUUgxe0OXdzrsjFKD3glkNm9?usp=sharing)  
**GitHub Repository:** `https://github.com/Monasree005/NYC_Road_Safety_Visual_Analytics`  

---

## 1. Project Overview & Research Identity

This repository contains the complete, reproducible RStudio project developed for the university assessment in **CSI3005 — Advanced Data Visualization**. Investigating **2,269,187 reported traffic collisions** from the **NYPD Motor Vehicle Collisions database (July 2012 to June 2026)** via NYC Open Data, this project moves deliberately *beyond simplistic crash counts* to evaluate spatiotemporal density, diurnal rhythms, vulnerable road user lethality, and behavioral risk factors.

### Core Objectives
1. **Identify Spatial Hotspots**: Model geographic collision density across 2.02M verified coordinates using 2D hexagonal spatial binning to resolve visual overplotting.
2. **Decompose Longitudinal Trends**: Analyze 14 years of monthly collision volume and injury rates, identifying structural shifts around Vision Zero (2014) and COVID-19 (2020).
3. **Map Diurnal Rhythms**: Characterize weekly and hourly commuter peaks vs. high-severity late-night weekend risk windows using a 7×24 matrix heat map.
4. **Compare Borough Dynamics**: Contrast cumulative crash volume with injury propensity across all five administrative boroughs over complete calendar years (2013–2025).
5. **Evaluate Road User Vulnerability**: Measure casualty disparities between vehicle occupants and Vulnerable Road Users (pedestrians and cyclists).
6. **Profile Behavioral Lethality**: Analyze associations between reported contributing factors and injury/fatality rates.
7. **Audit Data Governance Gaps**: Quantify missingness in administrative borough tags vs. valid GPS coordinates.

---

## 2. Directory Structure

```text
NYC_Road_Safety_Visual_Analytics/
├── NYC_Road_Safety_Visual_Analytics.Rproj   # Primary RStudio Project Configuration
├── README.md                                # Comprehensive Project & Assessment Documentation
├── run_pipeline.R                           # Single-Command Master Pipeline Orchestrator
├── renv.lock                                # Dependency & Version Lock File (JSON Manifest)
├── .gitignore                               # Git Exclusion Rules (Protects Large Raw Data)
├── config/
│   └── project_config.R                     # Central Path, Bounding Box, & Theme Configuration
├── data/
│   ├── raw/
│   │   └── export.csv                       # Immutable Raw NYPD CSV Dataset (567.2 MB, 2.27M rows)
│   ├── processed/
│   │   ├── crashes_cleaned.rds              # Compact Cleaned Analytical Dataset (2.27M rows)
│   │   ├── spatial_crashes_valid.rds        # Valid Geocoded Coordinates (2,020,640 records)
│   │   ├── crashes_spatial_sample.rds       # Representative Spatial Sample (100k records, seed=3005)
│   │   ├── temporal_monthly_aggregate.rds   # Monthly Longitudinal Aggregate (168 months)
│   │   ├── temporal_weekday_hour_aggregate.rds # 7x24 Diurnal Aggregate Matrix
│   │   ├── borough_annual_summary.rds       # Borough-Level Annual Metrics (2013-2025)
│   │   ├── contributing_factors_summary.rds # Ranked Factor Severity Metrics
│   │   └── vru_summary.rds                  # Road User Casualty Breakdown
│   └── audit/
│       ├── dataset_audit_metrics.json       # Machine-Readable Provenance & Dimension Audit
│       ├── column_missingness_audit.csv     # 29-Column Detailed Missingness Audit
│       └── preprocessing_decision_log.csv   # Comprehensive Transformation Audit Log
├── R/
│   ├── 00_setup.R                           # Environment & Package Verification
│   ├── 01_import_and_profile.R              # Fast Ingestion & Machine-Readable Audit
│   ├── 02_data_quality_audit.R              # Missingness & Anomaly Visual Analytics (Fig G)
│   ├── 03_data_preprocessing.R              # Vectorized Cleaning & Feature Engineering
│   ├── 04_temporal_analysis.R               # Monthly Trends & Diurnal Heat Map (Fig B & C)
│   ├── 05_spatial_analysis.R                # Hexagonal Binning & Spatial Density (Fig A & A2)
│   ├── 06_multivariate_analysis.R           # Borough, VRU, & Risk Factors (Fig D, E, F)
│   ├── 07_visualizations.R                  # Visual Artifacts Verification & Catalog
│   ├── 08_findings_and_validation.R         # Statistical Synthesis & Compliance Audit
│   └── helpers.R                            # Custom ggplot2 Theme (theme_road_safety) & Helpers
├── reports/
│   ├── final_case_study.qmd                 # Publication-Grade Quarto Case Study Source
│   └── final_case_study.html                # Rendered Self-Contained Standalone HTML Report (4.4 MB)
├── outputs/
│   ├── figures/                             # High-Resolution Publication Visualizations (300 DPI)
│   │   ├── fig_a_spatial_hex_density.png
│   │   ├── fig_a2_spatial_severity_comparison.png
│   │   ├── fig_b_temporal_monthly_trend.png
│   │   ├── fig_c_weekday_hour_heatmap.png
│   │   ├── fig_d_borough_comparison.png
│   │   ├── fig_e_severity_vru_distribution.png
│   │   ├── fig_f_contributing_factors_risk.png
│   │   └── fig_g_data_quality_missingness.png
│   ├── tables/                              # Verified Output Summary Tables (CSV)
│   │   ├── table_01_dataset_profile.csv
│   │   ├── table_02_data_quality_anomalies.csv
│   │   ├── table_03_preprocessing_log.csv
│   │   ├── table_04_monthly_trends.csv
│   │   ├── table_05_weekday_hour_matrix.csv
│   │   ├── table_06_borough_annual_metrics.csv
│   │   ├── table_07_contributing_factors.csv
│   │   ├── table_08_temporal_findings.csv
│   │   ├── table_09_spatial_hotspots.csv
│   │   ├── table_10_vru_summary.csv
│   │   ├── table_11_contributing_factors_ranked.csv
│   │   ├── table_12_visualization_catalog.csv
│   │   └── table_13_faculty_compliance_matrix.csv
│   ├── reports/
│   │   ├── final_case_study.html            # Standalone Complete Report Deliverable
│   │   └── synthesized_findings.json        # Machine-Readable Synthesized Findings
│   └── logs/                                # Execution Logs & Diagnostic Traces
├── tests/
│   └── test_data_integrity.R                # Automated 8-Suite Unit & Regression Tests (testthat)
└── app/
    └── app.R                                # Interactive Shiny + Plotly Case Study Dashboard
```

---

## 3. How to Open and Execute in RStudio

### Step 1: Open the Project in RStudio
1. Launch **RStudio** (located at `C:\Program Files\RStudio\rstudio.exe`).
2. Navigate to **File > Open Project...**
3. Select `C:\Users\nivet\Documents\NYC_Road_Safety_Visual_Analytics\NYC_Road_Safety_Visual_Analytics.Rproj`.
4. RStudio will automatically set the working directory to the project root.

### Step 2: Run the Complete Master Pipeline
To re-run the entire pipeline from raw data to final report in a single deterministic command:

```r
source("run_pipeline.R")
```

The pipeline executes the 7 analytical modules, verifies intermediate tables, executes the automated test suite, and compiles the Quarto report.

### Step 3: Run the Automated Test Suite Individually
```r
source("tests/test_data_integrity.R")
```
*Expected Result*: All 8 test suites pass (82 test assertions evaluated with 0 failures).

### Step 4: Launch the Interactive Shiny Dashboard
```r
shiny::runApp("app")
```
*Features*: Interactive sliders for calendar years (2012–2026), borough filters, severity tier filters, linked KPI cards, Plotly interactive trend charts, diurnal heat map, spatial scatter sample (100k points), and ranked risk factor bars.

---

## 4. Principal Visualizations Catalog

| ID | File Name | Visual Encoding Technique | Analytical Question Answered |
|:---|:---|:---|:---|
| **Vis A** | `fig_a_spatial_hex_density.png` | 2D Hexagonal Binning (75 bins) with Log10 Magma Palette | **Q1**: Geographic crash concentration and arterial clustering |
| **Vis A2** | `fig_a2_spatial_severity_comparison.png` | Faceted Hexagonal Cartography (Property Damage vs Injury) | **Q1 & Q6**: Spatial contrast between CBD congestion and outer arterial speeds |
| **Vis B** | `fig_b_temporal_monthly_trend.png` | Dual-Panel Longitudinal Line Chart with Policy Annotations | **Q2**: 14-year trend decomposition, COVID-19 dip, and post-2020 severity surge |
| **Vis C** | `fig_c_weekday_hour_heatmap.png` | 7×24 Diurnal Heat Map Matrix with Empirical Peak Highlight | **Q3**: Weekly commuter peaks (Fri 16:00) vs weekend early AM risk windows |
| **Vis D** | `fig_d_borough_comparison.png` | Dual-Faceted Ranked Bar & Multi-Line Annual Trajectory | **Q4**: Cumulative borough crash counts vs longitudinal injury propensity |
| **Vis E** | `fig_e_severity_vru_distribution.png` | Grouped Bar & Vulnerability Ratio Metric Panel | **Q5 & Q6**: Asymmetric casualty risk of pedestrians (4.83× higher fatality rate) |
| **Vis F** | `fig_f_contributing_factors_risk.png` | Multivariate Dumbbell & Bubble Plot (Volume, Injury %, Deaths) | **Q6**: Lethality of Unsafe Speeding (131.04 deaths/10k) vs Inattention |
| **Vis G** | `fig_g_data_quality_missingness.png` | Ranked Horizontal Bar Completeness Audit by Variable Domain | **Q7**: Uncertainty analysis; 30.5% missing borough vs 10.6% missing coordinates |

---

## 5. Summary of Verified Empirical Findings

1. **The Post-COVID Severity Inversion**:
   - Pre-COVID Baseline (2015–2019): **18,693 crashes/month**; **19.3% injury rate**.
   - COVID Lockdown Trough (April 2020): **4,129 crashes/month (-77.9%)**.
   - Post-Lockdown Regime (2021–2025): **8,132 crashes/month**; **40.0% injury rate (+20.8 percentage points)**.
2. **Diurnal Commuter Peaks**:
   - Absolute Peak Hour: **Friday at 16:00–17:00 (26,107 crashes)**.
   - Lowest Volume Window: **Tuesday at 04:00 (2,097 crashes)**.
3. **Vulnerable Road User Disproportionate Lethality**:
   - Motor Vehicle Occupants: **540,227 injured, 1,466 killed** (**2.71 deaths per 1,000 injured**).
   - Pedestrians: **137,819 injured, 1,805 killed** (**13.10 deaths per 1,000 injured**; **4.83× higher risk**).
   - Cyclists: **67,336 injured, 294 killed** (**4.37 deaths per 1,000 injured**; **1.61× higher risk**).
4. **Behavioral Lethality Disparities**:
   - Driver Inattention: **484,012 collisions**, **27.2% injury rate**, **10.29 fatalities per 10k crashes**.
   - Unsafe Speeding: **35,562 collisions**, **43.2% injury rate**, **131.04 fatalities per 10k crashes** (**12.7× deadlier** than inattention).
   - Disregarded Traffic Control: **41,898 collisions**, **47.9% injury rate**, **73.27 fatalities per 10k crashes**.
5. **Administrative Data Quality Finding**:
   - **691,375 records (30.5%)** lack borough text.
   - **488,444 of these records possess valid NYC GPS coordinates**, recoverable via spatial boundaries.

---

## 6. Strict Faculty Compliance Matrix (20 Marks Total)

| Evaluation Component | Faculty Assessment Requirement | Implementation / Artifact Evidence | Validation Status |
|:---|:---|:---|:---:|
| **Component 1 (5 Marks)** | 1. Meaningful real-world problem and domain definition | `final_case_study.qmd` Sections 1–3; explicit unit of analysis | **PASS** |
| **Component 1 (5 Marks)** | 2. Credible open dataset selection and provenance | `R/01_import_and_profile.R`; verified 2,269,187 records (2012–2026) | **PASS** |
| **Component 1 (5 Marks)** | 3. Systematic preprocessing & transformation log | `R/03_data_preprocessing.R`; `table_03_preprocessing_log.csv` | **PASS** |
| **Component 2 (5 Marks)** | 4. Selection of advanced R visualization libraries | `R/helpers.R`; `ggplot2`, `sf`, `hexbin`, `patchwork`, `viridis` | **PASS** |
| **Component 2 (5 Marks)** | 5. Implementation of 5–7 principal visualizations | 8 distinct figures in `outputs/figures/`; `table_12_visualization_catalog.csv` | **PASS** |
| **Component 3 (5 Marks)** | 6. Professional visual encodings, scales, & legends | Viridis/Magma perceptual palettes; log10 scales; comma formatting | **PASS** |
| **Component 3 (5 Marks)** | 7. Consistent design system avoiding chartjunk | Reusable `theme_road_safety()`; minimal gridlines; no 3D distortion | **PASS** |
| **Component 4 (5 Marks)** | 8. Rigorous interpretation of every visualization | `final_case_study.qmd` Section 5 (What, Pattern, Evidence, Why, Limits) | **PASS** |
| **Component 4 (5 Marks)** | 9. Evidence-backed findings without causal overreach | `outputs/reports/synthesized_findings.json`; exposure limits stated | **PASS** |
| **Reproducibility** | 10. End-to-end reproducible code, tests, & report | `run_pipeline.R`; `renv.lock`; 8/8 test suites pass; HTML report rendered | **PASS** |

---

## 7. R Dependencies

- `R` >= 4.6.0
- `data.table` (v1.17.8)
- `ggplot2` (v3.5.2)
- `dplyr` (v1.1.4)
- `tidyr` (v1.3.1)
- `lubridate` (v1.9.5)
- `janitor` (v2.2.1)
- `scales` (v1.4.0)
- `viridis` (v0.6.5)
- `hexbin` (v1.28.6)
- `patchwork` (v1.3.2)
- `sf` (v1.1-3)
- `testthat` (v3.3.2)
- `knitr` (v1.52)
- `rmarkdown` (v2.32)
- `shiny` (v1.14.0)
- `plotly` (v4.12.1)
- `jsonlite` (v2.0.0)

All packages are locked in `renv.lock` and installable via CRAN binary repositories.
