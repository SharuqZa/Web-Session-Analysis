
  --Description  : SQL queries powering the Web Analytics Power BI dashboard.
  --               Covers KPI summaries, traffic analysis, device breakdown,
  --               session trends, engagement metrics, and bounce risk profiling.


--------------------------------------------------------------------------------------------------------------------------------------------------
-- SECTION 1: OVERVIEW KPIs
-- Purpose : High-level summary metrics displayed on the Overview page
--           of the Power BI dashboard (KPI cards).
--------------------------------------------------------------------------------------------------------------------------------------------------

--|KPI Summary
-- Returns total users, total sessions, conversion rate, bounce rate,
-- average session duration (HH:MM), and average pages visited.
SELECT
    COUNT(DISTINCT c.User_ID) AS Total_Users,
    COUNT(u.Session_ID) AS Total_Sessions,
    ROUND(CAST(COUNT(CASE WHEN u.Conversion = 'Yes' THEN 1 END) * 100.0
               / COUNT(*) AS FLOAT), 2) AS Conversion_Rate,
    ROUND(CAST(COUNT(CASE WHEN u.Bounce = 'Yes' THEN 1 END) * 100.0
               / COUNT(*) AS FLOAT), 2) AS Bounce_Rate,
    CONVERT(VARCHAR(5), DATEADD(SECOND, AVG(u.Session_Duration), 0), 108) AS Avg_Session_Duration,
    ROUND(AVG(CAST(u.Pages_Visited AS FLOAT)), 2) AS Avg_Pages_Visited
FROM customer_info c
JOIN usage_info u ON c.User_ID = u.User_ID;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------


--| Sessions by Traffic Source
-- Used in a bar/column chart to compare session volume across traffic channels
-- (e.g. Organic, Paid, Direct, Referral, Social).
SELECT
    u.Traffic_Source,
    COUNT(u.Session_ID) AS Total_Sessions
FROM customer_info c
JOIN usage_info    u ON c.User_ID = u.User_ID
GROUP BY u.Traffic_Source
ORDER BY Total_Sessions DESC;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------


--| Bounce Rate by Traffic Source
-- Identifies which traffic channels have the highest bounce rates.
-- Useful for targeting underperforming acquisition channels.

SELECT
    u.Traffic_Source,
    ROUND(CAST(COUNT(CASE WHEN u.Bounce = 'Yes' THEN 1 END) * 100.0
               / COUNT(*) AS FLOAT), 2) AS Bounce_Rate
FROM customer_info c
JOIN usage_info    u ON c.User_ID = u.User_ID
GROUP BY u.Traffic_Source
ORDER BY Bounce_Rate DESC;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------


--| Sessions by Device Type
-- Breaks down session share (%) by device category (Desktop, Mobile, Tablet).
-- Window function used to calculate percentage without a subquery.
SELECT
    c.Device_Type,
    COUNT(u.Session_ID) AS Total_Sessions,
    ROUND(CAST(COUNT(u.Session_ID) * 100.0
               / SUM(COUNT(u.Session_ID)) OVER() AS FLOAT), 2) AS Percentage
FROM customer_info c
JOIN usage_info    u ON c.User_ID = u.User_ID
GROUP BY c.Device_Type;


--| Sessions Trend Over Time (Monthly)
-- Monthly session volume from Jan 2022 to Jan 2026.
-- Dual GROUP BY (formatted label + YEAR/MONTH integers) ensures correct
-- chronological ordering in Power BI line charts.
SELECT
    FORMAT(u.Date, 'MMM yyyy')  AS Month,
    COUNT(u.Session_ID)         AS Total_Sessions
FROM customer_info c
JOIN usage_info    u ON c.User_ID = u.User_ID
GROUP BY
    FORMAT(u.Date, 'MMM yyyy'),
    YEAR(u.Date),
    MONTH(u.Date)
ORDER BY
    YEAR(u.Date),
    MONTH(u.Date);


