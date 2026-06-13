# Web Session Analysis

A end-to-end web analytics project built using Python, SQL Server, and Power BI.

## Project Overview

This project simulates a real-world web analytics workflow — generating raw session data with Python, cleaning and loading it into SQL Server, writing analytical queries, and building a Power BI dashboard for business insights.

## Dashboard Pages

**Overview KPIs**
- Total Users, Total Sessions, Conversion Rate, Bounce Rate
- Sessions by Traffic Source
- Sessions by Device Type
- Monthly Sessions Trend (Jan 2022 — Jan 2026)

**Engagement Analysis**
- Engagement tier breakdown (Highly / Moderately / Low Engaged)
- Average Engagement Score
- High Bounce Risk users
- Top 10 Users by Engagement Score
- Conversion Rate by Device Type

## Project Structure

```
Web-Session-Analysis/
│
├── Web_Session_Analytics.sql     # All SQL queries powering the dashboard
├── Web_Session_Cleaning.ipynb    # Python — data generation & cleaning, bulk insert to SQL Server
├── Documentation.docx            # Full SQL query documentation
└── README.md
```

## Tech Stack

| Tool | Purpose |
|------|---------|
| Python (Pandas, Jupyter) | Data generation & cleaning |
| SQL Server (SSMS) | Data storage & analysis |
| Power BI Desktop | Dashboard & visualisation |

## Database

- **Server:** Local SQL Server (`LAPTOP-7MAV35VV\SQLEXPRESS`)
- **Tables:** `customer_info`, `usage_info`
- **Rows:** ~50,000 session records

## Key SQL Techniques

- Conditional aggregation with `CASE WHEN`
- Window functions (`SUM() OVER()`) for inline percentages
- `CONVERT + DATEADD` for session duration formatting
- Dual `GROUP BY` for correct Power BI chart ordering
- `TOP 10` with `AVG` for engagement leaderboard

## Author

**Z.A. Mohammed Sharuq**  
Data Analyst | Bahrain  
[GitHub](https://github.com/SharuqZa)
