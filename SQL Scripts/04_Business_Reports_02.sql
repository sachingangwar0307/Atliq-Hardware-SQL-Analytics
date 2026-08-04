/******************************************************************************
===============================================================================
                     ATLIQ HARDWARE SALES ANALYTICS USING SQL
===============================================================================

File Name : 04_Business_Reports.sql
Part      : 2
Author    : Sachin Gangwar
Database  : gdb0041
SQL Engine: MySQL 8.0

Description
-----------
This section focuses on Net Sales Analysis and Business Performance Reports.

Reports Included
----------------
1. Top Markets by Net Sales
2. Top Customers by Net Sales
3. Top Products by Net Sales (India)
4. Customer Contribution Percentage
5. Regional Customer Contribution Percentage

===============================================================================
******************************************************************************/

USE gdb0041;

-- ============================================================================
-- REPORT 7 : TOP 5 MARKETS BY NET SALES
-- ============================================================================

/*
Business Requirement
--------------------
Identify the Top 5 Markets based on Net Sales
for a selected Fiscal Year.

Business Value
--------------
• Helps identify high-performing markets.
• Supports regional sales strategy.
*/

SELECT

    market,

    ROUND(
        SUM(net_sales)/1000000,
        2
    ) AS net_sales_million

FROM net_sales

WHERE fiscal_year = 2021

GROUP BY market

ORDER BY net_sales_million DESC

LIMIT 5;



-- ============================================================================
-- REPORT 8 : TOP 5 CUSTOMERS BY NET SALES
-- ============================================================================

/*
Business Requirement
--------------------
Find the Top 5 Customers based on Net Sales.

Business Value
--------------
• Identify key customers.
• Improve customer relationship management.
*/

SELECT

    c.customer,

    ROUND(
        SUM(ns.net_sales)/1000000,
        2
    ) AS net_sales_million

FROM net_sales ns

JOIN dim_customer c

ON c.customer_code = ns.customer_code

WHERE ns.fiscal_year = 2021

GROUP BY c.customer

ORDER BY net_sales_million DESC

LIMIT 5;



-- ============================================================================
-- REPORT 9 : TOP PRODUCTS BY NET SALES (INDIA)
-- ============================================================================

/*
Business Requirement
--------------------
Display the Top Selling Products
in the Indian Market.

Business Value
--------------
• Helps identify best-selling products.
• Supports inventory planning.
*/

SELECT

    ns.product,

    c.market,

    ROUND(
        SUM(ns.net_sales)/1000000,
        2
    ) AS net_sales_million

FROM net_sales ns

JOIN dim_customer c

ON c.customer_code = ns.customer_code

WHERE

    ns.fiscal_year = 2021

AND c.market = 'India'

GROUP BY

    ns.product,
    c.market

ORDER BY

    net_sales_million DESC

LIMIT 5;



-- ============================================================================
-- REPORT 10 : CUSTOMER CONTRIBUTION TO TOTAL NET SALES
-- ============================================================================

/*
Business Requirement
--------------------
Calculate percentage contribution of each customer
towards total Net Sales.

Business Value
--------------
• Customer profitability analysis.
• Revenue concentration.
*/

WITH customer_sales AS
(

SELECT

    c.customer,

    ROUND(
        SUM(net_sales)/1000000,
        2
    ) AS net_sales_million

FROM net_sales s

JOIN dim_customer c

ON c.customer_code = s.customer_code

WHERE fiscal_year = 2021

GROUP BY c.customer

)

SELECT

    customer,

    net_sales_million,

    ROUND(

        net_sales_million * 100

        /

        SUM(net_sales_million) OVER(),

        2

    ) AS contribution_percentage

FROM customer_sales

ORDER BY net_sales_million DESC;



-- ============================================================================
-- REPORT 11 : CUSTOMER CONTRIBUTION BY REGION
-- ============================================================================

/*
Business Requirement
--------------------
Calculate Customer Contribution
within each Region.

Business Value
--------------
• Regional customer performance.
• Sales distribution analysis.
*/

WITH regional_sales AS
(

SELECT

    c.customer,

    c.region,

    ROUND(
        SUM(net_sales)/1000000,
        2
    ) AS net_sales_million

FROM net_sales s

JOIN dim_customer c

ON c.customer_code = s.customer_code

WHERE fiscal_year = 2021

GROUP BY

    c.customer,
    c.region

)

SELECT

    customer,

    region,

    net_sales_million,

    ROUND(

        net_sales_million * 100

        /

        SUM(net_sales_million)

        OVER(PARTITION BY region),

        2

    ) AS region_share_percentage

FROM regional_sales

ORDER BY

    region,

    net_sales_million DESC;



/******************************************************************************
End of Part 2
******************************************************************************/