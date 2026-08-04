/******************************************************************************
===============================================================================
                     ATLIQ HARDWARE SALES ANALYTICS USING SQL
===============================================================================

File Name : 04_Business_Reports.sql
Part      : 3
Author    : Sachin Gangwar
Database  : gdb0041
SQL Engine: MySQL 8.0

Description
-----------
This section contains advanced analytical reports using
CTEs and Window Functions.

Reports Included
----------------
1. Top Products by Division
2. Top Markets by Gross Sales
3. Forecast Accuracy Report

===============================================================================
******************************************************************************/

USE gdb0041;

-- ============================================================================
-- REPORT 12 : TOP PRODUCTS BY DIVISION
-- ============================================================================

/*
Business Requirement
--------------------
Find the Top N Selling Products
within each Division based on Sold Quantity.

Business Value
--------------
• Helps identify best-performing products.
• Supports inventory optimization.
• Useful for category managers.

*/

WITH division_sales AS
(
    SELECT

        p.division,

        p.product,

        SUM(s.sold_quantity) AS total_sold_quantity

    FROM fact_sales_monthly s

    JOIN dim_product p

        ON s.product_code = p.product_code

    WHERE s.fiscal_year = 2021

    GROUP BY

        p.division,
        p.product
),

division_rank AS
(
    SELECT

        *,

        DENSE_RANK() OVER
        (
            PARTITION BY division
            ORDER BY total_sold_quantity DESC
        ) AS ranking

    FROM division_sales
)

SELECT *

FROM division_rank

WHERE ranking <= 3

ORDER BY

division,

ranking;



-- ============================================================================
-- REPORT 13 : TOP MARKETS BY GROSS SALES
-- ============================================================================

/*
Business Requirement
--------------------
Retrieve the Top Markets in every Region
based on Gross Sales.

Business Value
--------------
• Regional performance comparison.
• Helps management identify strong markets.

*/

WITH market_sales AS
(

SELECT

    c.market,

    c.region,

    ROUND(

        SUM(
            s.sold_quantity * g.gross_price
        )/1000000,

        2

    ) AS gross_sales_million

FROM fact_sales_monthly s

JOIN fact_gross_price g

ON g.product_code = s.product_code

AND g.fiscal_year = s.fiscal_year

JOIN dim_customer c

ON c.customer_code = s.customer_code

WHERE

s.fiscal_year = 2021

GROUP BY

c.market,

c.region

),

market_rank AS
(

SELECT

*,

DENSE_RANK() OVER
(
PARTITION BY region
ORDER BY gross_sales_million DESC
)

AS ranking

FROM market_sales

)

SELECT *

FROM market_rank

WHERE ranking <= 2

ORDER BY

region,

ranking;



-- ============================================================================
-- REPORT 14 : FORECAST ACCURACY REPORT
-- ============================================================================

/*
Business Requirement
--------------------
Generate Forecast Accuracy Report
for every customer.

Forecast Accuracy

=

100 - Absolute Error %

Business Value
--------------
• Measure forecast quality.
• Improve demand planning.
• Identify poor forecast performance.

*/

WITH forecast_error AS
(

SELECT

    s.customer_code,

    SUM(s.sold_quantity) AS total_sold_quantity,

    SUM(s.forecast_quantity) AS total_forecast_quantity,

    SUM(forecast_quantity-sold_quantity) AS net_error,

    SUM(ABS(forecast_quantity-sold_quantity)) AS absolute_error,

    SUM(ABS(forecast_quantity-sold_quantity))*100

    /

    SUM(forecast_quantity)

    AS absolute_error_percentage

FROM fact_act_est s

WHERE fiscal_year = 2021

GROUP BY customer_code

)

SELECT

    c.customer,

    c.market,

    f.customer_code,

    f.total_sold_quantity,

    f.total_forecast_quantity,

    f.net_error,

    f.absolute_error,

    ROUND(
        f.absolute_error_percentage,
        2
    ) AS absolute_error_percentage,

    IF
    (

        f.absolute_error_percentage > 100,

        0,

        ROUND(
            100-f.absolute_error_percentage,
            2
        )

    ) AS forecast_accuracy

FROM forecast_error f

JOIN dim_customer c

USING(customer_code)

ORDER BY forecast_accuracy DESC;



/******************************************************************************
End of Part 3
******************************************************************************/