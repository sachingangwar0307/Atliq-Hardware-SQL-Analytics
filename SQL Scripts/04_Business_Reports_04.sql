/******************************************************************************
===============================================================================
                     ATLIQ HARDWARE SALES ANALYTICS USING SQL
===============================================================================

File Name : 04_Business_Reports.sql
Part      : 4
Author    : Sachin Gangwar
Database  : gdb0041
SQL Engine: MySQL 8.0

Description
-----------
This section contains Forecast Accuracy Analysis, Temporary Tables,
Data Preparation, and Business Comparison Reports.

Reports Included
----------------
1. Create Actual vs Forecast Table
2. Data Cleaning
3. Forecast Accuracy Comparison (2020 vs 2021)
4. Customers with Declined Forecast Accuracy

===============================================================================
******************************************************************************/

USE gdb0041;

-- ============================================================================
-- REPORT 15 : CREATE ACTUAL VS FORECAST TABLE
-- ============================================================================

/*
Business Requirement
--------------------
Combine Actual Sales and Forecast Data into a single table
to simplify forecasting analysis.

Business Value
--------------
• Centralized reporting
• Better performance
• Easier Forecast Accuracy calculation

*/

DROP TABLE IF EXISTS fact_act_est;

CREATE TABLE fact_act_est AS

(
SELECT

    s.date,

    s.fiscal_year,

    s.product_code,

    s.customer_code,

    s.sold_quantity,

    f.forecast_quantity

FROM fact_sales_monthly s

LEFT JOIN fact_forecast_monthly f

USING(date, customer_code, product_code)

)

UNION

(

SELECT

    f.date,

    f.fiscal_year,

    f.product_code,

    f.customer_code,

    s.sold_quantity,

    f.forecast_quantity

FROM fact_forecast_monthly f

LEFT JOIN fact_sales_monthly s

USING(date, customer_code, product_code)

);



-- ============================================================================
-- REPORT 16 : DATA CLEANING
-- ============================================================================

/*
Business Requirement
--------------------
Replace NULL values with zero
before Forecast Analysis.

*/

UPDATE fact_act_est

SET sold_quantity = 0

WHERE sold_quantity IS NULL;



UPDATE fact_act_est

SET forecast_quantity = 0

WHERE forecast_quantity IS NULL;



-- ============================================================================
-- REPORT 17 : FORECAST ACCURACY (2021)
-- ============================================================================

/*
Business Requirement
--------------------
Create Temporary Table
for Forecast Accuracy of FY 2021.

*/

CREATE TEMPORARY TABLE forecast_accuracy_2021

WITH forecast_error AS
(

SELECT

customer_code,

SUM(sold_quantity) AS total_sold_quantity,

SUM(forecast_quantity) AS total_forecast_quantity,

SUM(forecast_quantity-sold_quantity) AS net_error,

SUM(ABS(forecast_quantity-sold_quantity)) AS absolute_error,

SUM(ABS(forecast_quantity-sold_quantity))*100

/

SUM(forecast_quantity)

AS absolute_error_percentage

FROM fact_act_est

WHERE fiscal_year=2021

GROUP BY customer_code

)

SELECT

c.customer,

c.market,

f.*,

IF

(

absolute_error_percentage>100,

0,

100-absolute_error_percentage

)

AS forecast_accuracy

FROM forecast_error f

JOIN dim_customer c

USING(customer_code);



-- ============================================================================
-- REPORT 18 : FORECAST ACCURACY (2020)
-- ============================================================================

CREATE TEMPORARY TABLE forecast_accuracy_2020

WITH forecast_error AS
(

SELECT

customer_code,

SUM(sold_quantity) AS total_sold_quantity,

SUM(forecast_quantity) AS total_forecast_quantity,

SUM(forecast_quantity-sold_quantity) AS net_error,

SUM(ABS(forecast_quantity-sold_quantity)) AS absolute_error,

SUM(ABS(forecast_quantity-sold_quantity))*100

/

SUM(forecast_quantity)

AS absolute_error_percentage

FROM fact_act_est

WHERE fiscal_year=2020

GROUP BY customer_code

)

SELECT

c.customer,

c.market,

f.*,

IF

(

absolute_error_percentage>100,

0,

100-absolute_error_percentage

)

AS forecast_accuracy

FROM forecast_error f

JOIN dim_customer c

USING(customer_code);



-- ============================================================================
-- REPORT 19 : CUSTOMERS WITH DECLINED FORECAST ACCURACY
-- ============================================================================

/*
Business Requirement
--------------------
Identify customers whose Forecast Accuracy
decreased from FY2020 to FY2021.

Business Value
--------------
• Improve demand planning
• Focus on high-risk customers
• Reduce forecast error

*/

SELECT

f20.customer_code,

f20.customer,

f20.market,

ROUND(f20.forecast_accuracy,2) AS forecast_accuracy_2020,

ROUND(f21.forecast_accuracy,2) AS forecast_accuracy_2021,

ROUND(

f20.forecast_accuracy-

f21.forecast_accuracy,

2

) AS accuracy_drop

FROM forecast_accuracy_2020 f20

JOIN forecast_accuracy_2021 f21

ON f20.customer_code=f21.customer_code

WHERE

f21.forecast_accuracy<f20.forecast_accuracy

ORDER BY accuracy_drop DESC;



-- ============================================================================
-- REPORT 20 : BUSINESS INSIGHT
-- ============================================================================

/*

Key Insights Generated

✔ Monthly Gross Sales

✔ Fiscal Year Sales

✔ Product Performance

✔ Customer Performance

✔ Market Performance

✔ Regional Contribution

✔ Forecast Accuracy

✔ Forecast Error

✔ Top Products

✔ Top Markets

✔ Customer Contribution

✔ Product Ranking

✔ Executive Dashboard Ready Reports

*/



/******************************************************************************
===============================================================================

                 END OF BUSINESS REPORTS

Project Name :
ATLIQ HARDWARE SALES ANALYTICS USING SQL

Author :
Sachin Gangwar

SQL Concepts Demonstrated

✔ Joins

✔ Aggregate Functions

✔ CASE

✔ CTE

✔ Window Functions

✔ Views

✔ Stored Procedures

✔ User Defined Functions

✔ Temporary Tables

✔ Ranking

✔ Forecast Analytics

✔ Business Reporting

✔ Data Cleaning

✔ Sales Analytics

===============================================================================
******************************************************************************/