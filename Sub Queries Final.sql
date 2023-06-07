# Sub Queries
# Task 1 Get the details of customer with max Customer_ID
Select *  from customer where customer_ID = (Select Max(customer_ID) from Customer);

# Task 2 Get the Customers whose last name ends with Ey.
Select * from customer where last_name Regexp 'ey$';
Select * from customer where Customer_ID in (Select Customer_ID from customer where Last_name like '%ey');

# Task 3 Find the films which are not rated Pg-13 using ALL operator
Select * from film where Film_ID <> all (Select Film_ID from film where Rating = 'PG-13');
Select * from film where exists (Select Film_ID from film where Rating = 'PG-13');

# Task 1 Construct a query against the film table that uses a filter condition with 
# a noncorrelated subquery against the category table to find all Horror films.
# Non_correlated
Select * from film where Film_ID in (select film_ID from film_category where Category_ID in 
(Select Category_ID from Category where name = 'Horror'));
# Correlated
Select * from film F where (Select film_ID from film_category FC where FC.film_ID = F.film_ID and FC.Category_ID in
(Select Category_ID from Category C where name = 'Horror'));

# Task 2 Write a query that returns all cities that are not in China.
# Non_correlated
Select * from City where Country_ID not in
(Select country_ID  from Country where Country = 'China');
# All operator
Select * from City where Country_ID <> all
(Select country_ID  from Country where Country = 'China');
# using join
Select * from city C join
Country CO on CO.country_ID = C.country_id where Country <> 'China';
# Correlated
Select * from City C Where 
(Select Country_ID from Country CO where CO.country_ID = C.country_ID and Country <> 'China');

# Task 3 Write a query that returns all cities that are in India or Pakistan.
# Correlated 
Select * from City where Country_ID in 
(Select Country_ID from Country where Country = 'India' or Country = 'Pakistan');
Select * from City where Country_ID in 
(Select Country_ID from Country where Country regexp 'india|pakistan');
Select * from City where Country_ID in 
(Select Country_ID from Country where Country in ('india', 'pakistan'));
# Non Correlated
Select * from City C Where (Select Country_ID from Country CO 
where CO.Country_ID = C.Country_ID and Country Regexp 'India|Pakistan');

# Task 4 Write a query to find all customers who have never 
# gotten a free film rental. (ie the zero amount paid for a rental). Use the all operator. 
# Non_correlated
Select * from Customer where Customer_ID not in
(Select Distinct(Customer_ID) from payment where amount = 0);
# Correlated 
Select * from Customer C where 
(Select Distinct(Customer_ID) from payment P where C.customer_ID = P.Customer_ID and amount = 0);

# Correlated Queries

# Task 1 Find the customer who has made atleast 30 payments
Select * from customer C where (select Count(*) from payment P where P.Customer_ID = C.customer_ID) >=30;

# Exists operator comes under Correlated subqueries
# Task2 Find the count of the film rated with 'PG' available in inventory
Select * from inventory I where exists (Select * from film F where F.film_ID = I.Film_ID and rating = 'PG');

# Task 3 Find the actors who have never appeared in the R-Rated Film
# Non-Correlated Subquery
Select * from actor A where actor_ID not in (Select Actor_ID from Film_actor FA where FA.actor_ID = A.actor_ID 
and Film_ID in (Select Film_ID from Film F where F.Film_ID = FA.Film_ID and Rating = 'R'));
# Correlated with Exists
Select * from actor A where not exists (Select * from Film_actor FA where FA.actor_ID = A.actor_ID 
and exists (Select Film_ID from Film F where F.Film_ID = FA.Film_ID and Rating = 'R'));

Select Distinct(A.Actor_ID), Count(F.Film_ID), F.Rating from Actor A join
Film_Actor FA on FA.Actor_ID = A.actor_ID 
Join Film F on F.Film_ID = FA.film_ID where Rating = 'R' group by A.Actor_ID, Rating order by 1 asc;


# Task 1 Write a query to count the number of film rentals for each customer and the containing 
# query then retrieves those customers who have rented exactly 30 films.

Select Customer_ID from Customer C where
(Select Count(*) from Rental R where R.customer_ID = C.customer_ID) = 30;

# Task 2 Write a query to find all customers whose total payments for all film rentals are between 100 and 150 dollars.
Select * from Customer C Where exists
(Select Customer_ID, Sum(amount) Total_payment from payment P Where P.customer_ID = C.customer_ID
group by Customer_ID having Total_payment between 100 and 150);

Select * from customer C Where (Select sum(amount) from Payment P where P.customer_ID = C.customer_ID) 
between 100 and 150;

# Task 3 Write a query to find all the customers who rented at least one film prior to June 01 2005 
# without regard for how many films were rented.
Select * from Customer C Where (Select Distinct Customer_ID from Rental R where R.customer_ID = C.Customer_ID 
and Rental_date < '2005-06-01');

# Task 4 Construct a query against the film table that uses a filter condition with a correlated subquery 
# against the category table to find all Horror films.

Select * from film F Where (Select Film_ID from Film_category FC where FC.Film_ID = F.film_ID and exists
(Select Category_ID from Category C where C.category_ID = FC.category_ID and Name = 'Horror'));

Select Film_ID from Film_category FC where 
(Select Category_ID from Category C where C.category_ID = FC.Category_ID and Name = 'Horror');

