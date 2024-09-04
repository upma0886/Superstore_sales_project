create database Walmart_sales_database;

-- Create table by table import wizard.

-- Update existing data in table

UPDATE walmartsalesdata 
SET 
    Date = STR_TO_DATE(Date, '%m/%d/%Y');

UPDATE walmartsalesdata 
SET 
    Time = STR_TO_DATE(Time, '%H:%i:%s');

-- Change date type of columns in table

Alter table walmartsalesdata
Modify column gender VARCHAR(20) NOT NULL,
Modify column product_line VARCHAR(100)NOT NULL,
Modify column unit_price DECIMAL(10,2) NOT NULL,
Modify column quantity INT NOT NULL,
Modify column VAT FLOAT(6,4) NOT NULL,
Modify column total decimal(12,4) NOT NULL,
Modify column Date date not null,
Modify column Time time not null,
Modify column payment VARCHAR(20) NOT NULL,
Modify column cogs DECIMAL(10,2) NOT NULL,
Modify column gross_margin_percentage float(15,9),
Modify column gross_income Float(15,4) NOT NULL,
modify column rating float NOT NULL;


-- Rename column
Alter table walmartsalesdata
Rename column VAT to Taxes;

-- Add a new column time of day to give insight of sales in Morning, Afternoon, Evening.
SELECT 
    time,
    (CASE
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:00:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END) AS time_of_date
FROM
    walmartsalesdata;

ALTER table walmartsalesdata
ADD COLUMN time_of_day VARCHAR(20);

UPDATE walmartsalesdata 
SET 
    time_of_day = (CASE
        WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:00:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END);

-- add a new column day_name in table 

SELECT 
    DAYNAME(date)
FROM
    walmartsalesdata;

ALTER table walmartsalesdata
ADD COLUMN day_name VARCHAR(20);

UPDATE walmartsalesdata 
SET 
    day_name = DAYNAME(date);

-- add a new column month_name in table 
SELECT 
    date, MONTHNAME(date) as month_name
FROM
    walmartsalesdata;

ALTER table walmartsalesdata
add column month_name VARCHAR(10);

UPDATE walmartsalesdata 
SET 
    month_name = MONTHNAME(date);

-- --------------------------------------------------------------------
-- ---------------------------- Generic ------------------------------
-- -------------------------------------------------------------------
-- 1. Business Questions to answer
-- 		Name the cities does data have?

SELECT DISTINCT city
FROM
    walmartsalesdata;

-- 2. Name the branches in each city have?
 SELECT DISTINCT city, branch
FROM
    walmartsalesdata;
 
 
 -- --------------------------------------------------------------------
-- ---------------------------- Product Analysis-------------------------------
-- --------------------------------------------------------------------

-- 1.  How many unique product lines does the data have?
SELECT DISTINCT Product_line
FROM
    walmartsalesdata;
-- 2. What is the most common payment method? 
  SELECT 
    Payment AS Payment_method, COUNT(payment) AS frequency
FROM
    walmartsalesdata
GROUP BY payment
order by frequency desc;
    
    
-- 3. What is the most selling product line?
SELECT DISTINCT Product_line, SUM(quantity) AS pl_sales
FROM
    walmartsalesdata
GROUP BY Product_line
ORDER BY pl_sales DESC
LIMIT 1;

-- 4. What is the total revenue by month?

SELECT 
    month_name as month, SUM(unit_price * quantity) AS total_revenue 
FROM
    walmartsalesdata
GROUP BY month_name;

-- 5. What month had the largest COGS?

SELECT 
    month_name AS month, SUM(cogs) AS COGS
FROM
    walmartsalesdata
GROUP BY month_name
ORDER BY COGS DESC
LIMIT 1;

-- 6. What product line had the largest revenue?

SELECT 
    Product_Line, SUM(unit_price * quantity) AS revenue
FROM
    walmartsalesdata
GROUP BY Product_Line
ORDER BY revenue DESC
LIMIT 1;

-- 7. What is the branch of city with the largest revenue?
SELECT 
   Branch, City,SUM(unit_price * quantity) AS revenue
FROM
    walmartsalesdata
GROUP BY branch , city
ORDER BY revenue DESC
LIMIT 1;

-- 8.-- What product line had the largest VAT?
SELECT
	product_line,
	Round(AVG(Taxes),2) as avg_tax
FROM walmartsalesdata
GROUP BY product_line
ORDER BY avg_tax DESC;

-- 10. Which branch sold more products than average product sold?
 
select Branch, sum(quantity) as qty_sold
from walmartsalesdata
group by Branch
having sum(quantity) > (select sum(quantity)/count(distinct branch) as Total_average_sold
from walmartsalesdata);


-- --------------------------------------------------------------------
-- -------------------------- Customers -------------------------------
-- --------------------------------------------------------------------
-- 11. How many unique customer types does the data have?
SELECT DISTINCT Customer_type
FROM
    walmartsalesdata;

-- 12. -- How many unique payment methods does the data have?
SELECT DISTINCT payment
FROM
    walmartsalesdata;

-- 13. What is the most common customer type?
SELECT 
    customer_type, COUNT(*) AS count
FROM
    walmartsalesdata
GROUP BY customer_type
ORDER BY count DESC;

-- 14. Which customer type buys the most?
SELECT 
    customer_type, COUNT(*)
FROM
    walmartsalesdata
GROUP BY customer_type;

-- 15. What is the gender of most of the customers?
SELECT 
    gender, COUNT(*) AS gender_cnt
FROM
    walmartsalesdata
GROUP BY gender
ORDER BY gender_cnt DESC;

-- 16. What is the gender distribution per branch?
SELECT 
    gender, COUNT(*) AS gender_cnt
FROM
    walmartsalesdata
WHERE
    branch = 'A'
GROUP BY gender
ORDER BY gender_cnt DESC;


-- 17. Which time of the day do customers give most ratings?
SELECT 
    time_of_day, ROUND(AVG(rating), 2) AS avg_rating
FROM
    walmartsalesdata
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter


-- 18. Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM walmartsalesdata
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.


-- 19.  Which day fo the week has the best avg ratings?
SELECT 
    day_name, ROUND(AVG(rating), 2) AS avg_rating
FROM
    walmartsalesdata
GROUP BY day_name
ORDER BY avg_rating DESC;
-- Mon,Friday, Sunday are the top best days for good ratings


-- 20. Which day of the week has the best average ratings per branch?
SELECT 
    day_name, COUNT(day_name) total_sales
FROM
    walmartsalesdata
WHERE
    branch = 'C'
GROUP BY day_name
ORDER BY total_sales DESC;


-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- ---------------------------- Sales ---------------------------------
-- --------------------------------------------------------------------

-- 21.Number of sales made in each time of the day per weekday 
SELECT 
    time_of_day, COUNT(*) AS total_sales
FROM
    walmartsalesdata
WHERE
    day_name = 'Sunday'
GROUP BY time_of_day
ORDER BY total_sales DESC;
-- Evenings experience most sales.

-- 22. Which of the customer types brings the most revenue?
SELECT 
    customer_type, SUM(total) AS total_revenue
FROM
    walmartsalesdata
GROUP BY customer_type
ORDER BY total_revenue;

-- 23. Which city has the largest tax percent?
SELECT 
    city, ROUND(AVG(Taxes), 2) AS avg_tax
FROM
    walmartsalesdata
GROUP BY city
ORDER BY avg_tax DESC;

-- 24.  Which customer type pays the most in VAT?
SELECT 
    customer_type, AVG(taxes) AS total_tax
FROM
    walmartsalesdata
GROUP BY customer_type
ORDER BY total_tax;
