/******************************************************************************
===============================================================================
                    SQL ATLIQ HARDWARE ANALYTICS PROJECT
===============================================================================

File Name : 03_Stored_Procedures.sql
Part      : 1
Author    : Sachin Gangwar
Database  : gdb0041
SQL Engine: MySQL 8.0

Description
-----------
This file contains stored procedures developed for Atli Hardware Analytics.
These procedures automate common business reports and improve query
reusability.

Stored Procedures Included
--------------------------
1. get_monthly_gross_sales_for_customer()
2. gross_total_by_s_code()
3. get_top_n_market_by_net_sales()

===============================================================================
******************************************************************************/

USE gdb0041;

-- ============================================================================
-- PROCEDURE 1 : GET MONTHLY GROSS SALES FOR CUSTOMER
-- ============================================================================

/*
Business Objective
------------------
Generate Monthly Gross Sales for one or multiple customers.

Features
--------
✔ Accepts multiple customer codes
✔ Calculates monthly gross sales
✔ Useful for dashboard reporting

Input
-----
Customer Code(s)

Example
-------
CALL get_monthly_gross_sales_for_customer('90002002');

CALL get_monthly_gross_sales_for_customer('90002002,90002005');

*/

DROP PROCEDURE IF EXISTS get_monthly_gross_sales_for_customer;

DELIMITER $$

CREATE PROCEDURE get_monthly_gross_sales_for_customer
(
    IN in_customer_code TEXT
)

BEGIN

SELECT

    s.date,

    ROUND(
        SUM(g.gross_price * s.sold_quantity),
        2
    ) AS gross_price_total

FROM fact_sales_monthly s

JOIN fact_gross_price g

ON g.product_code = s.product_code

AND g.fiscal_year = GET_FISCAL_YEAR(s.date)

WHERE FIND_IN_SET
(
    s.customer_code,
    in_customer_code
) > 0

GROUP BY
    s.date

ORDER BY
    s.date;

END $$

DELIMITER ;



-- ============================================================================
-- PROCEDURE 2 : GROSS SALES REPORT USING CUSTOMER CODE
-- ============================================================================

/*
Business Objective
------------------
Generate Gross Sales Report for a specific customer.

Input
-----
Customer Code

Output
------
Monthly Gross Sales

Example
-------

CALL gross_total_by_s_code(90002002);

*/

DROP PROCEDURE IF EXISTS gross_total_by_s_code;

DELIMITER $$

CREATE PROCEDURE gross_total_by_s_code
(
    IN c_code INT
)

BEGIN

SELECT

    s.date,

    ROUND(

        SUM(
            g.gross_price
            *
            s.sold_quantity
        ),

        2

    ) AS gross_price_total

FROM fact_sales_monthly s

JOIN fact_gross_price g

ON g.product_code = s.product_code

AND g.fiscal_year = GET_FISCAL_YEAR(s.date)

WHERE

    s.customer_code = c_code

GROUP BY

    s.date

ORDER BY

    s.date;

END $$

DELIMITER ;



-- ============================================================================
-- PROCEDURE 3 : TOP N MARKETS BY NET SALES
-- ============================================================================

/*
Business Objective
------------------
Returns the Top N Markets based on Net Sales.

Input Parameters
----------------
Fiscal Year
Top N

Example
-------

CALL get_top_n_market_by_net_sales
(
    2021,
    5
);

Expected Output
---------------

Market

Net Sales (Million)

*/

DROP PROCEDURE IF EXISTS get_top_n_market_by_net_sales;

DELIMITER $$

CREATE PROCEDURE get_top_n_market_by_net_sales
(

    IN in_fiscal_year YEAR,

    IN in_top_n INT

)

BEGIN

SELECT

    market,

    ROUND(

        SUM(net_sales) / 1000000,

        2

    ) AS net_sales_million

FROM net_sales

WHERE

    fiscal_year = in_fiscal_year

GROUP BY

    market

ORDER BY

    net_sales_million DESC

LIMIT

    in_top_n;

END $$

DELIMITER ;



-- ============================================================================
-- TESTING SECTION
-- ============================================================================

/*
Monthly Gross Sales
*/

CALL get_monthly_gross_sales_for_customer('90002002');


/*
Gross Sales by Customer Code
*/

CALL gross_total_by_s_code(90002002);


/*
Top 5 Markets
*/

CALL get_top_n_market_by_net_sales
(
    2021,
    5
);



-- ============================================================================
-- NOTES
-- ============================================================================

/*

Why Stored Procedures?

✔ Better Performance

✔ Code Reusability

✔ Easier Maintenance

✔ Secure Business Logic

✔ Cleaner Dashboard Integration

*/


/******************************************************************************
End
******************************************************************************/