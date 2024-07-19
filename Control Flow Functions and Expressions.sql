use classicmodels;

show tables;

	-- Categorize customers based on their credit limits as Important and General
select *, 
		case
			when creditlimit > (select avg(creditLimit) from customers) then "Important"
            when creditlimit <= (select avg(creditlimit) from customers) then "General"
		end Category
from customers;

	-- The previous query using if statement
select *,
		if(creditlimit > (select avg(creditlimit) from customers), "Important", "General") Category
from customers;

	-- get all the customers and blank out the CustomerNames for below average creditlimit customers
select CustomerNumber, if(creditlimit > (select avg(creditlimit) from customers), CustomerName, "") CustomerName 
from customers;

	-- Retrieve all the state and return Not Available for null values
select ifnull(state, "Not Available") State
from customers;

	-- Retrieve all the countries and nullify for USA
select country, nullif(country, "USA") "No USA"
from customers;
	
	-- Substituting null values
select coalesce(state, "Nothing")
from customers;