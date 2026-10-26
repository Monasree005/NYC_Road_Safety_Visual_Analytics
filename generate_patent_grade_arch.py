import matplotlib.pyplot as plt
import matplotlib.patches as patches
import os

fig, ax = plt.subplots(figsize=(16, 12.0), dpi=300)
fig.patch.set_facecolor('#FFFFFF')
ax.set_facecolor('#FFFFFF')
ax.set_xlim(0, 16.0)
ax.set_ylim(0, 12.0)
ax.axis('off')

# Titles at top
ax.text(8.0, 11.60, 'SYSTEM ARCHITECTURE: CITYVISION STREAMING ROAD-SAFETY TELEMETRY FRAMEWORK',
        fontsize=14.5, fontweight='bold', ha='center', va='center', color='#000000', fontfamily='sans-serif')
ax.text(8.0, 11.28, 'Patent-Grade Closed-Loop Architecture for High-Frequency Spatial Ingestion, Real-Time Anomaly Scoring & Dispatch Escalation',
        fontsize=10.5, fontstyle='italic', ha='center', va='center', color='#333333', fontfamily='sans-serif')

def draw_module(ax, x, y, w, h, border_color, mod_title, mod_sub, bullets):
    # Main box
    box = patches.FancyBboxPatch((x, y), w, h, boxstyle='round,pad=0.03,rounding_size=0.10',
                                facecolor='#FFFFFF', edgecolor=border_color, linewidth=2.0, zorder=2)
    ax.add_patch(box)
    
    # Title & Subtitle
    ax.text(x + w/2, y + h - 0.28, mod_title, fontsize=10.2, fontweight='bold', ha='center', va='center',
            color='#000000', fontfamily='sans-serif', zorder=3)
    ax.text(x + w/2, y + h - 0.52, mod_sub, fontsize=8.6, fontstyle='italic', ha='center', va='center',
            color='#1F2937', fontfamily='sans-serif', zorder=3)
    
    # Header underline
    ax.plot([x + 0.25, x + w - 0.25], [y + h - 0.68, y + h - 0.68], color=border_color, linewidth=1.0, zorder=3)
    
    # Bullets
    b_y = y + h - 0.92
    for b in bullets:
        ax.text(x + 0.16, b_y, b, fontsize=8.0, ha='left', va='center', color='#111827',
                fontfamily='sans-serif', zorder=3)
        b_y -= 0.30

def draw_wire_label(ax, x, y, text):
    bbox_props = dict(boxstyle='square,pad=0.25', facecolor='#FFFFFF', edgecolor='#1F2937', linewidth=1.0)
    ax.text(x, y, text, fontsize=7.2, fontweight='bold', ha='center', va='center',
            color='#000000', bbox=bbox_props, zorder=6, fontfamily='sans-serif')

# Row 1 Modules
draw_module(ax, 0.80, 7.80, 4.40, 2.70, '#1E3A8A',
            'Module 1: Industrial Ingress & CAD Stream',
            'NYPD 911 CAD Dispatch / IoT Sensor Stream',
            [
                '• Ingress Channels: HTTP/2 REST & WebSocket CAD Stream',
                '• 14-Year NYPD Ingestion: 2,269,187 Collision Records',
                '• Ingestion Rate: ~120 Events/sec (Peak Surge: 450/s)',
                '• Jitter & Arrival Bound: delta_t < 15 ms, Dropwizard SLA',
                '• Strict Exposure Denominator Safeguard Enforced',
                '• Pre-Ingestion CRC32 Checksum Validation'
            ])

draw_module(ax, 5.80, 7.80, 4.40, 2.70, '#1E293B',
            'Module 2: Geospatial Canonical Parser',
            'WGS84 Coordinate & Schema Normalizer',
            [
                '• Bounding Box: Lat [40.48, 40.93], Lon [-74.28, -73.68]',
                '• Null Island Filter: (0.0, 0.0) Coordinates Dropped',
                '• Spatial Recovery: 488,444 Imputed Borough Records',
                '• Parse Latency Budget: tau_parse < 0.25 ms / Record',
                '• Zero Schema Mutation Guarantee (29 Attributes)',
                '• 8-Step Preprocessing Pipeline Execution'
            ])

draw_module(ax, 10.80, 7.80, 4.40, 2.70, '#854D0E',
            'Module 3: Partitioned Ring Buffer',
            'Apache Kafka 3.4 / 5-Borough Distributed Log',
            [
                '• Partitioning Key: hash(borough) mod 5 (16 Partitions)',
                '• Durability: At-Least-Once, 3-Way Replicated WAL',
                '• Retention Window: 7-Day Persistent Distributed Commit Log',
                '• Write Ingest SLA: latency_write < 12 ms (p99 SLA)',
                '• Backpressure Throttling: Reactive Pause / Resume',
                '• Buffer Capacity: 10,000+ Events/min Scalability'
            ])

