create database employees_data;
select * from employees;
select *from sales;
DESCRIBE employees;

UPDATE sales
SET sale_date = STR_TO_DATE(sale_date, '%d-%m-%Y');
ALTER TABLE sales
MODIFY COLUMN sale_date DATE;
update employees
set date_of_joining = str_to_date(date_of_joining, '%d-%m-%Y');
alter table employees
modify date_of_joining date;

 # Find the full name, department, and total sales amount for each employee who made sales above ₹100,000 in 2023.
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.department,
    SUM(s.total_sale) AS sales
FROM
    employees e
        JOIN
    sales s ON e.employee_id = s.employee_id
WHERE
    EXTRACT(YEAR FROM s.sale_date) = 2023
GROUP BY CONCAT(e.first_name, ' ', e.last_name) , e.department
HAVING SUM(s.total_sale) > 100000;

# List all employees who made at least one sale in the "West" region and have more than 5 years of experience in the company.**
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department,
    s.region,
    SUM(s.total_sale) AS TS
FROM
    employees e
        JOIN
    sales s ON e.employee_id = s.employee_id
WHERE
    s.region = 'West'
        AND TIMESTAMPDIFF(YEAR,
        e.date_of_joining,
        '2024-12-31') > 5
GROUP BY e.employee_id , e.first_name , e.last_name , e.department;

# For each department, show the average discount given by its employees and the total units sold.**

SELECT
e.department,
 round(AVG(s.discount),2) AS avg_discount,
 SUM(s.units_sold) AS total_units
FROM employees e
JOIN sales s ON e.employee_id = s.employee_id
GROUP BY e.department;

# Display employee details and their total sales amount where sales were made only through 'Card' or 'UPI'.**

SELECT 
    e.employee_id,
    e.first_name,
    e.department,
    s.payment_method,
    SUM(s.total_sale) AS TS
FROM
    employees e
        JOIN
    sales s ON e.employee_id = s.employee_id
WHERE
    s.payment_method IN ('Card' , 'UPI')
GROUP BY e.employee_id , e.first_name , e.department , s.payment_method;

# Show employees who have never made any sales, along with their department and location.**
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department,
    e.location
FROM employees e
LEFT JOIN sales s ON e.employee_id = s.employee_id
WHERE s.employee_id IS NULL;

 # Find the top 3 employees by total sales amount in each region.**
SELECT *
FROM (
    SELECT
        s.region,
        e.employee_id,
        e.first_name,
        e.last_name,
        SUM(s.total_sale) AS total_sales,
        RANK() OVER (PARTITION BY s.region ORDER BY SUM(s.total_sale) DESC) AS rnk
    FROM employees e
    JOIN sales s ON e.employee_id = s.employee_id
    GROUP BY s.region, e.employee_id, e.first_name, e.last_name
) t
WHERE rnk <= 3;

# Display each employee’s total number of sales and categorize them as ‘High Performer’, ‘Medium Performer’, or ‘Low Performer’ based on total sale value using a CASE statement.*
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS full_names,
    COUNT(s.sale_id) AS sales,
    ROUND(SUM(s.total_sale), 3) AS ts,
    CASE
        WHEN SUM(s.total_sale) > 300000 THEN 'High Performer'
        WHEN SUM(s.total_sale) BETWEEN 150000 AND 300000 THEN 'Medium Perfromer'
        ELSE 'Low Performer'
    END AS performence
FROM
    employees e
        JOIN
    sales s ON e.employee_id = s.employee_id
GROUP BY e.employee_id , CONCAT(e.first_name, ' ', e.last_name)
ORDER BY e.employee_id ASC;

# List all female employees from ‘Marketing’ department who sold ‘Laptop’ or ‘Mobile’ and offered a discount greater than 15%.**

SELECT DISTINCT
    e.employee_id,
    e.first_name,
    e.last_name,
    s.discount,
    e.department,
    s.product
FROM employees e
JOIN sales s ON e.employee_id = s.employee_id
WHERE e.gender = 'Female'
  AND e.department = 'Marketing'
  AND s.product IN ('Laptop', 'Mobile')
  AND s.discount > 0.15;

