
SBA National Loan Default Risk & Portfolio Analysis
​

Executive Summary This project is an interactive Power BI dashboard built to support small-business loan underwriting and portfolio risk decisions using the U.S. Small Business Administration's national loan-level dataset. It answers the questions a credit risk team actually asks day to day: which industries carry the highest default risk, where is loan volume geographically concentrated, and how would portfolio exposure change under different risk tolerance assumptions.
​

The dashboard is built for two audiences at once. For an underwriter, it surfaces sector-level and geographic risk patterns that inform individual lending decisions. For an executive or portfolio manager, it provides a high-level health check of the loan book with a live, adjustable risk tolerance control rather than a fixed, static snapshot.
​

📊 Data Source
​

Dataset Name: Should This Loan be Approved or Denied?
​

(U.S. Small Business Administration)
​

Platform: Kaggle
​

https://www.kaggle.com/datasets/mirbektoktogaraev/should-this-loan-be-approved-or-denied
​

Why This Dataset
​

Most beginner-to-intermediate analytics portfolios reach for consumer credit card or personal loan data, which tends to be narrow: a handful of demographic fields and a single binary outcome. The SBA national loan dataset was chosen deliberately instead, because it reflects the actual complexity a real underwriting or credit risk analyst works with.
​

This dataset combines guarantee percentage structures (how much of a loan the government backs versus the originating bank), industry classification through NAICS sector codes, disbursement and approval terms, urban versus rural business location, franchise status, and actual charge-off outcomes. That combination of structural loan terms, industry risk segmentation, and real financial outcomes is what makes this dataset a meaningfully closer analog to real-world credit risk work than a simpler binary classification dataset would be.
​

Tech Stack and Tools Used
​

Power BI Desktop was used as the primary development environment for both data modeling and report design.
​

Power Query (M) handled all data cleaning and shaping, including currency-column formatting, resolving inconsistent missing-value representations, and building the NAICS sector and state-name lookup tables.
​

DAX (Data Analysis Expressions) was used to design every measure in the model, including the dynamic Risk Tolerance parameter logic described below.
​

Star Schema data modeling principles were followed to keep the model performant and easy to extend, separating the transactional fact data from descriptive lookup dimensions.
​

UI/UX design principles were applied throughout the report layer, including a coordinated color palette, consistent KPI card treatment, and a two-page information hierarchy designed around how an underwriter would actually want to consume this data.
​

Data Architecture and Modeling
​

The model follows a Star Schema structure rather than a single flat table, which keeps the model both easier to maintain and faster to query as it grows.
​

Fact table: SBAnational. This is the loan-level transactional table, containing one row per loan with fields covering approval and disbursement amounts, loan terms, business characteristics, and the final loan status (Paid in Full versus Charged Off).
​

Dimension: NAICS Sectors. A compact lookup table mapping the numeric NAICS industry codes down to readable, sector-level industry names, connected back to the fact table on a shared sector-code key. This turns an unreadable numeric axis into a genuinely usable industry breakdown.
​

Dimension: State Mapping. A lookup table translating state abbreviations into full state names, used to make slicers and the map visual more approachable for a non-technical viewer.
​

Dimension: Date. A dedicated, standalone calendar table drives all time-based filtering and any year-over-year style comparisons, rather than relying on the loan table's own approval date column directly.
​

All relationships between the dimension tables and the fact table are one-to-many, flowing in a single direction from dimension to fact. This is the standard, recommended Star Schema pattern in Power BI, and it avoids the ambiguous filter propagation issues that can appear in more tangled data models.
​

On avoiding date table bloat: Power BI automatically generates a hidden internal date table behind every date-type column unless this behavior is turned off, which silently increases model size and clutters the field list as more date columns are added. This project disables that automatic behavior in favor of the single, explicit, shared Date table described above, which is the standard best practice for keeping both lean and predictable.
​

DAX Architecture and Measure Logic The measure layer is intentionally kept small and purposeful rather than sprawling, with each measure tied directly to a specific business question.
​

Loan Volume counts total approved loans across the portfolio (acting as a volume indicator), and forms the base measure behind every volume-oriented visual.
​

Defaulted Volume isolates the subset of that volume tied to loans that ultimately charged off, giving a direct view of realized risk counts rather than just a total count.
​

Risk Exposure % expresses the relationship between defaulted loans and total loans as a percentage, the core risk metric surfaced on every KPI card and chart in the report.
​