# Row 2 Modules
draw_module(ax, 0.80, 4.40, 4.40, 2.70, '#7E22CE',
            'Module 6: Macro-Trend Extractor',
            'Longitudinal STL Decomposition & LOESS',
            [
                '• Macro State: S_t = STL_Decomp(Crashes_Monthly)',
                '• COVID Structural Break: -77.9% Volume Shock (4,129/mo)',
                '• Post-Lockdown Baseline: mu_base = 8,132 Crashes/mo',
                '• Decouples Long-Term Drift from Short-Term Noise',
                '• Zero Prior Distribution Assumptions Required',
                '• Structural Inflexion Triggering & Policy Tagging'
            ])

draw_module(ax, 5.80, 4.40, 4.40, 2.70, '#047857',
            'Module 5: Multi-Scale Windowing Engine',
            'Apache Flink 1.17 Stateful Stream Operator',
            [
                '• Tumbling Aggregator: W_tumble = 15 min (Fixed Epoch)',
                '• Sliding Macro Window: W_slide = 24 hr, Step delta_t = 5 min',
                '• State Backend: RocksDB Incremental Checkpointing',
                '• Watermarking: Bounded-Out-Of-Order (Lag <= 30 s)',
                '• Overlaid 1-Hour Rolling Average State Vector',
                '• Rolling Exponential Decay (Zero Boundary Artifacts)'
            ])

draw_module(ax, 10.80, 4.40, 4.40, 2.70, '#0F766E',
            'Module 4: Hexagonal Spatial Tessellator',
            'H3 Hierarchical Spatial Indexer (Resolution 8)',
            [
                '• Hex Cell Diameter: d = 460 m (Uniform NYC Tessellation)',
                '• Real-Time Spatial Binning: (Lat, Lon) -> H3_Cell_Index',
                '• Crash Density Accumulator: C_hex(t) = sum(I(crash in hex))',
                '• Log10 Scaling Engine: S_hex = log10(C_hex + 1)',
                '• Resolves 2.02M Point Overplotting to Zero Smear',
                '• Isolate Expressways: FDR, Queens Blvd, Cross Bronx'
            ])

# Row 3 Modules
draw_module(ax, 0.60, 1.05, 3.45, 2.75, '#1E40AF',
            'Module 7: Severity Classifier',
            'Conditional Lethality Stratifier',
            [
                '• 3-Tier Classification: Fatal, Inj, PDO',
                '• VRU Counter: Pedestrians + Cyclists',
                '• Severity Rate: (Inj + Kill) / N_crashes',
                '• Post-COVID Severity Surge: 19.3% -> 40.0%',
                '• VRU 4.83x Lethality Disparity Tracking',
                '• Speeding Lethality Metric: 131.04/10k'
            ])

draw_module(ax, 4.35, 1.05, 3.45, 2.75, '#991B1B',
            'Module 8: Anomaly Engine',
            'Adaptive CUSUM & Z-Score Trigger',
            [
                '• Z-Score Metric: Z_t = (Rate - mu) / sigma',
                '• Alert Threshold: Z_t >= 3.00 (p < 0.0013)',
                '• Poisson Safeguard: Alert iff N >= 15',
                '• Consecutive Breach Rule: k = 2 Buckets',
                '• Dynamic Hysteresis Band: [0.35, 0.70]',
                '• Rapid Capture of High-Speed Crashes'
            ])

draw_module(ax, 8.10, 1.05, 3.45, 2.75, '#854D0E',
            'Module 9: In-Memory OLAP',
            'Redis Cache & ClickHouse Store',
            [
                '• Hot Tier (Redis): Sub-5ms Key-Value',
                '• Warm Tier (ClickHouse): Vectorized OLAP',
                '• Read Latency: < 8 ms p99 Query SLA',
                '• TTL Policy: 24-Hour Rolling Eviction',
                '• Pre-Aggregated 7x24 Diurnal Matrices',
                '• Hex Density Key-Value Lookups'
            ])

draw_module(ax, 11.85, 1.05, 3.55, 2.75, '#166534',
            'Module 10: Command Dispatch',
            'R Shiny WebGL & CAD Escalation',
            [
                '• WebGL Scatter: 100k-Point GPU Render',
                '• 5-KPI Ribbon: Volume, Inj, Kill, Rate, VRU',
                '• Dynamic Webhook to NYPD / EMS CAD',
                '• Variable Speed Limit (VSL) Feedback',
                '• Real-Time 5-Second Client Polling',
                '• Closed-Loop Post-Incident Audit Trail'
            ])

# Interconnect Lines & Wires
arrow_kw = dict(arrowstyle='->', lw=1.8, color='#0F172A', mutation_scale=13)

# 1 -> 2
ax.annotate('', xy=(5.80, 9.15), xytext=(5.20, 9.15), arrowprops=arrow_kw, zorder=5)
draw_wire_label(ax, 5.50, 9.15, 'Raw CAD Feed')

