USE sakila;


-- Step 1: Create a View

Create VIEW Customer_rental_inf as 
Select rental.customer_id, cu.first_name, cu.email, count(rental.customer_id) as num_of_rentals
FROM rental
join customer as cu
ON rental.customer_id = cu.customer_id
group by rental.customer_id;

select *
from customer_rental_inf;

-- Step 2: Create a Temporary Table

create temporary table customer_amount as
SELECT cri.customer_id, cri.first_name, sum(pa.amount) as total_paid
From customer_rental_inf as cri
Join payment as pa
on cri.customer_id = pa.customer_id
group by cri.customer_id;

-- Step 3: Create a CTE and the Customer Summary Report

With combined as (
	Select ca.customer_id, cri.first_name, cri.email, cri.num_of_rentals, ca.total_paid
    from customer_amount as ca
    join Customer_rental_inf as cri
    on ca.customer_id = cri.customer_id
    )
Select customer_id, first_name, email, num_of_rentals, total_paid, round(AVG((num_of_rentals + total_paid ) / 2 ), 2) AS average_per_rental
From combined 
group by customer_id, email, num_of_rentals, total_paid;