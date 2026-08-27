USE real_estate_data;

-- Business Question 1: How many properties are available, sold, and unsold?

SELECT 
    COUNT(*) AS total_properties,
    SUM(CASE
        WHEN sale_status = 'sold' THEN 1
        ELSE 0
    END) AS sold_properties,
    SUM(CASE
        WHEN sale_status = 'unsold' THEN 1
        ELSE 0
    END) AS unsold_properties
FROM
    properties;
    
-- Business Question 2: What is the sell-through rate?

SELECT 
    ROUND(SUM(CASE
                WHEN sale_status = 'sold' THEN 1
                ELSE 0
            END) / COUNT(*) * 100,
            2) AS sale_through_rate
FROM
    properties;

-- Business Question 3: What are total sales revenue and average selling price?

SELECT 
    ROUND(SUM(property_price), 2) AS total_revenue,
    ROUND(AVG(property_price), 2) AS average_selling_price
FROM
    properties
WHERE
    sale_status = 'sold'
;


-- Business Question 4: How have sales volume and revenue changed over time?

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
ORDER BY sale_year
;

-- Question 5: Which buildings perform best based on sales volume, revenue, average selling price, and sell-through rate?

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
            2) AS sale_through_rate,
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
ORDER BY total_revenue DESC
;
	

-- Question 6: Which customer acquisition sources generate the most customers and revenue?

WITH sold_properties AS(
	SELECT
		property_key,
        customer_id,
        property_price
	FROM
		properties
	WHERE
		sale_status = 'sold'
)

SELECT
	c.acquisition_source AS acquisition_type,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(p.property_key) AS properties_purchased,
    ROUND(SUM(p.property_price), 2) AS total_revenue,
    ROUND(AVG(p.property_price), 2) AS average_purchase_value
FROM 
	customers AS c
JOIN 
	sold_properties AS p
ON
	c.customer_id = p.customer_id
GROUP BY
	acquisition_type
ORDER BY
	total_revenue DESC
;


-- Question 7: Do home buyers and investors exhibit different purchasing behavior?

WITH sold_properties AS(
	SELECT 
		property_key,
        customer_id,
        property_price,
        area_sq_ft
	FROM
		properties
	WHERE
		sale_status = 'sold'
)

SELECT
	c.purpose AS purposes,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(sp.property_key) AS properties_purchased,
    ROUND(SUM(sp.property_price), 2) AS total_revenue,
    ROUND(AVG(sp.property_price), 2) AS average_purchase_value,
    ROUND(AVG(sp.area_sq_ft), 2) AS average_property_size
FROM 
	customers AS c
JOIN
	sold_properties AS sp
	ON
		c.customer_id = sp.customer_id
GROUP BY
	c.purpose
ORDER BY
	total_revenue DESC
;

-- Question 8: How do mortgage and non-mortgage buyers differ in purchasing behavior?

WITH sold_properties AS(
	SELECT 
		property_key,
        customer_id,
        property_price,
        area_sq_ft
	FROM
		properties
	WHERE
		sale_status = 'sold'
)

SELECT
	c.mortgage_status AS mortgage_status,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(sp.property_key) AS properties_purchased,
    ROUND(SUM(sp.property_price), 2) AS total_revenue,
    ROUND(AVG(sp.property_price), 2) AS average_purchase_value,
    ROUND(AVG(sp.area_sq_ft), 2) AS average_property_size
FROM 
	customers AS c
JOIN
	sold_properties AS sp
	ON
		c.customer_id = sp.customer_id
GROUP BY
	c.mortgage_status
ORDER BY
	total_revenue DESC
;


-- Question 9: Which customer age groups generate the most revenue and purchase value?

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

-- Question 10: Which geographic markets generate the most customers and revenue?

-- Country Wise

WITH sold_properties AS (
    SELECT
        property_key,
        customer_id,
        property_price
    FROM 
		properties
    WHERE 
		sale_status = 'sold'
)

SELECT
    c.country,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(sp.property_key) AS properties_purchased,
    ROUND(SUM(sp.property_price), 2) AS total_revenue,
    ROUND(AVG(sp.property_price), 2) AS average_purchase_value
FROM 
	customers c
JOIN 
	sold_properties sp
    ON 
		c.customer_id = sp.customer_id
GROUP BY 
	c.country
ORDER BY 
	total_revenue DESC;
    
-- State Wise

WITH sold_properties AS (
    SELECT
        property_key,
        customer_id,
        property_price
    FROM 
		properties
    WHERE 
		sale_status = 'sold'
)

SELECT
    c.state,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(sp.property_key) AS properties_purchased,
    ROUND(SUM(sp.property_price), 2) AS total_revenue,
    ROUND(AVG(sp.property_price), 2) AS average_purchase_value
FROM 
	customers c
JOIN 
	sold_properties sp
    ON 
		c.customer_id = sp.customer_id
WHERE 
	c.country = 'USA'
GROUP BY 
	c.state
ORDER BY 
	total_revenue DESC
;
    
-- Question 11: Who are the highest-value and repeat customers?

WITH customer_value AS(
	SELECT
		c.customer_id,
        CONCAT(c.name, ' ', c.surname) AS customer_name,
        COUNT(p.property_key) AS properties_purchased,
        ROUND(SUM(p.property_price), 2) AS total_customer_revenue,
        ROUND(AVG(p.property_price), 2) AS average_purchase_value
	FROM
		customers c
	JOIN
		properties p
        ON
			c.customer_id = p.customer_id
	WHERE 
		p.sale_status = 'sold'
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
    DENSE_RANK() OVER(
		ORDER BY total_customer_revenue DESC) AS revenue_rank
FROM
	customer_value
ORDER BY
	revenue_rank,
    customer_id
LIMIT
	10
;


-- Question 12: Which property types deliver the strongest value?

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