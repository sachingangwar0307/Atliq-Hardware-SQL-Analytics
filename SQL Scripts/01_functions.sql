/******************************************************************************
===============================================================================
                            SQL ATLIQ HARDWARE ANALYTICS PROJECT
===============================================================================

File Name : 01_Functions.sql
Author    : Sachin Gangwar
Database  : gdb0041
SQL Engine: MySQL 8.0

Description
-----------
This file contains all User Defined Functions (UDFs) used throughout the
Atliq hardware Analytics project.

Functions Included
------------------
1. get_fiscal_year()
2. get_fiscal_quarter()

These functions are used throughout reports, views, stored procedures,
and business analytics queries.

===============================================================================
******************************************************************************/

USE gdb0041;

-- ============================================================================
-- FUNCTION 1 : GET FISCAL YEAR
-- ============================================================================

/*
Purpose
-------
Returns the fiscal year for a given calendar date.

Business Logic
--------------
Company follows a fiscal year that starts in September.

Examples

Date             Fiscal Year
---------------  -----------
2019-09-01          2020
2020-01-10          2020
2020-10-15          2021

Usage
-----
SELECT get_fiscal_year('2020-09-01');
*/

DROP FUNCTION IF EXISTS get_fiscal_year;

DELIMITER $$

CREATE FUNCTION get_fiscal_year
(
    calendar_date DATE
)
RETURNS INT
DETERMINISTIC

BEGIN

    DECLARE fiscal_year INT;

    SET fiscal_year = YEAR(DATE_ADD(calendar_date, INTERVAL 4 MONTH));

    RETURN fiscal_year;

END $$

DELIMITER ;



-- ============================================================================
-- FUNCTION 2 : GET FISCAL QUARTER
-- ============================================================================

/*
Purpose
-------
Returns Fiscal Quarter based on company's financial calendar.

Fiscal Calendar

September-November  -> Q1
December-February   -> Q2
March-May           -> Q3
June-August         -> Q4

Example

SELECT get_fiscal_quarter('2020-09-15');

Output

Q1

*/

DROP FUNCTION IF EXISTS get_fiscal_quarter;

DELIMITER $$

CREATE FUNCTION get_fiscal_quarter
(
    calendar_date DATE
)
RETURNS CHAR(2)

DETERMINISTIC

BEGIN

    DECLARE month_number TINYINT;

    DECLARE fiscal_quarter CHAR(2);

    SET month_number = MONTH(calendar_date);

    CASE

        WHEN month_number IN (9,10,11)
            THEN SET fiscal_quarter = 'Q1';

        WHEN month_number IN (12,1,2)
            THEN SET fiscal_quarter = 'Q2';

        WHEN month_number IN (3,4,5)
            THEN SET fiscal_quarter = 'Q3';

        ELSE
            SET fiscal_quarter = 'Q4';

    END CASE;

    RETURN fiscal_quarter;

END $$

DELIMITER ;



-- ============================================================================
-- TESTING
-- ============================================================================

/*
These queries can be used to verify that the functions
are working correctly.
*/

SELECT
    get_fiscal_year('2019-09-01') AS fiscal_year;

SELECT
    get_fiscal_year('2020-11-15') AS fiscal_year;

SELECT
    get_fiscal_quarter('2019-09-01') AS fiscal_quarter;

SELECT
    get_fiscal_quarter('2020-01-15') AS fiscal_quarter;

SELECT
    get_fiscal_quarter('2020-05-10') AS fiscal_quarter;

SELECT
    get_fiscal_quarter('2020-08-15') AS fiscal_quarter;



-- ============================================================================
-- PRACTICAL USAGE EXAMPLES
-- ============================================================================

/*
Example 1
----------
Display Fiscal Year for Sales Records
*/

SELECT
    date,
    get_fiscal_year(date) AS fiscal_year
FROM fact_sales_monthly
LIMIT 10;



/*
Example 2
----------
Display Fiscal Quarter for Sales Records
*/

SELECT
    date,
    get_fiscal_quarter(date) AS fiscal_quarter
FROM fact_sales_monthly
LIMIT 10;



/*
Example 3
----------
Fiscal Year-wise Sales
*/

SELECT

    get_fiscal_year(date) AS fiscal_year,

    SUM(sold_quantity) AS total_quantity

FROM fact_sales_monthly

GROUP BY
    get_fiscal_year(date)

ORDER BY
    fiscal_year;



/*
Example 4
----------
Quarter-wise Sales Distribution
*/

SELECT

    get_fiscal_quarter(date) AS fiscal_quarter,

    SUM(sold_quantity) AS total_quantity

FROM fact_sales_monthly

GROUP BY
    get_fiscal_quarter(date)

ORDER BY
    fiscal_quarter;



/******************************************************************************
End of File
******************************************************************************/