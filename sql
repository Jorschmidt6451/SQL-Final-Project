WITH TopProducts AS (
    SELECT 
        s.product_id,
        p.product_name,
        t.store_id,
        st.store_name,
        SUM(s.quantity) AS total_quantity
    FROM 
        sales s
    JOIN 
        products p ON s.product_id = p.product_id
    JOIN 
        transactions t ON s.transaction_id = t.transaction_id
    JOIN 
        store st ON t.store_id = st.store_id
    GROUP BY 
        s.product_id, p.product_name, t.store_id, st.store_name
    ORDER BY 
        total_quantity DESC
    LIMIT 10 -- Adjust this limit for more/less top products
),
ProductSalesOverTime AS (
    SELECT 
        s.product_id,
        t.store_id,
        DATE(t.transaction_date) AS transaction_date,
        SUM(s.quantity) AS daily_quantity
    FROM 
        sales s
    JOIN 
        transactions t ON s.transaction_id = t.transaction_id
    GROUP BY 
        s.product_id, t.store_id, DATE(t.transaction_date)
)
SELECT 
    tp.product_name,
    tp.store_name,
    ps.transaction_date,
    ps.daily_quantity
FROM 
    ProductSalesOverTime ps
JOIN 
    TopProducts tp ON ps.product_id = tp.product_id AND ps.store_id = tp.store_id
ORDER BY 
    tp.store_name, tp.product_name, ps.transaction_date;




#total Sales for a time period
SELECT SUM(transaction_total) AS total_sales
FROM Transaction
WHERE date_sold BETWEEN '2024-01-01' AND '2024-12-31';


#Profitability per Store
SELECT s.store_id, 
       SUM(sales.units_sold * p.price) - SUM(e.expense_amount) AS profitability
FROM Sales AS s
JOIN Products AS p ON s.product_id = p.product_id
JOIN Expenses AS e ON s.store_id = e.store_id
WHERE s.date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY s.store_id;

#Top-Selling Products
SELECT p.product_name, SUM(s.units_sold) AS total_units_sold
FROM Sales AS s
JOIN Products AS p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_units_sold DESC
LIMIT 5;

#Customer Satisfaction Score

SELECT AVG(rating) AS avg_rating
FROM Customer_Review;

#2 Sales Insights

#Sales Trends Graph
SELECT DATE(date_sold) AS sale_date, SUM(transaction_total) AS total_sales
FROM Transaction
GROUP BY DATE(date_sold)
ORDER BY sale_date;

#Product Sales Breakdown
SELECT d.dept_name, SUM(s.units_sold) AS total_units_sold
FROM Sales AS s
JOIN Products AS p ON s.product_id = p.product_id
JOIN Departments AS d ON p.dept_id = d.dept_id
GROUP BY d.dept_name
ORDER BY total_units_sold DESC;

#Promotions Impact
SELECT p.product_name, 
       SUM(CASE WHEN pr.promotion_price IS NOT NULL THEN s.units_sold ELSE 0 END) AS promoted_sales,
       SUM(CASE WHEN pr.promotion_price IS NULL THEN s.units_sold ELSE 0 END) AS non_promoted_sales
FROM Sales AS s
JOIN Products AS p ON s.product_id = p.product_id
LEFT JOIN Product_Promotion AS pr ON p.product_id = pr.product_id AND s.date BETWEEN pr.start_date AND pr.end_date
GROUP BY p.product_name;

#3. Inventory and Waste Management

#Stock Levels by Product
SELECT product_name, units_in_stock
FROM Products
WHERE units_in_stock < 50;

#Waste Analysis
SELECT p.product_name, SUM(w.units_tossed) AS total_units_wasted, w.reason
FROM Product_Waste AS w
JOIN Products AS p ON w.product_id = p.product_id
GROUP BY p.product_name, w.reason
ORDER BY total_units_wasted DESC;

#4. Staffing and Payroll

#Employee Scheduling Overview
SELECT e.first_name, e.last_name, es.start_time, es.end_time
FROM Employee_Schedule AS es
JOIN Employee AS e ON es.employee_id = e.employee_id
WHERE es.start_time >= CURRENT_DATE;

#Employee Attendance
SELECT e.first_name, e.last_name, tt.total_hours_worked, es.schedule_id
FROM Employee_Time_Tracking AS tt
JOIN Employee AS e ON tt.employee_id = e.employee_id
JOIN Employee_Schedule AS es ON tt.schedule_id = es.schedule_id
WHERE tt.start_time >= '2024-01-01' AND tt.end_time <= '2024-12-31';

#Payroll Summary
SELECT e.first_name, e.last_name, SUM(p.total_hours_worked) AS hours_worked, SUM(p.total_hours_worked * p.hour_wage) AS total_wage
FROM Payroll AS p
JOIN Employee AS e ON p.employee_id = e.employee_id
GROUP BY e.employee_id;

#5. Customer Experience
#Feedback Dashboard

SELECT r.date, r.rating, r.comments, l.first_name, l.last_name
FROM Customer_Review AS r
JOIN Loyalty_Program AS l ON r.loyalty_number = l.loyalty_number
ORDER BY r.date DESC
LIMIT 10;

#Loyalty Program Participation
SELECT store_id, COUNT(DISTINCT loyalty_number) AS loyalty_members
FROM Transaction
GROUP BY store_id;

#6. Expense Tracking

#Expense Categories
SELECT expense_type, SUM(expense_amount) AS total_expenses
FROM Expenses
GROUP BY expense_type;

#Expense Trends
SELECT expense_date, SUM(expense_amount) AS total_expenses
FROM Expenses
GROUP BY expense_date
ORDER BY expense_date;

#7. Deliveries and Vendors
#Delivery Tracking

SELECT d.order_number, d.date, v.vendor_name, d.total_payment
FROM Deliveries AS d
JOIN Vendors AS v ON d.vendor_id = v.vendor_id
WHERE d.date >= CURRENT_DATE - INTERVAL '7 days';

#Vendor Performance
SELECT v.vendor_name, COUNT(d.product_id) AS products_delivered, SUM(d.total_payment) AS total_payment
FROM Deliveries AS d
JOIN Vendors AS v ON d.vendor_id = v.vendor_id
GROUP BY v.vendor_name;

