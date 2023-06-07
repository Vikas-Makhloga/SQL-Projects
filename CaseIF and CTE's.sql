# Conditional Logics

# Categorize the film according the rental_rate, Cheap <= 2, Moderate 2-5, expensive > 5 
Select Film_ID, Title, Case when Rental_rate <=2 Then 'Cheap'
When Rental_rate between 2 and 5 then 'Moderate'
When Rental_rate > 5 Then 'Expensive'
Else '' End as rental_Status
from Film;

# Task 1: Write a query to generate a value for the activity_type column which returns 
# the string “Active” or “Inactive” depending on the value of the customer active column

Select Customer_ID, First_name, Last_name, Case When Active = 1 then 'Active' Else 'Inactive' end as 
Customer_status from Customer;

# Task 2 Write a query to retrieve the number of rentals for each active customer. For inactive 
# customers the result should be 0. Use case expression and correlated subquery.
Select C.First_name, C.Last_name, Case When Active = 1 then (Select Count(*) from Rental R 
Where R.customer_ID = C.Customer_ID) else 0 end as Rental_Count from Customer C;

# Task 3 Write a query to show the number of film rentals for May, June and July of 2005 in a single row.
Select 
Sum(Case when Monthname(Rental_date) = 'May' then 1 else 0 end) May_count,
Sum(Case when Monthname(Rental_date) = 'June' then 1 else 0 end) June_count,
Sum(Case when Monthname(Rental_date) = 'July' then 1 else 0 end) july_count
From Rental;

# Task 4 Write a query to categorize films based on the inventory level. (15 min)
-- If the count of copies is 0 then ‘Out of stock’
-- If the count of copies is 1 or 2  then ‘Scarce’
-- If the count of copies is 3 or 4 then ‘Available’
-- If the count of copies is >= 5 then ‘Common’
Select Film_ID, Title, case (Select Count(film_ID) from inventory I where I.film_ID = F.film_ID)
when 0 then 'out of stock'
when 1 and 2 then 'scarce'
when 3 and 4 then 'available'
else 'common' end Inventory_status from Film F;
Select * from inventory;
Select film_ID, case (Select Count(film_ID) from inventory group by Film_ID)
	when 1 then 'scarce'
	when 2 then 'scarce'
	when 3 then 'available'
	when 4 then 'available'
	else 'common' end Inventory_status from inventory;

# Task 5 Write a query to get each customer along with their total payments, number of payments and average payment
With Rental as
(select Customer_ID, Count(*) No_of_payment, Sum(Amount) as Total_payment, avg(amount)as average_payment
From Payment group by customer_ID order by 1 asc),
Customer as
(Select Customer_ID, First_name, Last_name from Customer)
Select C.customer_ID, C.first_name, C.last_name, no_of_payment, TOtal_payment, Average_payment from Customer C join
Rental R on R.customer_ID = C.customer_ID;

# Task 6 Write a query to create a single row containing the number of films based on the ratings (G, PG and NC17)
Select
Sum(case when Rating = 'G' then 1 else 0 end) as G_ratings,
Sum(case when Rating = 'PG' then 1 else 0 end ) as PG_ratings,
Sum(case when Rating = 'NC-17' then 1 else 0 end) as NC_17_ratings
from Film;

# Task 1 Create a CTE with two named subqueries. The first one gets the actors with last names starting with s. 
# The second one gets all the pg films acted by them. Finally show the film id and title.
With CTE1 as
(select Actor_ID, First_name, Last_name from Actor where last_name like 's%'),
CTE2 as
(Select F.film_ID, F.Title, F.Rating, A.actor_ID from film F 
Join Film_actor FA on FA.film_ID = F.film_ID
join Actor A on A.actor_ID = FA.actor_ID 
where A.Actor_ID in (Select Actor_ID from CTE1) and rating = 'PG')
Select * from CTE2;

