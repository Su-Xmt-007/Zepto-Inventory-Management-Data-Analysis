drop table if exists zepto;

--Creating
create table zepto(
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(120) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(8,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms NUMERIC(8,2),
outofStock Boolean,
quantity INTEGER
);


----- DATA EXPLORATION -----
--Count of Rows
SELECT COUNT(*) from zepto;


-- Sample Data
SELECT * FROM zepto LIMIT 10;

--Null values
SELECT * FROM zepto WHERE
name IS NULL  OR
category IS NULL  OR
mrp IS NULL  OR
discountPercent IS NULL  OR
availableQuantity IS NULL  OR
discountedSellingPrice IS NULL  OR
weightInGms IS NULL  OR
outofStock IS NULL  OR
quantity IS NULL;


-- different category products
SELECT DISTINCT category
FROM zepto
ORDER BY category;


-- Product in stock vs out of stock
SELECT outofStock, COUNT(sku_id)
FROM ZEPTO
GROUP BY outofStock;


-- Product name present in multiple times
SELECT name, count(sku_id) as "Number of SKUs"
FROM zepto 
GROUP BY name
HAVING COUNT(sku_id)>1 
ORDER BY count(sku_id) DESC;



----------------  DATA CLEANING  ---------------
---- Product with price 0
SELECT * FROM zepto
WHERE mrp= 0 OR discountedSellingPrice=0;

DELETE FROM zepto
WHERE mrp=0  OR discountedSellingPrice=0;


----Convert Paise to Rupees
UPDATE zepto
SET mrp=mrp/100.0,
discountedSellingPrice=discountedSellingPrice/100.0;
--checking
SELECT mrp, discountedSellingPrice from zepto;





----------- Business Insight from this dataset ----------
-- Q1. Find top 10 best value product best on their discount percentage?
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;



-- Q2. What are the products with high MRP but out of stock
SELECT DISTINCT name AS ProductName, 
	MRP AS ProductPrice,
	outofstock
FROM zepto
WHERE outofStock= 'true'
ORDER BY mrp DESC
LIMIT 10;



-- Q3. Calculate estimated revenue for each category.
SELECT category AS CategoryName,
SUM(discountedSellingPrice * quantity) AS TotalRevenue
FROM zepto
GROUP BY category 
ORDER BY TotalRevenue



-- Q4: Find all products where MRP is greater than 500 rupees and discount is less than 10%.
SELECT DISTINCT name AS ProductName,
 	mrp as MRP, 
	discountPercent 
FROM zepto
WHERE mrp>500 AND discountPercent<10
ORDER BY mrp DESC, discountPercent DESC;
	


-- Q5. Identify the top 5 categories offering the highest avgrage discount percentage.
SELECT  category,
ROUND(AVG(discountPercent),3) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;



-- Q6. Find the price per gram for products above 100gm and sort by best value.
SELECT DISTINCT name AS ProductName, weightInGms, discountedSellingPrice,
	ROUND(discountedSellingPrice / weightInGms,3) AS Price_perGrams
FROM zepto
WHERE weightInGms>=100
ORDER BY Price_perGrams ASC;



-- Q7. Group the products into categories like low, medium, bluk.
SELECT DISTINCT name, weightInGms,
CASE
	WHEN weightInGms <1000 THEN 'LOW'
	WHEN weightInGms <5000 THEN 'Medium'
	ELSE 'Bulk'
	END AS "WeightCategory"
FROM zepto;



-- Q8. What is the total Inventory weight per category?
SELECT DISTINCT  category, 
	SUM(ROUND(availableQuantity * weightInGms,2)) AS TotalInvetoryCategorywise
FROM zepto
GROUP BY category
ORDER BY TotalInvetoryCategorywise DESC;




--Q9. Category with highest product variety.
SELECT category, COUNT(*) AS total_skus
FROM zepto
GROUP BY category
ORDER BY total_skus DESC;



--Q10. Top 10 products with highest absolute discount amount.
SELECT name, mrp, discountedSellingPrice,
       (mrp - discountedSellingPrice) AS discount_amount
FROM zepto
ORDER BY discount_amount DESC
LIMIT 10;



--Q11. Most revenue-efficient categories
SELECT category,
       SUM(discountedSellingPrice * quantity) / COUNT(*) AS revenue_per_product
FROM zepto
GROUP BY category
ORDER BY revenue_per_product DESC;


--Q12. Overpriced products in each category.
SELECT name, category, mrp
FROM zepto z1
WHERE mrp > (
    SELECT AVG(mrp) + 2 * STDDEV(mrp)
    FROM zepto z2
    WHERE z1.category = z2.category
)
ORDER BY category, mrp DESC;



--Q13 — Products with highest inventory holding value
SELECT name, category,
       (availableQuantity * discountedSellingPrice) AS stock_value
FROM zepto
ORDER BY stock_value DESC
LIMIT 10;



--Q14 — Out-of-stock percentage per category
SELECT category,
    SUM(CASE WHEN outOfStock=TRUE THEN 1 ELSE 0 END)*100.0/COUNT(*) AS oos_percent
FROM zepto
GROUP BY category
ORDER BY oos_percent DESC;



--Q15 — Slow-moving products (low quantity sold)
SELECT name, category, quantity
FROM zepto
ORDER BY quantity ASC
LIMIT 15;



--Q16 — Correlation between MRP and discount
SELECT corr(mrp, discountPercent) AS correlation
FROM zepto;



--Q17 — Best-value categories (discount + MRP + count)
SELECT category,
       AVG(discountPercent) AS avg_discount,
       AVG(mrp) AS avg_mrp,
       COUNT(*) AS total_items
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC;



--- Q18 — Low stock but available (risk of going out-of-stock)
SELECT name, category, availableQuantity
FROM zepto
WHERE availableQuantity < 5 AND outOfStock = FALSE
ORDER BY availableQuantity ASC;



--Q19 — Best bulk deals (low price per gram)
SELECT name, weightInGms, discountedSellingPrice,
       discountedSellingPrice / weightInGms AS price_per_gram
FROM zepto
WHERE weightInGms > 500
ORDER BY price_per_gram ASC
LIMIT 10;




