import os
import subprocess
import pymupdf

base_dir = r"C:\Users\nivet\Documents\NYC_Road_Safety_Visual_Analytics"
pdf_out_path = os.path.join(base_dir, "outputs", "reports", "CSI3005_Case_Study_Presentation_CheatSheet.pdf")
html_out_path = os.path.join(base_dir, "reports", "CSI3005_Case_Study_Presentation_CheatSheet.html")

html_content = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>CSI3005 Case Study Presentation Cheat-Sheet & Viva Defense</title>
<style>
@page {
  size: A4 portrait;
  margin: 0;
}
* {
  box-sizing: border-box;
}
html, body {
  margin: 0;
  padding: 0;
  background: #F8FAFC;
  font-family: 'Segoe UI', Helvetica, Arial, sans-serif;
  color: #0F172A;
  -webkit-print-color-adjust: exact;
  print-color-adjust: exact;
}
.sheet-page {
  width: 210mm;
  height: 296mm;
  padding: 8mm 10mm;
  page-break-after: always;
  break-after: page;
  page-break-inside: avoid;
  break-inside: avoid;
  overflow: hidden;
  position: relative;
  background: #FFFFFF;
}
.sheet-page:last-child {
  page-break-after: avoid;
  break-after: avoid;
}
.page-container {
  border: 1.5px solid #0284C7;
  border-radius: 8px;
  width: 100%;
  height: 100%;
  padding: 6mm 8mm;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  overflow: hidden;
  background: #FFFFFF;
}
.top-header {
  border-bottom: 2px solid #0284C7;
  padding-bottom: 4px;
  margin-bottom: 6px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.top-header-left h1 {
  font-size: 13pt;
  font-weight: 800;
  color: #0F172A;
  margin: 0;
  letter-spacing: -0.3px;
}
.top-header-left p {
  font-size: 8pt;
  color: #475569;
  margin: 1px 0 0 0;
}
.badge-pill {
  background: #E0F2FE;
  color: #0369A1;
  font-size: 8pt;
  font-weight: bold;
  padding: 3px 8px;
  border-radius: 12px;
  border: 1px solid #BAE6FD;
}
.section-card {
  background: #F8FAFC;
  border: 1px solid #CBD5E1;
  border-radius: 6px;
  padding: 5px 8px;
  margin-bottom: 6px;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
  border-bottom: 1px dashed #CBD5E1;
  padding-bottom: 3px;
}
.card-title {
  font-size: 9.5pt;
  font-weight: 800;
  color: #0F172A;
}
.comp-badge {
  font-size: 7.2pt;
  font-weight: bold;
  padding: 2px 6px;
  border-radius: 4px;
  color: #FFF;
}
.badge-c1 { background: #1E40AF; } /* Navy */
.badge-c2 { background: #0D9488; } /* Teal */
.badge-c3 { background: #D97706; } /* Amber */
.badge-c4 { background: #DC2626; } /* Red */
.badge-demo { background: #7C3AED; } /* Purple */

.speak-box {
  background: #EFF6FF;
  border-left: 3.5px solid #2563EB;
  padding: 4px 7px;
  margin: 4px 0;
  font-size: 7.8pt;
  line-height: 1.25;
  color: #1E3A8A;
  border-radius: 0 4px 4px 0;
}
.speak-label {
  font-weight: 800;
  text-transform: uppercase;
  font-size: 7pt;
  color: #1D4ED8;
  display: flex;
  align-items: center;
  gap: 4px;
  margin-bottom: 2px;
}
ul.bullet-list {
  margin: 2px 0;
  padding-left: 15px;
  font-size: 7.6pt;
  line-height: 1.25;
  color: #334155;
}
ul.bullet-list li {
  margin-bottom: 2px;
}
.highlight {
  font-weight: 700;
  color: #0F172A;
}
.stat-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 4px;
  margin: 4px 0;
}
.stat-box {
  background: #FFFFFF;
  border: 1px solid #E2E8F0;
  border-radius: 4px;
  padding: 4px;
  text-align: center;
}
.stat-num {
  font-size: 10pt;
  font-weight: 800;
  color: #0F172A;
}
.stat-desc {
  font-size: 6.5pt;
  color: #64748B;
  text-transform: uppercase;
  font-weight: 600;
}
.footer-bar {
  border-top: 1px solid #E2E8F0;
  padding-top: 4px;
  display: flex;
  justify-content: space-between;
  font-size: 7.2pt;
  color: #64748B;
}
code {
  background: #E2E8F0;
  padding: 1px 4px;
  border-radius: 3px;
  font-family: 'Consolas', monospace;
  font-size: 7.2pt;
  color: #0F172A;
}
.qa-box {
  background: #FFFBEB;
  border: 1px solid #FDE68A;
  border-left: 3.5px solid #D97706;
  border-radius: 4px;
  padding: 4px 7px;
  margin: 3px 0;
  font-size: 7.5pt;
  line-height: 1.25;
}
.qa-q { font-weight: bold; color: #92400E; }
.qa-a { color: #78350F; margin-top: 1px; }
</style>
</head>
<body>

<!-- ========================================== PAGE 1 ========================================== -->
<div class="sheet-page">
  <div class="page-container">
    <div>
      <div class="top-header">
        <div class="top-header-left">
          <h1>CSI3005 Case Study Presentation Master Script</h1>
          <p>Student: <strong>Monasree S (23MIC0084)</strong> | Slot: E2 | Evaluation Target: <strong>20 / 20 Marks</strong></p>
        </div>
        <div class="badge-pill">Cheat-Sheet: 10-Min Viva Defense</div>
      </div>

      <!-- Quick Elevator Pitch -->
      <div class="section-card" style="border-left: 4px solid #0284C7;">
        <div class="card-header">
          <span class="card-title">⏱️ Step 0: The 30-Second Opening Hook (Say This First!)</span>
          <span class="comp-badge" style="background: #0284C7;">OPENING HOOK</span>
        </div>
        <div class="speak-box">
          <div class="speak-label">🗣️ EXACT SCRIPT TO SAY:</div>
          "Good morning Professor. My project is <strong>'Beyond Crash Counts: Spatiotemporal Visual Analytics for Urban Road Safety'</strong>. In NYC, citywide collision counts have dropped by 56%, which municipal leaders celebrated. But my visual analysis discovers a critical hidden danger: <strong>the probability of a crash causing injury or death actually DOUBLED from 19.3% to 40.0%</strong>! Today I will demonstrate how spatiotemporal visualization in R decodes where and why this severity inversion is happening."
        </div>
      </div>

      <!-- Component 1: Dataset & Preparation -->
      <div class="section-card">
        <div class="card-header">
          <span class="card-title">📁 Component 1: Dataset Selection & Data Preparation (5 Marks)</span>
          <span class="comp-badge badge-c1">5 / 5 MARKS</span>
        </div>
        
        <div class="stat-grid">
          <div class="stat-box">
            <div class="stat-num">2.27 Million</div>
            <div class="stat-desc">Raw Collisions</div>
          </div>
          <div class="stat-box">
            <div class="stat-num">14 Years</div>
            <div class="stat-desc">July 2012 – June 2026</div>
          </div>
          <div class="stat-box">
            <div class="stat-num">488,444</div>
            <div class="stat-desc">Boroughs Recovered</div>
          </div>
          <div class="stat-box">
            <div class="stat-num">13 Core</div>
            <div class="stat-desc">Standardized Factors</div>
          </div>
        </div>

        <div class="speak-box">
          <div class="speak-label">🗣️ WHAT TO SAY TO THE FACULTY:</div>
          "I used the official <strong>NYPD Motor Vehicle Collisions Public Registry</strong> from NYC Open Data (Dataset ID: <code>h9gi-nx95</code>). It has 2,269,187 real rows and 29 columns across 14 years. I implemented an 8-step data preparation pipeline in R:"
        </div>

        <ul class="bullet-list">
          <li><strong>Step 1: Schema Normalization:</strong> Cleaned all 29 column names to <code>snake_case</code> using <code>janitor</code>.</li>
          <li><strong>Step 2: Temporal Decomposition:</strong> Extracted crash year, month, hour (0–23), and weekday (Mon–Sun).</li>
          <li><strong>Step 3: Bounding-Box Filtering:</strong> Filtered to verified NYC coordinates <code>[40.48–40.93 N, -74.28 to -73.68 W]</code>, discarding 7,591 Null Island (0,0) noise points.</li>
          <li><strong>Step 4: Spatial Borough Recovery (The Highlight!):</strong> 691,375 records lacked borough names. Using point-in-polygon spatial imputation with NYC shapefiles in package <code>sf</code>, I <strong>recovered 488,444 valid geocoded crashes</strong>!</li>
          <li><strong>Step 5: Casualty Imputation:</strong> Replaced missing injuries/deaths with 0 per NYPD reporting rules.</li>
          <li><strong>Step 6: Severity Tier Factor:</strong> Created a mutually exclusive 3-level factor: <code>Fatal Crash</code>, <code>Injury Only</code>, and <code>Property Damage</code>.</li>
          <li><strong>Step 7: VRU Composite Metric:</strong> Combined pedestrian and cyclist trauma into Vulnerable Road Users (VRU).</li>
          <li><strong>Step 8: Behavioral Mapping:</strong> Vectorized 67 messy police strings into 13 standardized driver factors.</li>
        </ul>

        <div class="qa-box">
          <div class="qa-q">🎓 Killer Academic Defense Point (Methodological Safeguard):</div>
          <div class="qa-a">"Professor, I explicitly enforce an <strong>Exposure Denominator Safeguard</strong>: Raw crash counts indicate volume exposure (traffic density), not necessarily bad road geometry, because we lack vehicle miles traveled (VMT). Therefore, I analyze <em>conditional severity rates (% injury/fatal)</em>, never raw volume alone!"</div>
        </div>
      </div>
    </div>

    <div class="footer-bar">
      <span>CSI3005 Case Study Presentation Cheat-Sheet &bull; Monasree S (23MIC0084)</span>
      <span>Page 1 of 3</span>
    </div>
  </div>
</div>

<!-- ========================================== PAGE 2 ========================================== -->
<div class="sheet-page">
  <div class="page-container">
    <div>
      <div class="top-header">
        <div class="top-header-left">
          <h1>Visual Selection, Design Critique & Streaming Math</h1>
          <p>Components 2 & 3: Theory Defense, Tufte Lie Factor, and Patent Architecture</p>
        </div>
        <div class="badge-pill">Components 2 & 3 &bull; 10 Marks</div>
      </div>

      <!-- Component 2: Visualization Selection & Defense -->
      <div class="section-card">
        <div class="card-header">
          <span class="card-title">📊 Component 2: Visualization Selection & Cognitive Defense (5 Marks)</span>
          <span class="comp-badge badge-c2">5 / 5 MARKS</span>
        </div>

        <div class="speak-box">
          <div class="speak-label">🗣️ WHAT TO SAY ABOUT VISUAL TECHNIQUES:</div>
          "I defended all visual choices using <strong>Cleveland & McGill's graphical perception hierarchy</strong>, which proves humans perceive position along common scales and length with the highest cognitive accuracy, while area and color hue have higher error rates."
        </div>

        <ul class="bullet-list">
          <li><strong>Figure 1: 2D Hexagonal Spatial Binning (<code>stat_bin_hex</code> + <code>viridis magma</code>):</strong><br>
          <em>Why not scatter dots?</em> 2 million scatter points cause severe overplotting—the entire city becomes an undifferentiated black blob. Hexagons tessellate space uniformly without directional distortion, encoding collision density into continuous logarithmic color luminance. Reveals acute hotspots along <strong>Midtown Manhattan (FDR Drive), Queens Blvd, and Cross Bronx Expressway</strong>.</li>
          <li><strong>Figure 2: Dual-Panel Longitudinal Multi-Series Time Series (<code>geom_line</code> + LOESS):</strong><br>
          <em>Why dual-panel?</em> Exploys position along an aligned common scale. Top panel tracks volume (0–22,000); bottom panel tracks % injured (10%–50%). Decoupling volume from severity clearly exposes the structural break during COVID-19.</li>
          <li><strong>Core R Packages:</strong> <code>ggplot2</code>, <code>sf</code>, <code>hexbin</code>, <code>viridis</code>, <code>data.table</code>, <code>plotly</code>, <code>shiny</code>, <code>bs4Dash</code>.</li>
        </ul>
      </div>

      <!-- Component 3: Design Critique & Redesign -->
      <div class="section-card">
        <div class="card-header">
          <span class="card-title">🎨 Component 3: Design Critique, Tufte Lie Factor & Patent Diagram (5 Marks)</span>
          <span class="comp-badge badge-c3">5 / 5 MARKS</span>
        </div>

        <div class="speak-box">
          <div class="speak-label">🗣️ WHAT TO SAY ABOUT TASK 3 (CRITIQUE & REDESIGN):</div>
          "In Task 3, I critiqued an intentionally deceptive bar chart used in public-sector reporting and applied Edward Tufte's mathematical Lie Factor formula to correct it:"
        </div>

        <ul class="bullet-list">
          <li><strong>Flaw 1: Truncated Y-Axis (Lie Factor = 4.20x):</strong> The chart cut the vertical axis at 3,100 collisions instead of zero. Because bar charts encode value by bar length, this exaggerated a routine 21.0% seasonal change into an apparent 88.1% visual collapse!
          $$\text{Lie Factor} = \frac{\text{Size of effect in graphic}}{\text{Size of effect in data}} = \frac{88.1\%}{21.0\%} = 4.20$$
          A Lie Factor of 4.2x severely deceives civic leaders into declaring a false public-safety catastrophe!</li>
          <li><strong>Flaw 2: Red-Green Emotional Bias:</strong> Alternating red/green induced fear and violated WCAG 2.1 AAA accessibility for colorblind individuals (8% of males).</li>
          <li><strong>The Redesign (Figure 4):</strong> Restored a zero baseline, applied corporate slate blue (<code>#2B6CB0</code>), direct value labels, and maximized Tufte's data-ink ratio.</li>
        </ul>

        <div class="speak-box" style="background: #F0FDF4; border-left-color: #059669; color: #065F46;">
          <div class="speak-label" style="color: #047857;">🗣️ WHAT TO SAY ABOUT FIGURE 5 (PATENT-GRADE ARCHITECTURE):</div>
          "To satisfy Task 4's changed requirement for high-frequency streaming data, I designed a <strong>patent-grade 10-module closed-loop telemetry architecture</strong>. It features HTTP/2 CAD ingestion (120 events/sec), Kafka borough-partitioned ring buffers, Flink 15-minute tumbling and 24-hour sliding windows, Redis sub-5ms serving, and an automated $Z$-score anomaly trigger:
          $$Z_t = \frac{\text{Rate}_{\text{inj}}(t) - \mu_{24\text{h}}}{\sigma_{24\text{h}}} \ge 3.00 \quad (p < 0.0013)$$
          with a Poisson rate safeguard ($N \ge 15$) to prevent false alarms during sparse hours."
        </div>
      </div>
    </div>

    <div class="footer-bar">
      <span>CSI3005 Case Study Presentation Cheat-Sheet &bull; Monasree S (23MIC0084)</span>
      <span>Page 2 of 3</span>
    </div>
  </div>
</div>

<!-- ========================================== PAGE 3 ========================================== -->
<div class="sheet-page">
  <div class="page-container">
    <div>
      <div class="top-header">
        <div class="top-header-left">
          <h1>Key Findings, RStudio Code & Shiny Live Demo</h1>
          <p>Component 4 & Live Demonstration Walkthrough: The Final 20/20 Grade</p>
        </div>
        <div class="badge-pill">Component 4 & Live Demo</div>
      </div>

      <!-- Component 4: Findings & Recommendations -->
      <div class="section-card">
        <div class="card-header">
          <span class="card-title">💡 Component 4: 4 Major Findings & 4 Policy Recommendations (5 Marks)</span>
          <span class="comp-badge badge-c4">5 / 5 MARKS</span>
        </div>

        <div class="stat-grid">
          <div class="stat-box">
            <div class="stat-num">+20.8%</div>
            <div class="stat-desc">Post-COVID Injury Surge</div>
          </div>
          <div class="stat-box">
            <div class="stat-num">4.83x</div>
            <div class="stat-desc">VRU Lethality Disparity</div>
          </div>
          <div class="stat-box">
            <div class="stat-num">131.0</div>
            <div class="stat-desc">Speed Deaths / 10k Crashes</div>
          </div>
          <div class="stat-box">
            <div class="stat-num">117.9s</div>
            <div class="stat-desc">Full R Pipeline Time</div>
          </div>
        </div>

        <ul class="bullet-list">
          <li><strong>Finding 1: Post-COVID Severity Inversion:</strong> Lockdown crashed monthly volume by -77.9% (from 18.6k to 4.1k/mo). But empty roads led to speeding, causing injury probability to double from <strong>19.3% to 40.0%</strong>!</li>
          <li><strong>Finding 2: Vulnerable Road User (VRU) Disparity:</strong> Motorists suffer 2.71 deaths per 1,000 injuries, while pedestrians suffer <strong>13.10 deaths per 1,000 injuries (4.83x deadlier!)</strong>, accounting for half of all deaths (1,805).</li>
          <li><strong>Finding 3: Speed Kills:</strong> Unsafe speeding causes 131.04 deaths per 10k crashes (<strong>12.7x deadlier</strong> than inattention).</li>
          <li><strong>Finding 4: Spatial Clustering:</strong> Collisions concentrate on multi-lane arterials (Queens Blvd, Atlantic Ave).</li>
          <li><strong>4 Strategic Policies:</strong> (1) 24/7 automated radar cameras; (2) Intersection daylighting (20-ft setbacks); (3) Concrete bike lane barriers; (4) Automated spatial reverse-geocoding for open-data integrity.</li>
        </ul>
      </div>

      <!-- Live RStudio Demo Walkthrough -->
      <div class="section-card" style="border: 1.5px solid #7C3AED; background: #FAF5FF;">
        <div class="card-header">
          <span class="card-title" style="color: #6D28D9;">💻 Live RStudio & Shiny Demo: Exact Cues to Show the Faculty</span>
          <span class="comp-badge badge-demo">LIVE DEMO GUIDE</span>
        </div>

        <div class="speak-box" style="background: #FFFFFF; border-left-color: #7C3AED; color: #5B21B6;">
          <div class="speak-label" style="color: #6D28D9;">🖥️ STEP 1: RUN THE PIPELINE IN RSTUDIO CONSOLE</div>
          Type: <code>source("run_pipeline.R")</code><br>
          <em>Say to faculty:</em> "Professor, notice the console: using <code>data.table</code>, it ingests all 2.27 million rows in just <strong>5.45 seconds</strong>. It executes all 7 pipeline steps, evaluates <strong>8 automated unit test suites with 42 passing assertions</strong>, and completes the entire end-to-end run in <strong>117.9 seconds</strong>."
        </div>

        <div class="speak-box" style="background: #FFFFFF; border-left-color: #7C3AED; color: #5B21B6;">
          <div class="speak-label" style="color: #6D28D9;">🚀 STEP 2: LAUNCH THE SHINY DASHBOARD</div>
          Type: <code>shiny::runApp("app")</code> &rarr; It opens on <code>http://127.0.0.1:6176</code>.<br>
          <em>Point your mouse and explain each plot:</em>
          <ul style="margin: 2px 0; padding-left: 12px; font-size: 7.2pt;">
            <li><strong>1. Top KPI Ribbon:</strong> 2,269,187 Total Crashes | 756k Injured | 3,617 Killed | 24.62% Injury Rate | 58.0% VRU Share.</li>
            <li><strong>2. Top-Left Plot (Monthly Volume):</strong> "Point at March 2020: clearly see the sharp COVID drop and post-lockdown plateau."</li>
            <li><strong>3. Top-Right Plot (7x24 Diurnal Heatmap):</strong> "Hover over Friday 16:00–17:00 (peak 26k volume); contrast with Sunday 3 AM (low volume, peak fatal crash rate)."</li>
            <li><strong>4. Bottom-Left Plot (Borough Trends):</strong> "Shows annual crash trajectories across all 5 boroughs from 2013 to 2025."</li>
            <li><strong>5. Bottom-Right Plot (Factor Dumbbells):</strong> "Compares volume vs fatality rate: Driver Inattention is high volume but low lethality; Unsafe Speeding is extreme lethality (131 deaths/10k)."</li>
            <li><strong>6. Interactivity Demo:</strong> "Slide the year slider to '2020–2024' or select 'Brooklyn' from the dropdown: all plots and KPIs instantly re-render in sub-second time via reactive expressions!"</li>
          </ul>
        </div>

        <!-- Quick Viva Q&A -->
        <div class="qa-box" style="margin-top: 3px;">
          <div class="qa-q">⚡ Expected Faculty Questions & 1-Sentence Winning Answers:</div>
          <div class="qa-a">
            <strong>Q1: Why did injury rates double after COVID?</strong><br>
            <em>Answer:</em> "Lower traffic congestion allowed higher vehicle operating speeds, increasing kinetic energy on impact."<br>
            <strong>Q2: Why use hexagonal bins instead of a heat map or scatter plot?</strong><br>
            <em>Answer:</em> "Scatter plots suffer from severe overplotting with 2M points; hexagons avoid directional bias and tessellate uniformly with minimal perimeter-to-area distortion."
          </div>
        </div>
      </div>
    </div>

    <div class="footer-bar">
      <span>CSI3005 Case Study Presentation Cheat-Sheet &bull; Monasree S (23MIC0084)</span>
      <span>Page 3 of 3</span>
    </div>
  </div>
</div>

</body>
</html>
"""

with open(html_out_path, "w", encoding="utf-8") as f:
    f.write(html_content)

print(f"Generated Presentation HTML: {html_out_path}")

# Compile PDF using Chrome headless
chrome_exe = r"C:\Program Files\Google\Chrome\Application\chrome.exe"
user_data = r"C:\Users\nivet\AppData\Local\Temp\chrome_pdf_tmp"
html_uri = "file:///" + html_out_path.replace("\\", "/")

cmd = [
    chrome_exe,
    "--headless=new",
    "--disable-gpu",
    "--no-pdf-header-footer",
    f"--print-to-pdf={pdf_out_path}",
    f"--user-data-dir={user_data}",
    html_uri
]

res = subprocess.run(cmd, capture_output=True, text=True)
print("Compiled Presentation PDF with Chrome:", res.stderr.strip()[:100])

doc = pymupdf.open(pdf_out_path)
print(f"Verified Presentation Cheat-Sheet PDF: {doc.page_count} pages (Target: 3 pages)")

# Sync copies
import shutil
shutil.copy2(pdf_out_path, os.path.join(base_dir, "reports", "CSI3005_Case_Study_Presentation_CheatSheet.pdf"))
shutil.copy2(pdf_out_path, os.path.join(base_dir, "outputs", "drive_submission_package", "01_Report_PDF", "CSI3005_Case_Study_Presentation_CheatSheet.pdf"))
print("Synchronized Cheat-Sheet copies to reports/ and outputs/drive_submission_package/01_Report_PDF/")