# Task 3 Add one more subquery to the previous CTE to get the revenues of those movies
With CTE1 as
(select Actor_ID, First_name, Last_name from Actor where last_name like 's%'),
CTE2 as
(Select F.film_ID, F.Title from film F 
Join Film_actor FA on FA.film_ID = F.film_ID
join Actor A on A.actor_ID = FA.actor_ID 
where A.Actor_ID in (Select Actor_ID from CTE1) and rating = 'PG'),
CTE3 as
(Select F.film_ID, Concat (sum(Amount), '$') as Revenue_Generated from payment P 
Join Rental R on R.customer_ID = P.Customer_ID
Join Inventory I on I.inventory_ID = R.inventory_ID
join Film F on F.film_ID =I.film_ID where F.film_ID in (select Film_ID from CTE2) group by F.Film_ID) 
Select CTE2.film_ID, TItle, Revenue_Generated from CTE2 left Join CTE3 on 
Cte3.film_ID = CTE2.film_ID order by 1 asc;

# Task 1 Find the films which are rented by both Indian and Pakistani customers. (Hint: You can use CTE’s)
With India as
(Select F.FIlm_ID, C.Customer_ID, Title, C.first_name, C.last_name from Film F 
Join Inventory I on I.film_ID = F.film_ID
Join Rental R on R.inventory_ID = I.inventory_ID
Join Customer C on C.customer_ID = R.customer_ID 
Where C.Customer_ID in 
(Select C1.Customer_ID from Customer C1 Join
Address A on A.address_ID = C1.address_ID
Join City CI on CI.city_ID = A.city_ID
Join Country CO on CO.country_ID = CI.country_ID
where Country = 'India') order by C.customer_ID), 
Pakistan as 
(Select F.FIlm_ID, Title, C.CUstomer_ID, C.First_name, C.last_name from Film F 
Join Inventory I on I.film_ID = F.film_ID
Join Rental R on R.inventory_ID = I.inventory_ID
Join Customer C on C.customer_ID = R.customer_ID 
Where C.Customer_ID in 
(Select C1.Customer_ID from Customer C1 Join
Address A on A.address_ID = C1.address_ID
Join City CI on CI.city_ID = A.city_ID
Join Country CO on CO.country_ID = CI.country_ID
where Country = 'Pakistan') order by C.customer_ID)

Select distinct P.title from India I 
Join Pakistan P on P.title = I.title;

# Find the films (if any) which are rented by Indian customers and not rented by Pakistani customers.
With CTE1 as 
(Select C.Customer_ID, CO.Country from Customer C
Join Address A on A.Address_ID = C.Address_ID
Join City CI on CI.City_ID = A.City_ID
Join Country CO on CO.Country_ID = CI.Country_ID
where Country = 'Pakistan'),
CTE2 as 
(Select F.Film_ID, C.customer_ID, Title from FIlm F 
Join Inventory I on I.film_ID = F.film_ID
join Rental R on R.inventory_ID = I.inventory_ID
Join Customer C on C.customer_ID = R.customer_ID
where C.Customer_ID in (Select Customer_ID from CTE1)),
CTE3 as
(Select C.Customer_ID, CO.Country from Customer C
Join Address A on A.Address_ID = C.Address_ID
Join City CI on CI.City_ID = A.City_ID
Join Country CO on CO.Country_ID = CI.Country_ID
where Country = 'India'),
CTE4 as
(Select F.Film_ID, C.customer_ID, Title from FIlm F 
Join Inventory I on I.film_ID = F.film_ID
join Rental R on R.inventory_ID = I.inventory_ID
Join Customer C on C.customer_ID = R.customer_ID
where C.Customer_ID in (Select Customer_ID from CTE3)),
CTE5 as 
(Select CTE4.title from CTE4 where CTE4.Title not in (Select CTE2.Title from CTE2))
select * from CTE5;

# Task 4 Write a SQL query that displays the title and rental rate of all films, and adds a new column called 
# "Rental Status" that indicates whether the film is currently available for rent or not. If the film has no 
# available copies, the Rental Status should be "Not Available"

Select F.film_ID, F.Title, F.Rental_rate, Case (Select Count(*) from Inventory I where I.film_ID = F.film_ID)
When 0 Then 'Not available' else 'Available' end Rental_status
from film F having Rental_status = 'Not available';
