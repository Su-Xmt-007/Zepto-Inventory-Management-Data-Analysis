
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

### 2.2 Sample Data

```sql
SELECT * FROM zepto LIMIT 10;
```
<img width="102" height="66" alt="image" src="https://github.com/user-attachments/assets/0cdd6a7c-5f62-4947-80a7-354e7e286901" />

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

### 2.5 Stock Status Distribution

```sql
SELECT outofStock, COUNT(sku_id)
FROM zepto
GROUP BY outofStock;
```

### 2.6 Products Appearing Multiple Times

```sql
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY COUNT(sku_id) DESC;
```

---

## 3. Data Cleaning

### 3.1 Price Zero Check

```sql
SELECT * FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;
```

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

### Q3. Estimated Revenue per Category

```sql
SELECT category AS CategoryName,
       SUM(discountedSellingPrice * quantity) AS TotalRevenue
FROM zepto
GROUP BY category
ORDER BY TotalRevenue;
```

### Q4. Products with MRP > 500 and Discount < 10%

```sql
SELECT DISTINCT name AS ProductName,
       mrp,
       discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;
```

### Q5. Top 5 Categories by Highest Average Discount Percentage

```sql
SELECT category,
       ROUND(AVG(discountPercent), 3) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;
```

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

### Q8. Total Inventory Weight per Category

```sql
SELECT category,
       SUM(ROUND(availableQuantity * weightInGms, 2)) AS TotalInventoryCategorywise
FROM zepto
GROUP BY category
ORDER BY TotalInventoryCategorywise DESC;
```

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


## 6. Conclusion

This SQL analysis provides a comprehensive understanding of product pricing, discount behavior, category performance, and inventory distribution. The queries included here cover data cleaning, exploration, and insightful business analytics. Additional advanced analysis can be added to make the insights deeper and more meaningful depending on business requirements.

If needed, further dashboards, visualizations, or automated reports can be created on top of this SQL output.
