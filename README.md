# 🛒 Zepto Inventory Management — End-to-End Data Analysis

![Dashboard Preview](charts/page1_overview.png)

[![Python](https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white)](https://python.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=flat-square&logo=postgresql&logoColor=white)](https://postgresql.org)
[![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=flat-square&logo=powerbi&logoColor=black)](https://powerbi.microsoft.com)
[![Scikit-Learn](https://img.shields.io/badge/Scikit--Learn-F7931E?style=flat-square&logo=scikit-learn&logoColor=white)](https://scikit-learn.org)
[![Jupyter](https://img.shields.io/badge/Jupyter-F37626?style=flat-square&logo=jupyter&logoColor=white)](https://jupyter.org)

---

## 📌 Business Problem

> **Zepto** is an Indian quick-commerce grocery startup delivering in 10 minutes.
> With 3,692 product SKUs across 14 categories, inventory stockouts directly
> hurt customer experience and revenue.
>
> **Core question:** *Which products are at risk of going out of stock, why does
> it happen, and can we predict it before it occurs?*

---

## 📊 Key Findings

| Finding | Detail |
|---|---|
| 🔴 **26.6% catalog at risk** | 450 OOS + 533 Low Stock = 983 SKUs need attention |
| 🔴 **Biscuits: worst OOS rate** | 28.5% — 2.4× above the 11.7% overall average |
| 💰 **₹41,939 revenue at risk** | Cooking Essentials + Munchies carry 29.8% of total OOS value |
| 💡 **Discounts don't cause stockouts** | OOS is supply-side failure — statistically confirmed (Mann-Whitney p<0.05) |
| 📉 **Budget products go OOS more** | OOS avg MRP ₹88 vs In-Stock avg MRP ₹161 — ₹72.90 gap (t=9.14, p<0.001) |
| 🌿 **Fruits & Veg: best stocked** | Only 4.5% OOS — most uniform category |
| 🤖 **ML model AUC: 0.855** | Random Forest predicts stockout risk per SKU |

---

## 🗂️ Project Structure

```
Zepto-Inventory-Management-Data-Analysis/
│
├── data/
│   ├── zepto_v1.xlsx              ← Raw dataset (scraped from Zepto app)
│   └── zepto_clean.csv            ← Cleaned dataset (output of Phase 1)
│
├── notebooks/
│   ├── 01_zepto_wrangling.ipynb   ← Phase 1: Data Cleaning & Feature Engineering
│   ├── 02_zepto_eda.ipynb         ← Phase 2: Exploratory Data Analysis (9 charts)
│   ├── 03_zepto_stats.ipynb       ← Phase 3: Statistical Testing (5 tests + 2 gaps)
│   ├── 04_zepto_ml.ipynb          ← Phase 4: ML Baseline (3 models)
│   └── 05_zepto_sql_automation.ipynb ← Phase 5: PostgreSQL ETL + Automation
│
├── charts/                        ← All exported chart PNGs (20 charts)
├── reports/                       ← Auto-generated procurement reports
├── sql/
│   └── zepto_analysis.sql         ← All SQL queries
├── powerbi/
│   └── zepto_dashboard.pbix       ← 3-page interactive Power BI dashboard
└── README.md
```

---

## 🔄 Analysis Pipeline

```
Raw Data (zepto_v1.xlsx)
        ↓
Phase 1: Data Wrangling       → zepto_clean.csv (3,692 rows · 13 columns)
        ↓
Phase 2: EDA                  → 9 charts · 4 key patterns identified
        ↓
Phase 3: Statistical Tests    → 5 tests · 2 business gap analyses
        ↓
Phase 4: ML Baseline          → 3 models · Random Forest AUC 0.855
        ↓
Phase 5: SQL + ETL Automation → PostgreSQL · 7 business queries · daily report
        ↓
Phase 6: Power BI Dashboard   → 3 pages · 10 DAX measures · interactive filters
```

---

## 📁 Phase Breakdown

### Phase 1 — Data Wrangling (`01_zepto_wrangling.ipynb`)

**Raw data problems found and fixed:**

| Problem | Fix |
|---|---|
| Prices stored in paise (not ₹) | Divided by 100 → ₹10 to ₹2,600 range |
| 1 row with MRP = 0 | Removed — invalid product |
| Text columns had trailing spaces | Stripped with `.str.strip()` |
| 4 products with weight = 0 | `price_per_100g` set to NaN intentionally |

**4 new columns engineered:**

| Column | Formula | Purpose |
|---|---|---|
| `discount_amount` | MRP − Selling Price | Absolute ₹ saving per product |
| `price_per_100g` | (MRP / weight) × 100 | Value comparison across pack sizes |
| `stock_status` | In Stock / Low Stock / OOS | Human-readable inventory label |
| `discount_tier` | No / Low / Mid / High | Discount grouping for analysis |

**Output:** 3,692 rows · 13 columns · `zepto_clean.csv`

---

### Phase 2 — Exploratory Data Analysis (`02_zepto_eda.ipynb`)

9 charts across 4 analysis areas:

| Chart | Key Finding |
|---|---|
| SKUs per Category | Cooking Essentials + Munchies dominate (477 each) |
| OOS Rate by Category | Biscuits 28.5% vs Fruits & Veg 4.5% — 6× gap |
| Price Distribution | Right-skewed — Mean ₹156 vs Median ₹110 |
| Avg MRP by Category | Paan Corner + Personal Care highest (₹205) |
| Discount Analysis | 78.5% products have 0–10% discount — speed not price |
| MRP vs Discount Scatter | OOS concentrated in ₹0–₹300 budget range |
| Stacked Bar | Biscuits OOS proportion dominates its bar |
| OOS Heatmap | F&V + Low Discount = 75% OOS — supply failure signal |
| Price per 100g Boxplot | Health & Hygiene highest median per gram |

---

### Phase 3 — Statistical Analysis (`03_zepto_stats.ipynb`)

**5 hypothesis tests + 2 business gap analyses:**

| Test | Method | Result | Finding |
|---|---|---|---|
| H1: MRP vs OOS status | Independent T-Test | t=9.14, p<0.001, d=0.56 | OOS products cheaper by ₹72.90 |
| H2: Discount amount vs OOS | Independent T-Test | t=4.60, p<0.001 | OOS gets ₹9.34 less discount |
| H3: Discount % vs Category | One-Way ANOVA | F=8.73, p<0.001 | Category drives discount strategy |
| H4: OOS rate vs Category | Chi-Square | χ²=89.98, p<0.001, V=0.155 | Stockouts are category-specific |
| H5: MRP vs Discount % | Pearson Correlation | r=0.171, r²=2.9% | No meaningful linear relationship |
| Gap 1 | Revenue quantification | ₹41,939 at risk | Cooking Essentials > Biscuits in ₹ |
| Gap 2 | Kruskal-Wallis (3 tiers) | H=136.07, p<0.001 | Low Stock ≠ OOS — keep binary target |

**Key insight:** Stockouts are a **supply chain problem, not a discount-driven demand problem** — statistically validated at α = 0.05.

---

### Phase 4 — ML Baseline (`04_zepto_ml.ipynb`)

**Target:** `out_of_stock` (binary: True/False)
**Class imbalance:** 87.8% In Stock vs 12.2% OOS (7.2:1) → handled with `class_weight='balanced'`

**Features used (7):**

```python
FEATURES = [
    'mrp_inr',           # Phase 3 Test 1: significant (d=0.56)
    'discount_pct',      # Phase 3 Test 2+3: significant
    'discount_amount',   # Phase 3 Test 2: significant
    'weight_gms',        # Product size proxy
    'price_per_100g',    # Value metric
    'unit_qty',          # Pack size
    'category_encoded'   # Phase 3 Test 4: χ²=89.98
]
# available_qty EXCLUDED — direct proxy for OOS (data leakage)
```

**Model comparison:**

| Model | ROC-AUC | Recall (OOS) | Notes |
|---|---|---|---|
| Dummy Classifier | 0.500 | — | Baseline: 87.8% accuracy = useless |
| Logistic Regression | ~0.72 | — | Linear baseline |
| Decision Tree | ~0.75 | — | Interpretable rules |
| **Random Forest** | **0.855** | — | **Best model — primary** |

**Business output:** Every SKU gets an OOS risk score (0–1). High-risk but currently in-stock products = procurement priority list.

---

### Phase 5 — SQL + ETL Automation (`05_zepto_sql_automation.ipynb`)

**PostgreSQL database:** `zepto_db` · table: `products` · 3,692 rows

**7 business SQL queries:**

```sql
-- Query 1: OOS rate by category (confirms EDA)
-- Query 2: Avg MRP by stock status (confirms t-test finding)
-- Query 3: Top 10 highest discount products
-- Query 4: Low stock alert (533 products, qty ≤ 2)
-- Query 5: Discount tier vs OOS rate
-- Query 6: Revenue at risk with RANK() window function
-- Query 7: Premium OOS products (MRP > ₹200) — 42 SKUs
```

**Automated ETL pipeline:**
```python
run_postgres_etl(
    data_path='../data/zepto_clean.csv',
    db_config=DB_CONFIG,
    report_dir='../reports'
)
```
Generates daily procurement report → `zepto_report_YYYY_MM_DD.txt`

---

### Phase 6 — Power BI Dashboard (`zepto_dashboard.pbix`)

**3-page interactive dashboard connected to PostgreSQL:**

| Page | Purpose | Key Visuals |
|---|---|---|
| 1 — Catalogue Overview | Health check | 4 KPI cards, Stacked bar, Donut, OOS rate bar, Revenue at risk |
| 2 — Pricing & Discounts | Pricing story | Column chart, Donut, Discount bar, Scatter plot |
| 3 — Stock Alert | Action page | At-risk table, OOS count bar, Category × Discount matrix |

**10 DAX measures written:**
```dax
Total SKUs, OOS Count, OOS Rate %, Low Stock Count,
At Risk Count, At Risk %, Avg MRP, Avg Discount %,
Avg Discount Saved, Zero Discount Items
```

---

## 🛠️ Tech Stack

| Tool | Version | Used for |
|---|---|---|
| Python | 3.12 | EDA, stats, ML, ETL |
| Pandas | 2.x | Data wrangling, transformation |
| NumPy | 1.x | Numerical operations |
| Matplotlib + Seaborn | latest | 20 charts across 4 phases |
| Scikit-learn | 1.x | ML models, evaluation metrics |
| SciPy | 1.x | T-test, ANOVA, Chi-Square, Mann-Whitney |
| PostgreSQL | 17.6 | Database, ETL pipeline |
| psycopg2 + SQLAlchemy | latest | Python-PostgreSQL connection |
| Power BI Desktop | latest | 3-page interactive dashboard |
| Jupyter Notebook | latest | All analysis notebooks |

---

## 🚀 How to Run

### 1 — Clone repo
```bash
git clone https://github.com/Su-Xmt-007/Zepto-Inventory-Management-Data-Analysis.git
cd Zepto-Inventory-Management-Data-Analysis
```

### 2 — Install dependencies
```bash
pip install pandas numpy matplotlib seaborn scikit-learn scipy psycopg2-binary sqlalchemy openpyxl
```

### 3 — Run notebooks in order
```
01_zepto_wrangling.ipynb   → generates zepto_clean.csv
02_zepto_eda.ipynb         → generates 9 chart PNGs
03_zepto_stats.ipynb       → generates 5 stat test results
04_zepto_ml.ipynb          → generates ML model + risk scores
05_zepto_sql_automation.ipynb → requires PostgreSQL running locally
```

### 4 — PostgreSQL setup (for Phase 5)
```sql
CREATE DATABASE zepto_db;
-- Then run 05_zepto_sql_automation.ipynb
-- It creates table and loads data automatically
```

### 5 — Power BI (for Phase 6)
```
Open zepto_dashboard.pbix in Power BI Desktop
Update data source to your local PostgreSQL credentials
Refresh → all 3 pages load automatically
```

---

## 📈 Dashboard Screenshots

| Page 1 — Catalogue Overview | Page 2 — Pricing & Discounts |
|---|---|
| ![Page 1](charts/page1_overview.png) | ![Page 2](charts/page2_pricing.png) |

| Page 3 — Stock Alert |
|---|
| ![Page 3](charts/page3_alert.png) |

---

## 💼 What This Project Demonstrates

| Skill | Where demonstrated |
|---|---|
| Data Cleaning | Phase 1 — paise→₹ conversion, type fixing, outlier detection |
| Feature Engineering | Phase 1 — 4 new columns with business logic |
| EDA | Phase 2 — 9 charts, distribution analysis, pattern identification |
| Statistical Testing | Phase 3 — T-Test, ANOVA, Chi-Square, Mann-Whitney, Pearson |
| Effect Size Reporting | Phase 3 — Cohen's d, Cramer's V, r² alongside p-values |
| Business Quantification | Phase 3 — ₹41,939 revenue at risk translated from % findings |
| ML (Classification) | Phase 4 — 3 models, imbalance handling, ROC-AUC evaluation |
| Data Leakage Prevention | Phase 4 — `available_qty` excluded, scaler fit on train only |
| SQL (Advanced) | Phase 5 — Window functions, IQR outlier detection in pure SQL |
| ETL Pipeline | Phase 5 — Python→PostgreSQL automated daily pipeline |
| Power BI + DAX | Phase 6 — 3-page dashboard, 10 DAX measures, conditional formatting |
| Data Storytelling | All phases — EDA → Stats → ML → Dashboard (consistent narrative) |

---

## 📋 Dataset

| Field | Detail |
|---|---|
| Source | Scraped from Zepto app (public product listings) |
| Raw rows | 3,732 |
| Clean rows | 3,692 |
| Columns (raw) | 9 |
| Columns (clean) | 13 |
| Categories | 14 |
| Time period | Single snapshot (Nov 2024) |

**Original columns:** `Category`, `name`, `mrp`, `discountPercent`, `availableQuantity`, `discountedSellingPrice`, `weightInGms`, `outOfStock`, `quantity`

---

## 👤 Author

**Subhamoy Hazra**
Aspiring Data Analyst | MCA — Vidyasagar University (83.83%)

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=flat-square&logo=linkedin)](https://linkedin.com/in/subhamoyhazra3)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?style=flat-square&logo=github)](https://github.com/Su-Xmt-007)
[![Email](https://img.shields.io/badge/Email-Contact-EA4335?style=flat-square&logo=gmail)](mailto:subhamhazramoy@gmail.com)

---

*"Stockouts aren't random — they're predictable. This project proves it."*
