# bank-customer-churn-analysis
SQL analysis and Excel Dashboard of customer churn banking dataset.
SQL · Excel · pgAdmin · PostgreSQL
> *Identifying why customers leave — and what the bank can do about it.*
---
 Project overview
Customer churn is one of the most expensive problems in banking. When a customer leaves, the bank doesn't just lose their account — it loses their deposits, loan interest, transaction fees, and lifetime value.
This project analyses a dataset of 1,000 bank customers across France, Germany, Spain, and the UK to answer one core business question:
> **Who is leaving, why are they leaving, and how much is it costing the bank?**
The analysis was conducted entirely in SQL (PostgreSQL via pgAdmin), and the findings were visualised in an interactive Excel dashboard.
---
 Dashboard preview
[Bank Customer Churn Dashboard](dashboard_screenshot.png)
> Dashboard covers: Total customers · Churn rate · Money at risk · Satisfaction scores · Churn by country · Churn by age group · Top 10 high-risk customers
---
 Key findings
Metric	Finding
Total customers analysed	1,000
Overall churn rate	24.6% — 1 in 4 customers is leaving
Total money at risk	$73.4 million (deposits + loans + transaction value)
Highest churn country	France (30 churned customers in top segment)
Highest churn age group	46–55 years (25.5% churn rate)
Avg satisfaction — churned	Lower than retained customers
Churned customers with active loans	Significant — credit risk exposure confirmed
---
  Business insights
1. France is the highest churn market
France had the most churned customers across all countries, suggesting either a service quality gap, stronger local competition, or unmet product needs in that market. Recommendation: targeted retention campaigns in France.
2. Middle-aged customers (46–55) churn the most
This is a high-value demographic — typically at peak earning and saving years. Losing them is disproportionately expensive.     Recommendation: loyalty programmes and personalised relationship management for this segment.
3. $73.4 million in deposits and loans is at risk
This was calculated by combining lost deposits, outstanding loan balances, and estimated transaction value from churned customers. This figure gives leadership a concrete financial cost to attach to the churn problem.
4. Low satisfaction scores predict churn
Churned customers consistently scored lower on satisfaction surveys. This means satisfaction scores can be used as an early warning signal — customers scoring 3 or below should trigger a retention intervention before they leave.
5. Churned customers transact significantly less before leaving
Transaction frequency drops before churn occurs. This is a detectable behavioural signal that could power a churn prediction model in future.
---
 Project structure
```
bank-churn-analysis/
│
├── README.md                        ← You are here
├── banking_churn_sql_questions.sql  ← All 15 SQL queries with answers
├── churn_dashboard.xlsx             ← Excel dashboard
└── dashboard_screenshot.png        ← Dashboard preview image
```
---
🛠️ Tools used
Tool	Purpose
PostgreSQL	Database engine
pgAdmin	SQL query environment
SQL	Data extraction, joins, aggregations, CASE logic
Microsoft Excel	Dashboard, pivot tables, charts, KPI cards
---
 SQL analysis breakdown
The analysis was structured across 8 business sections, each answering a real operational question a bank analyst would face:
Section 1 — Customer overview
Established the baseline: total customer count, geographic distribution, age profile, and gender split. Used `COUNT`, `AVG`, and `GROUP BY` fundamentals.
Section 2 — Churn analysis
Calculated the overall churn rate (24.6%), identified France as the highest churn country, and broke churn down by age group using `CASE WHEN` logic to create age bands — a technique commonly used in customer segmentation.
```sql
-- Churn rate by age group (example)
SELECT
  CASE
    WHEN age BETWEEN 18 AND 25 THEN '18-25'
    WHEN age BETWEEN 26 AND 35 THEN '26-35'
    WHEN age BETWEEN 36 AND 45 THEN '36-45'
    WHEN age BETWEEN 46 AND 55 THEN '46-55'
    ELSE '56+'
  END AS age_group,
  COUNT(*) AS total_customers,
  SUM(CASE WHEN churned = 1 THEN 1 ELSE 0 END) AS churned_customers,
  ROUND(SUM(CASE WHEN churned = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM bank_customers bc
JOIN bank_churn_profile bcp ON bc.customer_id = bcp.customer_id
GROUP BY age_group
ORDER BY churn_rate_pct DESC;
```
Section 3 — Balance & financial risk
Compared average balances of churned vs retained customers and calculated total money at risk by combining lost deposits, loan balances, and transaction value. This produced the $73.4M headline figure in the dashboard.
Section 4 — Loan exposure
Identified churned customers who still hold active loans — a credit risk flag for the bank. A churned customer with an active loan is both a revenue loss and a potential default risk.
Section 5 — Satisfaction & high-risk customers
Compared satisfaction scores between churned and retained customers, confirming that low satisfaction is a churn predictor. Built a high-risk customer watchlist using multi-condition filtering (`WHERE` + `OR`) across satisfaction score, complaints, activity status, and churn flag — ordered to surface the most urgent cases first.
Section 6 — Transaction behaviour
Confirmed that churned customers transact significantly less, establishing transaction frequency as a behavioural churn signal that could be monitored in real time.
Section 7 — Product analysis
Identified which account types have the highest churn rates — informing product team decisions about which products need improvement or better retention incentives.
Section 8 — Executive report
Produced a full customer-level view ordered by balance, giving leadership a complete picture of the customer base for strategic decision-making.
---
 Database schema
Five tables linked by `customer_id`:
```
bank_customers       → demographics (age, gender, country)
bank_accounts        → balance, account type
bank_loans           → loan amount, loan status
bank_transactions    → transaction count, average value
bank_churn_profile   → churned flag, satisfaction score, complaints
```
---
To the CEO / MD:
One in four customers is leaving and taking $73.4 million with them. France is the most at-risk market. Customers aged 46–55 are the highest value segment churning. We have early warning signals — satisfaction scores and transaction drops — that could power a retention programme before customers leave.
To the Head of Retail Banking:
The data shows churn is not random. It clusters in France, in the 46–55 age group, and among customers with satisfaction scores of 3 or below. A targeted intervention on just these three segments could retain a significant share of that $73.4M.
To the Risk team:
Churned customers with active loans represent unresolved credit exposure. This cohort needs immediate follow-up from the collections and relationship management teams.
---

 About the analyst
Veronica Mueni — Data Analyst
📍 Nairobi, Kenya
🔗 LinkedIn  www.linkedin.com/in/mueni-mutua-7b15281a1
📧 mueni475@gmail.com
Open to junior data analyst roles in banking, fintech, insurance, and healthcare.
