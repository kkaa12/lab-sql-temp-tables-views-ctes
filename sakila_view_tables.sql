-- In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, including their rental history and payment details. 
-- The report will be generated using a combination of views, CTEs, and temporary tables.

USE sakila;

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW rental_summary AS
SELECT c.customer_id, c.first_name, c.last_name, c.email, COUNT(r.rental_id) AS rental_count from sakila.customer AS c
JOIN sakila.rental as r
ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

SELECT * FROM rental_summary;


-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT rs.customer_id, rs.first_name, rs.last_name, rs.email, rs.rental_count,SUM(p.amount) AS total_paid
FROM rental_summary AS rs
JOIN sakila.payment AS p 
ON rs.customer_id = p.customer_id
GROUP BY rs.customer_id, rs.first_name, rs.last_name, rs.email;

SELECT * FROM customer_payment_summary;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.
-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
WITH cte_customer AS(
SELECT rs.first_name, rs.last_name, rs.email, rs.rental_count, cp.total_paid
FROM rental_summary AS rs
JOIN customer_payment_summary AS cp 
ON rs.customer_id = cp.customer_id
)
SELECT ct.first_name, ct.email, ct.rental_count, ct.total_paid, 
ROUND((ct.total_paid/ct.rental_count),2) AS average_payment_per_rental FROM cte_customer AS ct;



