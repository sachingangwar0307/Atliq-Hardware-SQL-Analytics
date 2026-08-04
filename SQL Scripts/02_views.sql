/******************************************************************************
===============================================================================
                        SQL ATLIQ HARDWARE ANALYTICS PROJECT
===============================================================================

File Name : 02_Views.sql
Author    : Sachin Gangwar
Database  : gdb0041
SQL Engine: MySQL 8.0

Description
-----------
This file contains all SQL Views used throughout the Atliq Hardware Analytics
Project.

Views Included
--------------
1. gross_sales
2. sales_postinv_discount
3. net_sales

View Dependency
---------------

gross_sales
      │
      ▼
sales_preinv_discount (Existing View/Table)
      │
      ▼
sales_postinv_discount
      │
      ▼
net_sales

===============================================================================
******************************************************************************/

USE gdb0041;

-- ============================================================================
-- VIEW 1 : GROSS SALES
-- ============================================================================

/*
Business Objective
------------------
This view calculates Gross Sales for every transaction.

Gross Sales = Sold Quantity × Gross Price

Output Columns
--------------
• Date
• Fiscal Year
• Customer
• Market
• Product
• Variant
• Sold Quantity
• Gross Price Per Item
• Gross Sales Amount
*/

DROP VIEW IF EXISTS gross_sales;

CREATE VIEW gross_sales AS

SELECT

    s.date,

    s.fiscal_year,

    s.customer_code,

    c.customer,

    c.market,

    s.product_code,

    p.product,

    p.variant,

    s.sold_quantity,

    g.gross_price AS gross_price_per_item,

    ROUND(
        s.sold_quantity * g.gross_price,
        2
    ) AS gross_price_total

FROM fact_sales_monthly s

JOIN dim_customer c
ON c.customer_code = s.customer_code

JOIN dim_product p
ON p.product_code = s.product_code

JOIN fact_gross_price g
ON g.product_code = s.product_code
AND g.fiscal_year = s.fiscal_year;



-- ============================================================================
-- VIEW 2 : SALES AFTER PRE-INVOICE DISCOUNT
-- ============================================================================

/*
Business Objective
------------------
Calculates Net Invoice Sales after applying Pre-Invoice Discounts.

Formula

Net Invoice Sales

=

Gross Sales

-

(Gross Sales × Pre-Invoice Discount)

*/

DROP VIEW IF EXISTS sales_postinv_discount;

CREATE VIEW sales_postinv_discount AS

SELECT

    s.date,

    s.fiscal_year,

    s.customer_code,

    s.market,

    s.product_code,

    s.product,

    s.variant,

    s.sold_quantity,

    s.gross_price_total,

    s.pre_invoice_discount_pct,

    (
        s.gross_price_total
        -
        (
            s.gross_price_total
            * s.pre_invoice_discount_pct
        )
    ) AS net_invoice_sales,

    (

        po.discounts_pct

        +

        po.other_deductions_pct

    ) AS post_invoice_discount_pct

FROM sales_preinv_discount s

JOIN fact_post_invoice_deductions po

ON po.customer_code = s.customer_code

AND po.product_code = s.product_code

AND po.date = s.date;



-- ============================================================================
-- VIEW 3 : NET SALES
-- ============================================================================

/*
Business Objective
------------------

Final business sales after all discounts.

Formula

Net Sales

=

Net Invoice Sales

×

(1 - Post Invoice Discount)

*/

DROP VIEW IF EXISTS net_sales;

CREATE VIEW net_sales AS

SELECT

    date,

    fiscal_year,

    customer_code,

    market,

    product_code,

    product,

    variant,

    sold_quantity,

    gross_price_total,

    pre_invoice_discount_pct,

    net_invoice_sales,

    post_invoice_discount_pct,

    (

        1

        -

        post_invoice_discount_pct

    )

    *

    net_invoice_sales

    AS net_sales

FROM sales_postinv_discount;



-- ============================================================================
-- SAMPLE QUERIES
-- ============================================================================

/*
View Gross Sales
*/

SELECT *
FROM gross_sales
LIMIT 20;



/*
View Net Invoice Sales
*/

SELECT *
FROM sales_postinv_discount
LIMIT 20;



/*
View Final Net Sales
*/

SELECT *
FROM net_sales
LIMIT 20;



-- ============================================================================
-- BUSINESS REPORT EXAMPLES
-- ============================================================================

/*
Example 1
----------
Top 10 Customers by Net Sales
*/

SELECT

    customer_code,

    ROUND(SUM(net_sales)/1000000,2) AS net_sales_million

FROM net_sales

GROUP BY customer_code

ORDER BY net_sales_million DESC

LIMIT 10;



/*
Example 2
----------
Top Markets by Net Sales
*/

SELECT

    market,

    ROUND(SUM(net_sales)/1000000,2) AS net_sales_million

FROM net_sales

GROUP BY market

ORDER BY net_sales_million DESC;



/*
Example 3
----------
Top Products by Net Sales
*/

SELECT

    product,

    ROUND(SUM(net_sales)/1000000,2) AS net_sales_million

FROM net_sales

GROUP BY product

ORDER BY net_sales_million DESC

LIMIT 10;



/*
Example 4
----------
Fiscal Year-wise Net Sales
*/

SELECT

    fiscal_year,

    ROUND(SUM(net_sales)/1000000,2) AS total_sales_million

FROM net_sales

GROUP BY fiscal_year

ORDER BY fiscal_year;



/*
Example 5
----------
Market-wise Gross Sales
*/

SELECT

    market,

    ROUND(SUM(gross_price_total)/1000000,2) AS gross_sales_million

FROM gross_sales

GROUP BY market

ORDER BY gross_sales_million DESC;



/******************************************************************************
End of File
******************************************************************************/