# Get the count of employees who have made sales in more than 2 different customer types.**

select employee_id, count(distinct customer_type) as customer_types from sales 
group by employee_id
having count(distinct customer_type)>=2;

# Show all employee names and their highest and lowest sale amounts. Sort by highest sale descending.**

SELECT 
    e.first_name,
    e.last_name,
    MAX(total_sale) AS highest_sale,
    MIN(total_sale) AS lowest_sale
FROM
    employees e
        JOIN
    sales s ON e.employee_id = s.employee_id
GROUP BY e.first_name , e.last_name
ORDER BY highest_sale DESC;

# List the first 5 employees (by joining date) who made a sale in 2023 using 'Cash' as the payment method.**

SELECT DISTINCT
    e.employee_id, e.first_name, e.last_name, e.date_of_joining
FROM
    employees e
        JOIN
    sales s ON e.employee_id = s.employee_id
WHERE
    payment_method = 'Cash'
        AND EXTRACT(YEAR FROM s.sale_date) = 2023
ORDER BY e.date_of_joining ASC
LIMIT 5;

# Get employee names, department, and their most frequently sold product.*

SELECT employee_id, product
FROM (
    SELECT
        employee_id,
        product,
        COUNT(*) AS cnt,
        dense_rank() OVER (PARTITION BY employee_id ORDER BY COUNT(*) DESC) AS rnk
    FROM sales
    GROUP BY employee_id, product
) t
WHERE rnk = 1;

# Find all employees who made sales in both ‘North’ and ‘South’ regions.**
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    department,
    s.region
FROM
    employees e
        JOIN
    sales s ON e.employee_id = s.employee_id
WHERE
    s.region IN ('North' , 'South')
GROUP BY e.employee_id , e.first_name , e.last_name , department , s.region;

# Show the average unit price for each product sold by employees from the 'Sales' and 'IT' departments.**

SELECT 
    s.product, ROUND(AVG(s.unit_price), 2) AS avg_unit_price
FROM
    sales s
        JOIN
    employees e ON s.employee_id = e.employee_id
WHERE
    e.department IN ('Sales' , 'IT')
GROUP BY s.product;

# List employees who made sales on weekends and the total sale amount for those days.**

SELECT 
    e.employee_id, e.first_name, SUM(total_sale) AS total_sale
FROM
    employees e
        JOIN
    sales s ON e.employee_id = s.employee_id
WHERE
    DAYOFWEEK(s.sale_date) IN (1 , 7)
GROUP BY e.employee_id , e.first_name;

# Find all employees who gave a discount more than 25% in any sale, and calculate how much money was lost due to the discount (as a column).**

SELECT 
    employee_id,
    discount,
    ROUND((total_sale * discount / 100), 2) AS discount_loss
FROM
    sales
WHERE
    discount > 0.25;
    
# Show all employees with their total number of sales and average sale value, only if the average sale is above ₹20,000

SELECT 
    employee_id,
    COUNT(units_sold) AS total_sales,
    ROUND(AVG(total_sale), 2) AS avg_value
FROM
    sales
GROUP BY employee_id
HAVING AVG(total_sale) > 20000;

# List departments where no employee has made a sale in 2023

SELECT 
    e.employee_id, e.department
FROM
    employees e
        LEFT JOIN
    sales s ON e.employee_id = s.employee_id
        AND EXTRACT(YEAR FROM s.sale_date) = 2023
WHERE
    s.employee_id IS NULL;

# For each employee, show total sales done month-wise (in 2023), with a column for month name and total sale.**

SELECT 
    employee_id,
    MONTHNAME(sale_date) AS month_name,
    SUM(total_sale) AS total_sale
FROM
    sales
WHERE
    EXTRACT(YEAR FROM sale_date) = 2023
GROUP BY employee_id , MONTHNAME(sale_date)
ORDER BY employee_id;

# Find employees who sold products in all 4 regions (North, South, East, West)

SELECT 
    employee_id
FROM
    sales
GROUP BY employee_id
HAVING COUNT(DISTINCT region) = 4
ORDER BY employee_id;

