/******************************************************************************
===============================================================================
                    ATLIQ HARDWARE SALES ANALYTICS USING SQL
===============================================================================

File Name : 03_Stored_Procedures.sql
Part      : 3
Author    : Sachin Gangwar
Database  : gdb0041
SQL Engine: MySQL 8.0

Description
-----------
This file contains advanced stored procedures developed for the
Atliq Hardware Sales Analytics Project.

These procedures automate business reporting for forecasting,
market segmentation and product performance.

Stored Procedures Included
--------------------------
1. get_top_n_product_per_division_by_qty_sold()
2. get_forecast_acc_by_fiscal_year()
3. get_market_badge()

===============================================================================
******************************************************************************/

USE gdb0041;

-- ============================================================================
-- PROCEDURE 7 : TOP N PRODUCTS PER DIVISION BY QUANTITY SOLD
-- ============================================================================

/*
Business Objective
------------------
Returns the Top N Products within each Division
based on Sold Quantity.

Business Value
--------------
• Identify best-performing products.
• Compare product performance within divisions.
• Assist inventory planning.
• Support category managers.

Input Parameters
----------------
Fiscal Year
Top N

Example

CALL get_top_n_product_per_division_by_qty_sold
(
    2021,
    3
);

*/

DROP PROCEDURE IF EXISTS get_top_n_product_per_division_by_qty_sold;

DELIMITER $$

CREATE PROCEDURE get_top_n_product_per_division_by_qty_sold
(
    IN in_fiscal_year YEAR,
    IN in_top_n INT
)

BEGIN

WITH division_sales AS
(

SELECT

    p.division,

    p.product,

    SUM(s.sold_quantity) AS total_quantity

FROM fact_sales_monthly s

JOIN dim_product p

ON p.product_code = s.product_code

WHERE

    s.fiscal_year = in_fiscal_year

GROUP BY

    p.division,
    p.product

),

ranking AS
(

SELECT

    *,

    DENSE_RANK() OVER
    (
        PARTITION BY division
        ORDER BY total_quantity DESC
    ) AS ranking

FROM division_sales

)

SELECT *

FROM ranking

WHERE ranking <= in_top_n

ORDER BY division, ranking;

END $$

DELIMITER ;



-- ============================================================================
-- PROCEDURE 8 : FORECAST ACCURACY REPORT
-- ============================================================================

/*
Business Objective
------------------

Generates Forecast Accuracy Report
for a selected Fiscal Year.

Forecast Accuracy Formula

100 - Absolute Forecast Error %

Business Value

• Demand Planning
• Forecast Improvement
• Customer Planning
• Inventory Optimization

Example

CALL get_forecast_acc_by_fiscal_year(2021);

*/

DROP PROCEDURE IF EXISTS get_forecast_acc_by_fiscal_year;

DELIMITER $$

CREATE PROCEDURE get_forecast_acc_by_fiscal_year
(
    IN p_fiscal_year INT
)

BEGIN

WITH forecast_error AS
(

SELECT

    customer_code,

    SUM(sold_quantity) AS total_sold_qty,

    SUM(forecast_quantity) AS total_forecast_qty,

    SUM(forecast_quantity-sold_quantity) AS net_error,

    SUM(ABS(forecast_quantity-sold_quantity)) AS absolute_error,

    SUM(ABS(forecast_quantity-sold_quantity))*100
    /
    SUM(forecast_quantity)

    AS absolute_error_pct

FROM fact_act_est

WHERE fiscal_year = p_fiscal_year

GROUP BY customer_code

)

SELECT

    c.customer,

    c.market,

    f.customer_code,

    f.total_sold_qty,

    f.total_forecast_qty,

    f.net_error,

    f.absolute_error,

    ROUND(f.absolute_error_pct,2) AS absolute_error_pct,

    IF
    (
        f.absolute_error_pct > 100,

        0,

        ROUND(100-f.absolute_error_pct,2)

    ) AS forecast_accuracy

FROM forecast_error f

JOIN dim_customer c

USING(customer_code)

ORDER BY forecast_accuracy DESC;

END $$

DELIMITER ;



-- ============================================================================
-- PROCEDURE 9 : MARKET BADGE
-- ============================================================================

/*
Business Objective
------------------

Classify Market Performance.

Business Rule

Gold Market
------------
Total Sold Quantity > 500,000

Silver Market
--------------
Otherwise

Example

CALL get_market_badge
(
    'India',
    2021,
    @badge
);

SELECT @badge;

*/

DROP PROCEDURE IF EXISTS get_market_badge;

DELIMITER $$

CREATE PROCEDURE get_market_badge
(

    IN in_market VARCHAR(45),

    IN in_fiscal_year YEAR,

    OUT out_badge VARCHAR(20)

)

BEGIN

DECLARE total_qty INT DEFAULT 0;

IF in_market = '' THEN

SET in_market = 'India';

END IF;

SELECT

SUM(s.sold_quantity)

INTO total_qty

FROM fact_sales_monthly s

JOIN dim_customer c

ON c.customer_code=s.customer_code

WHERE

GET_FISCAL_YEAR(s.date)=in_fiscal_year

AND c.market=in_market;

IF total_qty > 500000 THEN

SET out_badge='Gold';

ELSE

SET out_badge='Silver';

END IF;

END $$

DELIMITER ;



-- ============================================================================
-- SAMPLE EXECUTION
-- ============================================================================

CALL get_top_n_product_per_division_by_qty_sold
(
2021,
3
);

CALL get_forecast_acc_by_fiscal_year
(
2021
);

CALL get_market_badge
(
'India',
2021,
@badge
);

SELECT @badge;



-- ============================================================================
-- BUSINESS APPLICATIONS
-- ============================================================================

/*

These Stored Procedures are designed for:

✔ Executive Dashboard Reporting

✔ Sales Performance Analysis

✔ Forecast Accuracy Monitoring

✔ Inventory Planning

✔ Market Segmentation

✔ Customer Demand Analysis

✔ Product Ranking

✔ Decision Support Systems

✔ Power BI Integration

✔ Automated Business Reporting

*/



/******************************************************************************
End of File

Project:
ATLIQ HARDWARE SALES ANALYTICS USING SQL

Author:
Sachin Gangwar

******************************************************************************/