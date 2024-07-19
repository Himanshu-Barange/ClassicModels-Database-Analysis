use classicmodels;

show tables;

	-- rank customers by their credit limits - first approach
select *, rank() over(order by creditlimit desc) as Ranking
from customers;

	-- rank customers by their credit limits - second approach
select *, dense_rank() over(order by creditlimit desc) as Ranking
from customers;

	-- country-wise rank customers by their credit limits
select *, dense_rank() over(partition by country order by creditLimit desc) Ranking
from customers;
	
    -- country-wise percentile rank customers by their credit limits
select *, percent_rank() over(partition by country order by creditLimit desc) PercentileRank
from customers;

	-- find 3rd larget credit limit in each country
select *, nth_value(creditLimit, 3) over(partition by country order by creditLimit desc) 3rdLargestCreditLimit
from customers;

	-- Find the name of the person with the largest credit limit in each country
select *, first_value(customerName) over(partition by country order by creditLimit desc) FirstPerson
from customers;

	-- Find the name of the person with lowest credit limit in each country
select *, 
		last_value(CustomerName) over(partition by country 
										order by creditlimit desc
                                        range between unbounded preceding and unbounded following) LeastCustomer
from customers;

	-- average lag between orders for customers
select CustomerNumber, CustomerName, avg(lagdays) Average_Lag_Days
from
(select c.CustomerNumber,
		c.CustomerName,
        datediff(o.OrderDate, lag(o.OrderDate, 1) over(partition by c.customerNumber order by orderdate)) as lagdays
from customers c
left join orders o using (customerNumber)
) sq1
where lagdays is not null
group by CustomerNumber;
    
    -- average lag days between orders
select avg(Average_Lag_Days) Average_of_Lag_Days
from 
(select CustomerNumber, CustomerName, avg(lagdays) Average_Lag_Days
from
(select c.CustomerNumber,
		c.CustomerName,
        datediff(o.OrderDate, lag(o.OrderDate, 1) over(partition by c.customerNumber order by orderdate)) as lagdays
from customers c
left join orders o using (customerNumber)
) sq1
where lagdays is not null
group by CustomerNumber 
) sq1;


	-- sales amount for each country
select *, sum(od.quantityOrdered * priceEach) over(partition by country) Sales
from customers c
join orders o using(customerNumber)
join orderdetails od using(orderNumber)
order by Sales desc;
    