# Show the names of employees who made more than 1 sales in a single month, along with the month name and number of sales.**

SELECT 
    e.first_name,
    e.last_name,
    MONTHNAME(sale_date) AS month_name,
    COUNT(*) AS total_sale
FROM
    employees e
        JOIN
    sales s ON e.employee_id = s.employee_id
GROUP BY e.first_name , e.last_name , MONTHNAME(sale_date)
HAVING COUNT(*) > 1;

# Find all employees whose total sale value is less than the average total sale value of their department.**
with dept_avg as (
select e.department, avg(s.total_sale)  as dept_avg from employees e join sales s on e.employee_id = s.employee_id 
group by e.department)
SELECT 
    e.first_name,
    e.last_name,
    e.department,
    SUM(total_sale) AS ts,
    ROUND(d.dept_avg, 2) AS dept_avg
FROM
    employees e
        JOIN
    sales s ON e.employee_id = s.employee_id
        JOIN
    dept_avg d ON e.department = d.department
GROUP BY e.first_name , e.last_name , d.dept_avg , e.department
HAVING SUM(s.total_sale) < d.dept_avg;

# Display each product with the total revenue generated, and also show which employee sold it the most.*

select * from (
select employee_id,product,
round(sum(total_sale),2) as total_sale,
rank() over (partition by product order by sum(total_sale) desc) as rnk 
from sales 
group by employee_id,product)e
having rnk  = 1;

# Show employees who made a sale in more than one quarter of 2023, along with their total annual sale.**

SELECT employee_id,round(SUM(total_sale),2) AS total_sales
FROM sales
WHERE EXTRACT(YEAR FROM sale_date) = 2023
GROUP BY employee_id
HAVING COUNT(DISTINCT EXTRACT(QUARTER FROM sale_date)) >1
order by employee_id;

# Find the department-wise percentage contribution to the overall sales amount, rounded to two decimals.**

SELECT 
    e.department,
    ROUND(SUM(s.total_sale) * 100.0 / (SELECT 
                    SUM(total_sale)
                FROM
                    sales),
            2) AS dept_percentage
FROM
    employees e
        JOIN
    sales s ON e.employee_id = s.employee_id
GROUP BY e.department;


SELECT
    e.department,
    ROUND(
        SUM(s.total_sale) * 100.0 /
        (SELECT SUM(total_sale) FROM sales),
        2
    ) AS contribution_pct
FROM employees e
JOIN sales s ON e.employee_id = s.employee_id
GROUP BY e.department;

# Get a list of employees who made sales using all four payment methods (Card, Cash, UPI, Net Banking).**

SELECT 
    employee_id, payment_method
FROM
    sales
WHERE
    payment_method = 'Card' && 'Cash'
        && 'UPI'
        && 'Net Banking'
GROUP BY employee_id , payment_method;

# Display employees who joined after 2021 and whose average discount offered across all sales is less than 10%.**

SELECT 
    e.employee_id,
    e.date_of_joining,
    ROUND(AVG(s.discount), 2) AS avg_disct
FROM
    employees e
        JOIN
    sales s ON e.employee_id = s.employee_id
WHERE
    date_of_joining > '2021-12-31'
GROUP BY e.employee_id , e.date_of_joining
HAVING AVG(s.discount) < 0.10
ORDER BY employee_id ASC;

# List employees who made their highest sale on a weekend, along with the sale amount and date.

select * 
from(
select employee_id ,sale_date,total_sale,
rank() over(partition by employee_id order by total_sale desc)as rnk from sales 
where dayofweek(sale_date) in (1,7)
)t
where rnk =1;

# For each region, show the employee who achieved the highest total sales in 2023.**

select * 
from( 
select employee_id,region,round(sum(total_sale),2) as highest_sales,
rank() over (partition by region order by sum(total_sale) desc) as rnk  
from sales
where extract(year from sale_date)=2023
group by employee_id,region)t
where rnk=1
order by employee_id;

# Identify employees who sold all available products (Laptop, Mobile, Tablet, Monitor, Keyboard) at least once.**

select employee_id from sales
group by employee_id
having count(distinct product)=4
