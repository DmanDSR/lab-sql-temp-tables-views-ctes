USE sakila;


-- Step 1: Create a View

-- Create VIEW Customer_rental_inf as 
-- Select rental.customer_id, cu.first_name, cu.email, count(rental.customer_id) as num_of_rentals
-- FROM rental
-- join customer as cu
-- ON rental.customer_id = cu.customer_id
-- group by rental.customer_id;

CREATE OR REPLACE VIEW Customer_rental_info AS 
SELECT r.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS full_name, c.email, COUNT(r.rental_id) AS rental_count
FROM rental r
JOIN customer c ON r.customer_id = c.customer_id
GROUP BY r.customer_id;

select *
from customer_rental_info;

-- Step 2: Create a Temporary Table

-- create temporary table customer_amount as
-- SELECT cri.customer_id, cri.first_name, sum(pa.amount) as total_paid
-- From customer_rental_inf as cri
-- Join payment as pa
-- on cri.customer_id = pa.customer_id
-- group by cri.customer_id;

CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT cri.customer_id, SUM(p.amount) AS total_paid
FROM Customer_rental_info cri
JOIN payment p ON cri.customer_id = p.customer_id
GROUP BY cri.customer_id;

-- Step 3: Create a CTE and the Customer Summary Report

-- With combined as (
-- 	Select ca.customer_id, cri.first_name, cri.email, cri.num_of_rentals, ca.total_paid
--     from customer_amount as ca
--     join Customer_rental_inf as cri
--     on ca.customer_id = cri.customer_id
--     )
-- Select customer_id, first_name, email, num_of_rentals, total_paid, round(AVG((num_of_rentals + total_paid ) / 2 ), 2) AS average_per_rental
-- From combined 
-- group by customer_id, email, num_of_rentals, total_paid;

WITH Customer_Summary AS (
    SELECT cri.customer_id, cri.full_name, cri.email, cri.rental_count, cps.total_paid
    FROM Customer_rental_info cri
    JOIN customer_payment_summary cps 
    ON cri.customer_id = cps.customer_id
)
SELECT customer_id, full_name, email, rental_count, total_paid, ROUND(total_paid / rental_count, 2) AS average_payment_per_rental
FROM Customer_Summary;