# 2 -> 3
ax.annotate('', xy=(10.80, 9.15), xytext=(10.20, 9.15), arrowprops=arrow_kw, zorder=5)
draw_wire_label(ax, 10.50, 9.15, 'Validated Events')

# 1 -> 6 (Down)
ax.plot([3.00, 3.00], [7.80, 7.10], color='#0F172A', lw=1.8, zorder=5)
ax.annotate('', xy=(3.00, 7.10), xytext=(3.00, 7.80), arrowprops=arrow_kw, zorder=5)
draw_wire_label(ax, 3.00, 7.45, 'Longitudinal Data')

# 2 -> 5 (Down)
ax.plot([8.00, 8.00], [7.80, 7.10], color='#0F172A', lw=1.8, zorder=5)
ax.annotate('', xy=(8.00, 7.10), xytext=(8.00, 7.80), arrowprops=arrow_kw, zorder=5)
draw_wire_label(ax, 8.00, 7.45, 'Parsed Stream (W=15m)')

# 3 -> 4 (Down)
ax.plot([13.00, 13.00], [7.80, 7.10], color='#0F172A', lw=1.8, zorder=5)
ax.annotate('', xy=(13.00, 7.10), xytext=(13.00, 7.80), arrowprops=arrow_kw, zorder=5)
draw_wire_label(ax, 13.00, 7.45, 'Kafka Partition Stream')

# 6 -> 7 (Down)
ax.plot([2.30, 2.30], [4.40, 3.80], color='#0F172A', lw=1.8, zorder=5)
ax.annotate('', xy=(2.30, 3.80), xytext=(2.30, 4.40), arrowprops=arrow_kw, zorder=5)
draw_wire_label(ax, 2.30, 4.10, 'Baseline Drift')

# 5 -> 7 (Down-Left)
ax.plot([7.00, 7.00, 3.20, 3.20], [4.40, 4.05, 4.05, 3.80], color='#0F172A', lw=1.8, zorder=5)
ax.annotate('', xy=(3.20, 3.80), xytext=(3.20, 4.05), arrowprops=arrow_kw, zorder=5)
draw_wire_label(ax, 5.10, 4.05, '15-min Window State')

# 4 -> 8 (Down-Left)
ax.plot([12.00, 12.00, 6.10, 6.10], [4.40, 3.90, 3.90, 3.80], color='#0F172A', lw=1.8, zorder=5)
ax.annotate('', xy=(6.10, 3.80), xytext=(6.10, 3.90), arrowprops=arrow_kw, zorder=5)
draw_wire_label(ax, 9.05, 3.90, 'Hex Density Vector')

# 4 -> 9 (Down)
ax.plot([13.50, 13.50, 9.80, 9.80], [4.40, 4.25, 4.25, 3.80], color='#0F172A', lw=1.8, zorder=5)
ax.annotate('', xy=(9.80, 3.80), xytext=(9.80, 4.25), arrowprops=arrow_kw, zorder=5)
draw_wire_label(ax, 11.65, 4.25, 'Spatial Hex State')

# 7 -> 8
ax.annotate('', xy=(4.35, 2.42), xytext=(4.05, 2.42), arrowprops=arrow_kw, zorder=5)
draw_wire_label(ax, 4.20, 2.70, 'Rate_inj')

# 8 -> 9
ax.annotate('', xy=(8.10, 2.42), xytext=(7.80, 2.42), arrowprops=arrow_kw, zorder=5)
draw_wire_label(ax, 7.95, 2.70, 'Score Z_t')

# 9 -> 10
ax.annotate('', xy=(11.85, 2.42), xytext=(11.55, 2.42), arrowprops=arrow_kw, zorder=5)
draw_wire_label(ax, 11.70, 2.70, 'OLAP State')

# Bottom Closed-Loop Feedback Wire
ax.plot([13.60, 13.60, 0.35, 0.35, 0.80], [1.05, 0.45, 0.45, 9.15, 9.15], color='#0F172A', lw=1.8, zorder=5)
ax.annotate('', xy=(0.80, 9.15), xytext=(0.35, 9.15), arrowprops=arrow_kw, zorder=5)
draw_wire_label(ax, 7.00, 0.45, 'Closed-Loop Operational Feedback, Dispatch Escalation & State Update')

# Bottom Patent Caption in Serif Italic
ax.text(8.0, 0.12, 'Figure 5: Patent-Grade 10-Module Closed-Loop System Architecture for CityVision Streaming Telemetry Framework',
        fontsize=10.5, fontstyle='italic', ha='center', va='center', color='#111827', fontfamily='serif')

out_path = r'C:\Users\nivet\Documents\NYC_Road_Safety_Visual_Analytics\outputs\figures\fig_task4_streaming_architecture.png'
plt.tight_layout()
plt.savefig(out_path, dpi=300, bbox_inches='tight', pad_inches=0.1)
plt.close()

print('Successfully generated patent-grade architecture diagram to:', out_path)