--------------------------------------------------------------------------------------------------------------------------------------------------------
-- SECTION 2: ENGAGEMENT ANALYSIS
-- Purpose : Metrics for the Engagement page of the Power BI dashboard.
--           Covers engagement segmentation, scoring, and conversion impact.
--------------------------------------------------------------------------------------------------------------------------------------------------------

--| Engagement KPIs
-- KPI card values: counts per engagement tier, average engagement score,
-- high bounce-risk user count, and conversion rate for highly engaged users.

SELECT
    COUNT(CASE WHEN u.Engagement_Type = 'Highly Engaged' THEN 1 END) AS Highly_Engaged_Users,
    COUNT(CASE WHEN u.Engagement_Type = 'Moderately Engaged' THEN 1 END) AS Moderately_Engaged_Users,
    COUNT(CASE WHEN u.Engagement_Type = 'Low Engaged' THEN 1 END) AS Low_Engaged_Users,
    ROUND(AVG(CAST(u.Engagement_Score AS FLOAT)), 2) AS Avg_Engagement_Score,
    COUNT(CASE WHEN u.Bounce_Risk = 'High Risk' THEN 1 END) AS High_Bounce_Risk_Users,
    ROUND(CAST(
        COUNT(CASE WHEN u.Conversion = 'Yes'
                    AND u.Engagement_Type = 'Highly Engaged' THEN 1 END) * 100.0
        / COUNT(*) AS FLOAT), 2) AS Conversion_Rate_Engaged
FROM customer_info c
JOIN usage_info u ON c.User_ID = u.User_ID;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------


--| Sessions by Engagement Type
-- Stacked bar or pie chart source — shows how sessions are distributed
-- across engagement tiers.

SELECT
    u.Engagement_Type,
    COUNT(u.Session_ID) AS Total_Sessions
FROM usage_info u
GROUP BY u.Engagement_Type
ORDER BY Total_Sessions DESC;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------


--| Conversion Rate by Device Type
-- Highlights which device type drives the most conversions.
-- Useful for device-specific UX optimisation decisions.

SELECT
    c.Device_Type,
    ROUND(CAST(COUNT(CASE WHEN u.Conversion = 'Yes' THEN 1 END) * 100.0
               / COUNT(*) AS FLOAT), 2) AS Conversion_Rate
FROM customer_info c
JOIN usage_info    u ON c.User_ID = u.User_ID
GROUP BY c.Device_Type
ORDER BY Conversion_Rate DESC;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------


--| Top 10 Users by Engagement Score
-- Leaderboard table in Power BI showing the highest-value users
-- based on their average engagement score.

SELECT TOP 10
    c.User_ID,
    c.Country,
    ROUND(AVG(CAST(u.Engagement_Score AS FLOAT)), 2) AS Engagement_Score,
    u.Engagement_Type,
    COUNT(u.Session_ID) AS Sessions
FROM customer_info c
JOIN usage_info    u ON c.User_ID = u.User_ID
GROUP BY
    c.User_ID,
    c.Country,
    u.Engagement_Type
ORDER BY Engagement_Score DESC;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------


--| High Bounce Risk Users (Detail Table)
-- Drill-through or filtered table listing all sessions flagged as High Risk.
-- Ordered by most recent date for recency-first analysis.
SELECT
    c.User_ID,
    c.Country,
    u.Traffic_Source,
    c.Device_Type,
    u.Pages_Visited,
    u.Session_Duration,
    u.Bounce_Risk,
    u.Date
FROM customer_info c
JOIN usage_info    u ON c.User_ID = u.User_ID
WHERE u.Bounce_Risk = 'High Risk'
ORDER BY u.Date DESC;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------


--| Engagement Type Distribution (with Percentage)
-- Donut/pie chart source showing proportional split across engagement tiers.
-- Window function calculates percentage inline without a subquery.

SELECT
    u.Engagement_Type,
    COUNT(*)                                                                   AS Total_Users,
    ROUND(CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS FLOAT), 2)         AS Percentage
FROM usage_info u
GROUP BY u.Engagement_Type;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------