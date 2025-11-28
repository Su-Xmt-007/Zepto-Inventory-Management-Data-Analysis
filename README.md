
# Zepto Product Dataset Analysis

This project focuses on exploring, cleaning, and analyzing the Zepto product dataset using SQL. The goal is to generate meaningful business insights related to product pricing, 
discounts, inventory distribution, stock status, and category-level performance.

## 1. Dataset Structure

The dataset contains product-level information including:

* SKU ID
* Category
* Product Name
* MRP (Maximum Retail Price)
* Discount Percentage
* Available Quantity
* Discounted Selling Price
* Weight in Grams
* Stock Status
* Quantity

A PostgreSQL table is created using the following schema:

```sql
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
```


---

## 2. Data Exploration

### 2.1 Row Count

```sql
SELECT COUNT(*) FROM zepto;
```
<img width="102" height="66" alt="image" src="https://github.com/user-attachments/assets/0cdd6a7c-5f62-4947-80a7-354e7e286901" />

### 2.2 Sample Data

```sql
SELECT * FROM zepto LIMIT 10;
```
<img width="986" height="246" alt="image" src="https://github.com/user-attachments/assets/07ba0760-cfb0-4574-bcef-30492d1e9865" />


### 2.3 Null Value Detection

```sql
SELECT * FROM zepto
WHERE name IS NULL
   OR category IS NULL
   OR mrp IS NULL
   OR discountPercent IS NULL
   OR availableQuantity IS NULL
   OR discountedSellingPrice IS NULL
   OR weightInGms IS NULL
   OR outofStock IS NULL
   OR quantity IS NULL;
```

### 2.4 Distinct Categories

```sql
SELECT DISTINCT category
FROM zepto
ORDER BY category;
```
<img width="172" height="332" alt="image" src="https://github.com/user-attachments/assets/e925f3d1-ac28-4ee8-88ae-d8cab64de56b" />

### 2.5 Stock Status Distribution

```sql
SELECT outofStock, COUNT(sku_id)
FROM zepto
GROUP BY outofStock;
```
<img width="163" height="77" alt="image" src="https://github.com/user-attachments/assets/dd8e6c50-e7a1-4945-abbd-f3e1ea585a3a" />

### 2.6 Products Appearing Multiple Times

```sql
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY COUNT(sku_id) DESC;
```
<img width="595" height="250" alt="image" src="https://github.com/user-attachments/assets/e3c8a1dc-d9ca-483a-aff4-62a89726ba60" />

---

## 3. Data Cleaning

### 3.1 Price Zero Check

```sql
SELECT * FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;
```
<img width="1063" height="63" alt="image" src="https://github.com/user-attachments/assets/8c913d1c-6438-46f7-8b87-5d7a571cb43e" />

```sql
DELETE FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;
```

### 3.2 Converting Paise to Rupees

```sql
UPDATE zepto
SET mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0;
```

---

## 4. Business Insights

### Q1. Top 10 Best Value Products (Highest Discount Percentage)

```sql
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;
```
<img width="567" height="266" alt="image" src="https://github.com/user-attachments/assets/b191fed1-a5a4-42fe-a911-1bfa68e592f1" />

### Q2. Products with High MRP but Out of Stock

```sql
SELECT DISTINCT name AS ProductName,
       mrp AS ProductPrice,
       outofStock
FROM zepto
WHERE outofStock = 'true'
ORDER BY mrp DESC
LIMIT 10;
```
<img width="529" height="272" alt="image" src="https://github.com/user-attachments/assets/1c5fab1b-c400-4df7-b780-86897ccdc76b" />

### Q3. Estimated Revenue per Category

```sql
SELECT category AS CategoryName,
       SUM(discountedSellingPrice * quantity) AS TotalRevenue
FROM zepto
GROUP BY category
ORDER BY TotalRevenue;
```
<img width="307" height="390" alt="image" src="https://github.com/user-attachments/assets/5ad13985-c01b-4f4c-8c82-65b530842469" />

### Q4. Products with MRP > 500 and Discount < 10%

```sql
SELECT DISTINCT name AS ProductName,
       mrp,
       discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;
```
<img width="740" height="501" alt="image" src="https://github.com/user-attachments/assets/264f8dd5-bdb9-4260-9fef-d02ac6df1675" />

### Q5. Top 5 Categories by Highest Average Discount Percentage

```sql
SELECT category,
       ROUND(AVG(discountPercent), 3) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;
```
<img width="310" height="165" alt="image" src="https://github.com/user-attachments/assets/7a7d12a1-793b-45b7-8361-0e0162b3df4c" />

### Q6. Price per Gram for Products above 100g

```sql
SELECT DISTINCT name AS ProductName,
       weightInGms,
       discountedSellingPrice,
       ROUND(discountedSellingPrice / weightInGms, 3) AS Price_perGrams
FROM zepto
WHERE weightInGms >= 100
ORDER BY Price_perGrams ASC;
```
<img width="891" height="505" alt="image" src="https://github.com/user-attachments/assets/0232d005-2d9c-47ec-be35-9a0011ca7d1b" />

### Q7. Weight-Based Product Classification

```sql
SELECT DISTINCT name,
       weightInGms,
       CASE
           WHEN weightInGms < 1000 THEN 'LOW'
           WHEN weightInGms < 5000 THEN 'Medium'
           ELSE 'Bulk'
       END AS WeightCategory
FROM zepto;
```
<img width="825" height="519" alt="image" src="https://github.com/user-attachments/assets/59e9b104-06c0-436e-8b59-4b0b77908eb9" />

### Q8. Total Inventory Weight per Category

```sql
SELECT category,
       SUM(ROUND(availableQuantity * weightInGms, 2)) AS TotalInventoryCategorywise
FROM zepto
GROUP BY category
ORDER BY TotalInventoryCategorywise DESC;
```
<img width="381" height="396" alt="image" src="https://github.com/user-attachments/assets/d05f2b1a-ffeb-4b3e-a4e0-b1fd28510f01" />

---

## 5. Additional Suggested Analysis

To further improve the quality of this analysis, consider adding:

### 1. Outlier Detection (High MRP within each category)

```sql
SELECT name, category, mrp
FROM zepto z1
WHERE mrp > (
    SELECT AVG(mrp) + 2 * STDDEV(mrp)
    FROM zepto z2
    WHERE z1.category = z2.category
)
ORDER BY category, mrp DESC;
```
<img width="763" height="234" alt="image" src="https://github.com/user-attachments/assets/c22e2adf-b80f-44d1-881c-70a21f786bdf" />




