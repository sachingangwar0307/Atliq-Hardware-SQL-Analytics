/******************************************************************************
===============================================================================
                     ATLIQ HARDWARE SALES ANALYTICS USING SQL
===============================================================================

File Name : 04_Business_Reports.sql
Part      : 1
Author    : Sachin Gangwar
Database  : gdb0041
SQL Engine: MySQL 8.0

Description
-----------
This file contains Business Reports created using SQL for the
Atliq Hardware Sales Analytics Project.

Reports Included
----------------
1. Customer Sales Report
2. Monthly Gross Sales Report
3. Yearly Gross Sales Report
4. Product Sales Report

===============================================================================
******************************************************************************/

USE gdb0041;

-- ============================================================================
-- REPORT 1 : CUSTOMER SALES REPORT
-- ============================================================================

/*
Business Requirement
--------------------
Generate customer-wise product sales report for Croma India
for Fiscal Year 2021.

Output
------
• Date
• Product
• Variant
• Sold Quantity
• Gross Price
• Gross Sales

*/

SELECT

    s.date,

    s.product_code,

    p.product,

    p.variant,

    s.sold_quantity,

    ROUND(g.gross_price,2) AS gross_price_per_item,

    ROUND(g.gross_price*s.sold_quantity,2) AS gross_price_total

FROM fact_sales_monthly s

JOIN dim_product p
ON s.product_code=p.product_code

JOIN fact_gross_price g
ON g.product_code=s.product_code
AND g.fiscal_year=GET_FISCAL_YEAR(s.date)

WHERE

customer_code='90002002'

AND GET_FISCAL_YEAR(s.date)=2021

ORDER BY s.date;



-- ============================================================================
-- REPORT 2 : MONTHLY GROSS SALES
-- ============================================================================

/*
Business Requirement
--------------------

Generate Monthly Gross Sales Report
for Croma India.

*/

SELECT

    s.date,

    ROUND(

        SUM(g.gross_price*s.sold_quantity),

        2

    ) AS gross_sales

FROM fact_sales_monthly s

JOIN fact_gross_price g

ON g.product_code=s.product_code

AND g.fiscal_year=GET_FISCAL_YEAR(s.date)

WHERE

customer_code=90002002

GROUP BY

s.date

ORDER BY

s.date;



-- ============================================================================
-- REPORT 3 : YEARLY GROSS SALES
-- ============================================================================

/*
Business Requirement
--------------------

Generate Fiscal Year wise Gross Sales.

*/

SELECT

GET_FISCAL_YEAR(date) AS fiscal_year,

ROUND(

SUM(g.gross_price*s.sold_quantity),

2

) AS yearly_gross_sales

FROM fact_sales_monthly s

JOIN fact_gross_price g

ON g.product_code=s.product_code

AND g.fiscal_year=GET_FISCAL_YEAR(s.date)

WHERE

customer_code=90002002

GROUP BY

GET_FISCAL_YEAR(date)

ORDER BY

fiscal_year;



-- ============================================================================
-- REPORT 4 : PRODUCT SALES REPORT
-- ============================================================================

/*
Business Requirement
--------------------

Generate Product Level Sales Report
for FY 2021.

Output

• Product
• Variant
• Customer
• Market
• Gross Sales
• Pre Invoice Discount

*/

SELECT

s.date,

s.product_code,

s.customer_code,

s.fiscal_year,

c.market,

p.product,

p.variant,

s.sold_quantity,

g.gross_price,

ROUND(g.gross_price*s.sold_quantity,2) AS gross_price_total,

pre.pre_invoice_discount_pct

FROM fact_sales_monthly s

JOIN dim_product p

ON s.product_code=p.product_code

JOIN dim_customer c

ON c.customer_code=s.customer_code

JOIN fact_gross_price g

ON g.product_code=s.product_code

AND g.fiscal_year=s.fiscal_year

JOIN fact_pre_invoice_deductions pre

ON pre.customer_code=s.customer_code

AND pre.fiscal_year=s.fiscal_year

WHERE

s.fiscal_year=2021

ORDER BY

gross_price_total DESC;





-- ============================================================================
-- REPORT 5 : NET INVOICE SALES
-- ============================================================================

/*
Business Requirement
--------------------

Calculate Net Invoice Sales
after applying Pre-Invoice Discount.

Formula

Net Invoice Sales

=

Gross Sales

-

Pre Invoice Discount

*/

SELECT

*,

(

gross_price_total

-

gross_price_total*pre_invoice_discount_pct

)

AS net_invoice_sales

FROM sales_preinv_discount;





-- ============================================================================
-- REPORT 6 : POST INVOICE SALES
-- ============================================================================

/*
Business Requirement
--------------------

Calculate Post Invoice Discount
and Net Invoice Sales.

*/

SELECT

*,

(1-pre_invoice_discount_pct)

*

gross_price_total

AS net_invoice_sales,

(

po.discounts_pct

+

po.other_deductions_pct

)

AS post_invoice_discount_pct

FROM sales_preinv_discount s

JOIN fact_post_invoice_deductions po

ON s.date=po.date

AND s.product_code=po.product_code

AND s.customer_code=po.customer_code;



/******************************************************************************
End of Part 1
******************************************************************************/