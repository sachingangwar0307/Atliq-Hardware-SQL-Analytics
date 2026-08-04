/******************************************************************************
===============================================================================
                    SQL ATLIQ HARDWARE ANALYTICS PROJECT
===============================================================================

File Name : 03_Stored_Procedures.sql
Part      : 2
Author    : Sachin Gangwar
Database  : gdb0041
SQL Engine: MySQL 8.0

Description
-----------
This file contains business reporting stored procedures related to
Customer and Product Performance.

Stored Procedures Included
--------------------------
1. get_top_n_customer()
2. get_top_product_n_by_net_sales()
3. top_product_n_by_net_sales()

===============================================================================
******************************************************************************/

USE gdb0041;

-- ============================================================================
-- PROCEDURE 4 : GET TOP N CUSTOMERS BY NET SALES
-- ============================================================================

/*
Business Objective
------------------
Returns the Top N Customers based on Net Sales
for a given Market and Fiscal Year.

Input Parameters
----------------
1. Market
2. Fiscal Year
3. Top N

Example
-------

CALL get_top_n_customer
(
    'India',
    2021,
    5
);

*/

DROP PROCEDURE IF EXISTS get_top_n_customer;

DELIMITER $$

CREATE PROCEDURE get_top_n_customer
(
    IN in_market VARCHAR(45),
    IN in_fiscal_year YEAR,
    IN in_top_n INT
)

BEGIN

SELECT

    c.customer,

    ROUND(
        SUM(ns.net_sales)/1000000,
        2
    ) AS net_sales_million

FROM net_sales ns

JOIN dim_customer c
ON c.customer_code = ns.customer_code

WHERE

    ns.fiscal_year = in_fiscal_year
    AND ns.market = in_market

GROUP BY

    c.customer

ORDER BY

    net_sales_million DESC

LIMIT in_top_n;

END $$

DELIMITER ;



-- ============================================================================
-- PROCEDURE 5 : GET TOP N PRODUCTS BY NET SALES
-- ============================================================================

/*
Business Objective
------------------
Returns Top Selling Products
for a given Fiscal Year.

Input Parameters
----------------
Fiscal Year
Top N

Example

CALL get_top_product_n_by_net_sales
(
    2021,
    10
);

*/

DROP PROCEDURE IF EXISTS get_top_product_n_by_net_sales;

DELIMITER $$

CREATE PROCEDURE get_top_product_n_by_net_sales
(
    IN in_fiscal_year YEAR,
    IN in_top_n INT
)

BEGIN

SELECT

    product,

    ROUND(
        SUM(net_sales)/1000000,
        2
    ) AS net_sales_million

FROM net_sales

WHERE

    fiscal_year = in_fiscal_year

GROUP BY

    product

ORDER BY

    net_sales_million DESC

LIMIT in_top_n;

END $$

DELIMITER ;



-- ============================================================================
-- PROCEDURE 6 : TOP N PRODUCTS BY MARKET
-- ============================================================================

/*
Business Objective
------------------
Returns Top Selling Products
for a selected Market.

Input Parameters
----------------
Market
Fiscal Year
Top N

Example

CALL top_product_n_by_net_sales
(
    'India',
    2021,
    5
);

*/

DROP PROCEDURE IF EXISTS top_product_n_by_net_sales;

DELIMITER $$

CREATE PROCEDURE top_product_n_by_net_sales
(
    IN in_market VARCHAR(45),
    IN in_fiscal_year YEAR,
    IN in_top_n INT
)

BEGIN

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

    ns.fiscal_year = in_fiscal_year

    AND c.market = in_market

GROUP BY

    ns.product,
    c.market

ORDER BY

    net_sales_million DESC

LIMIT in_top_n;

END $$

DELIMITER ;



-- ============================================================================
-- TESTING
-- ============================================================================

/*
Top 5 Customers
*/

CALL get_top_n_customer
(
    'India',
    2021,
    5
);



/*
Top 10 Products
*/

CALL get_top_product_n_by_net_sales
(
    2021,
    10
);



/*
Top Products in India
*/

CALL top_product_n_by_net_sales
(
    'India',
    2021,
    5
);



-- ============================================================================
-- NOTES
-- ============================================================================

/*

These procedures are useful for:

✔ Executive Sales Dashboard

✔ Sales Leaderboard

✔ Customer Performance Analysis

✔ Product Performance Analysis

✔ Market-wise Sales Ranking

✔ KPI Reporting

*/


/******************************************************************************
End 
******************************************************************************/