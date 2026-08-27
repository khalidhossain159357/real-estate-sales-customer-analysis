USE real_estate_data;

CREATE VIEW vw_sales_kpis AS
    SELECT 
        COUNT(*) AS total_properties,
        SUM(CASE
            WHEN sale_status = 'sold' THEN 1
            ELSE 0
        END) AS properties_sold,
        SUM(CASE
            WHEN sale_status = 'unsold' THEN 1
            ELSE 0
        END) AS properties_unsold,
        ROUND(SUM(CASE
                    WHEN sale_status = 'sold' THEN 1
                    ELSE 0
                END) / COUNT(*) * 100,
                2) AS sell_through_rate,
        ROUND(SUM(CASE
                    WHEN sale_status = 'sold' THEN property_price
                    ELSE 0
                END),
                2) AS total_revenue,
        ROUND(AVG(CASE
                    WHEN sale_status = 'sold' THEN property_price
                    ELSE NULL
                END),
                2) AS average_selling_price,
        ROUND(AVG(CASE
                    WHEN sale_status = 'sold' THEN property_price / area_sq_ft
                    ELSE NULL
                END),
                2) AS average_price_per_sq_ft
    FROM
        properties;

SELECT 
    *
FROM
    vw_sales_kpis;

CREATE VIEW vw_yearly_sales AS
    SELECT 
        YEAR(sale_date) AS sale_year,
        COUNT(*) AS properties_sold,
        ROUND(SUM(property_price), 2) AS total_revenue,
        ROUND(AVG(property_price), 2) AS average_selling_price
    FROM
        properties
    WHERE
        sale_status = 'sold'
            AND sale_date IS NOT NULL
    GROUP BY YEAR(sale_date)
    ORDER BY sale_year;

SELECT 
    *
FROM
    vw_yearly_sales;

CREATE OR REPLACE VIEW vw_building_performance AS
    SELECT 
        building_id,
        COUNT(*) AS total_properties,
        SUM(CASE
            WHEN sale_status = 'sold' THEN 1
            ELSE 0
        END) AS properties_sold,
        ROUND(SUM(CASE
                    WHEN sale_status = 'sold' THEN 1
                    ELSE 0
                END) / COUNT(*) * 100,
                2) AS sell_through_rate,
        ROUND(SUM(CASE
                    WHEN sale_status = 'sold' THEN property_price
                    ELSE 0
                END),
                2) AS total_revenue,
        ROUND(AVG(CASE
                    WHEN sale_status = 'sold' THEN property_price
                    ELSE NULL
                END),
                2) AS average_selling_price
    FROM
        properties
    GROUP BY building_id
    ORDER BY total_revenue DESC;

SELECT 
    *
FROM
    vw_building_performance;

CREATE OR REPLACE VIEW vw_customer_segments AS
    SELECT 
        c.acquisition_source,
        c.purpose,
        c.mortgage_status,
        COUNT(DISTINCT c.customer_id) AS total_customers,
        COUNT(p.property_key) AS properties_purchased,
        ROUND(SUM(p.property_price), 2) AS total_revenue,
        ROUND(AVG(p.property_price), 2) AS average_purchase_value,
        ROUND(AVG(p.area_sq_ft), 2) AS average_property_size
    FROM
        customers c
            JOIN
        properties p ON c.customer_id = p.customer_id
    WHERE
        p.sale_status = 'sold'
    GROUP BY c.acquisition_source , c.purpose , c.mortgage_status;
    
SELECT 
    *
FROM
    vw_customer_segments;

CREATE OR REPLACE VIEW vw_geographic_performance AS
    SELECT 
        c.country,
        c.state,
        COUNT(DISTINCT c.customer_id) AS total_customers,
        COUNT(p.property_key) AS properties_purchased,
        ROUND(SUM(p.property_price), 2) AS total_revenue,
        ROUND(AVG(p.property_price), 2) AS average_purchase_value
    FROM
        customers c
            JOIN
        properties p ON c.customer_id = p.customer_id
    WHERE
        p.sale_status = 'sold'
    GROUP BY c.country , c.state;
    
SELECT 
    *
FROM
    vw_geographic_performance
ORDER BY total_revenue DESC;

CREATE OR REPLACE VIEW vw_top_customers AS

WITH customer_value AS (
    SELECT
        c.customer_id,
        CONCAT(c.name, ' ', c.surname) AS customer_name,
        COUNT(p.property_key) AS properties_purchased,
        ROUND(SUM(p.property_price), 2) AS total_customer_revenue,
        ROUND(AVG(p.property_price), 2) AS average_purchase_value
    FROM customers c
    JOIN properties p
        ON c.customer_id = p.customer_id
    WHERE p.sale_status = 'sold'
    GROUP BY
        c.customer_id,
        c.name,
        c.surname
)

SELECT
    customer_id,
    customer_name,
    properties_purchased,
    total_customer_revenue,
    average_purchase_value,
    DENSE_RANK() OVER (
        ORDER BY total_customer_revenue DESC
    ) AS revenue_rank
FROM customer_value;

SELECT 
    *
FROM
    vw_top_customers
ORDER BY revenue_rank
LIMIT 10;

CREATE VIEW vw_property_type_performance AS
    SELECT 
        property_type,
        COUNT(*) AS total_properties,
        SUM(CASE
            WHEN sale_status = 'sold' THEN 1
            ELSE 0
        END) AS properties_sold,
        ROUND(SUM(CASE
                    WHEN sale_status = 'sold' THEN 1
                    ELSE 0
                END) / COUNT(*) * 100,
                2) AS sell_through_rate,
        ROUND(SUM(CASE
                    WHEN sale_status = 'sold' THEN property_price
                    ELSE 0
                END),
                2) AS total_revenue,
        ROUND(AVG(CASE
                    WHEN sale_status = 'sold' THEN property_price
                    ELSE NULL
                END),
                2) AS average_selling_price,
        ROUND(AVG(CASE
                    WHEN sale_status = 'sold' THEN property_price / area_sq_ft
                    ELSE NULL
                END),
                2) AS average_price_per_sq_ft
    FROM
        properties
    GROUP BY property_type
    ORDER BY total_revenue DESC;
    
    
SELECT 
    *
FROM
    vw_property_type_performance
LIMIT 10;

CREATE VIEW vw_age_group_performance AS
WITH customer_sales AS(
	SELECT
		c.customer_id,
        c.birth_date,
        p.property_key,
        p.property_price,
        p.sale_date,
        TIMESTAMPDIFF(YEAR, c.birth_date, p.sale_date) AS age_at_purchase
	FROM
		customers c
	JOIN
		properties p
        ON
			c.customer_id = p.customer_id
	WHERE
		p.sale_status = 'sold'
	AND 
		c.birth_date IS NOT NULL
)

SELECT
	CASE
		WHEN age_at_purchase < 30 THEN 'Under 30'
        WHEN age_at_purchase BETWEEN 30 AND 39 THEN '30-39'
        WHEN age_at_purchase BETWEEN 40 AND 49 THEN '40-49'
        WHEN age_at_purchase BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60+'
	END AS age_group,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(property_key) AS properties_purchased,
    ROUND(SUM(property_price), 2) AS total_revenue,
    ROUND(AVG(property_price), 2) AS average_purchase_value
FROM
	customer_sales
GROUP BY
	age_group
ORDER BY
	total_revenue DESC
;

SELECT 
    *
FROM
    vw_age_group_performance
LIMIT 10;