The Risk Tolerance what-if parameter is the most technically involved piece of the model. Rather than being a static slicer, it is backed by a disconnected What-If parameter table and a supporting measure that reads the parameter's currently selected value:
​

Selected Risk Tolerance = SELECTEDVALUE('Risk Tolerance'[Risk Tolerance], 100)
​

This selected value then feeds into the core exposure measures through a filter pattern that evaluates each industry sector's own default rate independently, and only includes sectors whose risk falls within the currently selected tolerance:
​

Filtered Total Loans =
​

CALCULATE(
​

[Loan Volume],
​

FILTER(
​

VALUES('NAICS Sectors'[SectorCode]),
​

CALCULATE([Risk Exposure %], ALL(SBAnational[SBAnational[NAICS_Sector_Code]])) <= [Selected Risk Tolerance]
​
)
​
)


The practical effect: dragging the Risk Tolerance slider dynamically recalculates portfolio-level KPIs to reflect only the sectors that would fall within that chosen risk appetite, rather than simply filtering rows on a single column.
​

Dashboard Design and User Journey The report is organized into two purpose-built pages rather than one crowded canvas, reflecting how an underwriter or executive would naturally move through the analysis.
​

Portfolio Health is the landing page and functions as the executive overview. It surfaces the three headline KPI cards, a geographic map showing loan volume and risk exposure by state, state and approval-year slicers, and the live Risk Tolerance slider positioned prominently at the top of the page.
​

Sector Breakdown is the detailed drill-down page, built for a reader who wants to go deeper than the headline numbers. It contains a sortable data table listing every sector alongside its loan volume, default volume, and risk exposure percentage, paired with a bar chart ranking sectors by risk exposure.
​

Visual and color consistency is maintained across both pages through a shared teal-to-navy gradient background and a coordinated accent color palette, replacing Power BI's default theme entirely so the report reads as a single cohesive product rather than two disconnected pages.
​

KPI card styling follows a consistent visual treatment across all six cards on both pages: rounded corners, a subtle drop shadow, a solid accent fill, and a clean outline border, so every KPI reads with the same visual weight regardless of which page it appears on.
​

Interactivity runs through the entire report rather than being confined to one page: the State and Approval Year slicers filter every visual on Portfolio Health simultaneously, and the Risk Tolerance slider recalculates exposure metrics live as it moves.
​

Key Business Insights and Findings
​

Sector concentration of risk: The Real Estate (28.64%) and Finance and Insurance (28.35%) sectors carry the highest default risk exposures in the portfolio, which are significantly higher than the overall portfolio average of 17.52%. Conversely, sectors like Mining (8.48%) and Agriculture (9.02%) show the lowest risk exposure.
​

Geographic concentration: The "Risk By State" map visual highlights that loan volume is heavily concentrated in major economic regions (with California showing the largest volume bubbles), while elevated risk exposures are dispersed across various state-level pockets rather than strictly following the highest volume centers.
​

Risk tolerance sensitivity: Adjusting the Risk Tolerance slider dynamically recalibrates the portfolio view, demonstrating that tightening the risk threshold down to a stricter percentage successfully filters out higher-risk sector volumes while keeping baseline assets visible.
​

Limitations and Future Roadmap This dashboard reflects a static, historical snapshot of SBA loan data rather than a live-updating feed, so any conclusions drawn reflect the time period covered by the underlying dataset rather than current market conditions.
​

Future extensions worth pursuing include connecting to a live or periodically refreshed data source rather than a static file, layering in external macroeconomic indicators such as interest rates or regional unemployment to contextualize default trends, and extending the model to support a predictive default-risk score as a separate, dedicated project rather than folding machine learning into this BI-focused dashboard.
​

How to Use This Dashboard
​

Open the file by downloading the .pbix file from this repository and opening it directly in Power BI Desktop, which is free to install from Microsoft.
​

Start on the Portfolio Health page to get the overall picture: the three KPI cards at the top summarize total loan volume, defaulted volume, and overall risk exposure, the map below shows geographic distribution, and the State and Approval Year slicers on the right let you narrow the view to a specific region or time period.
​

Drag the Risk Tolerance slider at the top of the page to explore how portfolio exposure shifts under a stricter or looser risk appetite, and watch the KPI cards update in response.
​

Switch to the Sector Breakdown page using the page tabs at the bottom of the report to see the same portfolio broken down by industry, ranked by risk exposure in the bar chart, with full supporting detail in the table alongside it.
