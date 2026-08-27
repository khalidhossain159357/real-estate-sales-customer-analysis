CREATE DATABASE real_estate_data;

USE real_estate_data;

SHOW tables;

RENAME TABLE customers_clean TO customers;

RENAME TABLE properties_clean TO properties;


-- customers cleaning 

DESCRIBE customers;

ALTER TABLE customers
RENAME COLUMN `ï»¿customer_id` TO customer_id;

DESCRIBE customers;

ALTER TABLE customers
ADD COLUMN birth_date_new DATE;

UPDATE customers
SET birth_date_new = STR_TO_DATE(birth_date, '%m/%d/%Y')
WHERE birth_date IS NOT NULL
  AND birth_date <> '';
  
SELECT 
    birth_date, birth_date_new
FROM
    customers
LIMIT 10

ALTER TABLE customers
DROP COLUMN birth_date;

ALTER TABLE customers
RENAME COLUMN birth_date_new TO birth_date;

ALTER TABLE customers
MODIFY customer_id VARCHAR(10) NOT NULL,
MODIFY entity VARCHAR(20),
MODIFY name VARCHAR(100),
MODIFY surname VARCHAR(100),
MODIFY birth_date DATE,
MODIFY sex VARCHAR(10),
MODIFY country VARCHAR(50),
MODIFY state VARCHAR(50),
MODIFY purpose VARCHAR(20),
MODIFY satisfaction_score TINYINT,
MODIFY mortgage_status VARCHAR(10),
MODIFY acquisition_source VARCHAR(30);

DESCRIBE customers;


-- properties cleaning

SELECT birth_date 
from customers
limit 10;
DESCRIBE properties;

ALTER TABLE properties
RENAME COLUMN ï»¿property_key to property_key;

DESCRIBE properties;

UPDATE properties
SET sale_date = NULL
WHERE TRIM(sale_date) = '';

UPDATE properties
SET sale_date = DATE_FORMAT(
    STR_TO_DATE(sale_date, '%m/%d/%Y'),
    '%Y-%m-%d'
)
WHERE sale_date IS NOT NULL;

ALTER TABLE properties
MODIFY property_key INT NOT NULL,
MODIFY property_id INT,
MODIFY building_id INT,
MODIFY sale_date DATE,
MODIFY property_type VARCHAR(20),
MODIFY property_number INT,
MODIFY area_sq_ft DECIMAL(10,2),
MODIFY property_price DECIMAL(12,2),
MODIFY sale_status VARCHAR(10),
MODIFY customer_id VARCHAR(10);

DESCRIBE properties;


SELECT sale_date
FROM properties;

ALTER TABLE properties
ADD PRIMARY KEY (property_key);

ALTER TABLE customers
ADD PRIMARY KEY (customer_id);

SELECT COUNT(p.customer_id)
FROM properties p
LEFT JOIN customers c
    ON p.customer_id = c.customer_id
WHERE p.customer_id IS NOT NULL
  AND c.customer_id IS NULL;
  
SELECT 
	LENGTH(customer_id) id_length,
    customer_id
FROM
	customers;

SELECT 
	LENGTH(customer_id) id_length,
    customer_id
FROM
	properties;
    
UPDATE properties
SET customer_id = TRIM(customer_id)
WHERE customer_id IS NOT NULL;

UPDATE properties
SET customer_id = NULL
WHERE TRIM(customer_id) = ''
;

SELECT COUNT(p.customer_id)
FROM properties p
LEFT JOIN customers c
    ON p.customer_id = c.customer_id
WHERE p.customer_id IS NOT NULL
  AND c.customer_id IS NULL;
  
ALTER TABLE properties
ADD CONSTRAINT fk_properties_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

SHOW CREATE TABLE properties;

DESCRIBE properties;

SELECT 	
	DISTINCT sale_status,
    LENGTH(sale_status) 
FROM 
	properties;
    
UPDATE properties 
SET 
    sale_status = LOWER(TRIM(sale_status))