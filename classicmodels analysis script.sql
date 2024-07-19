use classicmodels;

show tables;

	-- peeking the tables
select * from employees;
select * from customers;
select * from orders;
select * from orderdetails;
select * from offices;
select * from payments;
select * from productlines;
select * from products;

	-- Employee Count
select count(distinct(employeeNumber)) as EmployeeCount
from employees;

	-- Customers Count
select count(distinct(customerNumber)) as CustomerCount
from customers;

	-- Customer Countries
select distinct(Country)
from customers;

	-- Country and State wise Customer Count
select Country, 
		State, 
        count(distinct(customerNumber)) as CustomerCount, 
        if(grouping(State) = 0, '', concat_ws(" ", Country, 'SubTotal')) CountrySubtotal,
        if(grouping(Country) = 0, '', "Grand Total") Total
from customers
group by Country, State with rollup
order by Country, CustomerCount desc;

	-- Top 10 Customers By Credit Limit - First Approach
select *
from customers
order by creditLimit desc
limit 10;

	-- Top 10 Customers By Credit Limit - 2nd Approach
select *
from
	(select *, dense_rank() over(order by creditlimit desc) as ranking
	from customers) as subquery1
where ranking <= 10;

	-- Total Credit Limit Given to Customers
select sum(creditLimit) as TotalCredits
from customers;

	-- Total Credit Limit Given to "Top 10 Customers By CreditLimit"
select sum(creditLimit) as "Total Credits of Top 10 Customers"
from 
	(select creditLimit
	from customers
	order by creditLimit desc
	limit 10) as sq1;

	-- Total Credit Limit of Top 10 Customers as a percentage of the total credit
with totalCredits as
(
select sum(creditlimit)
from customers
),
top10Credits as
(
select creditLimit
from customers
order by creditLimit desc
limit 10
)
(select truncate(sum(creditlimit) / (select * from totalcredits) * 100, 2) as Top10CreditPercentage 
from top10credits);


	-- Total Sale in the database
select sum(amount) as "Total Revenue"
from payments;

	-- Yearly Sale
select year(paymentDate) as Year, sum(amount) as Sale
from payments
group by Year;

	-- Monthly Sale for each Year
select Year(paymentDate) Year, month(paymentDate) Month, sum(amount) as Sale
from payments
group by Year, Month
order by Year, Month;

	-- Highest value cheque and payer
select *
from payments
order by amount desc
limit 1;
    
    -- Top 5 Customers by amount
select c.CustomerNumber, sum(p.amount) as TotalPayment
from customers c
left join payments p on c.customerNumber = p.customerNumber
group by c.customerNumber
order by TotalPayment desc
limit 5;

	-- Top 5 Customer by Payment Percentage
select c.CustomerNumber, truncate(sum(p.amount) / (select sum(amount) from payments) * 100, 2) as PaymentPercentage
from customers c
left join payments p on c.customerNumber = p.customerNumber
group by c.customerNumber
order by PaymentPercentage desc
limit 5;

	-- Product and ProductLine Counts
select count(distinct(ProductCode)) as Products,
		count(distinct(ProductLine)) as ProductLines
from products;
    
	-- Products in each ProductLine
select ProductLine, count(productcode) as ProductsCount
from products
group by ProductLine;
    
    -- Check if two products are in the same productLine (it shouldn't be, but maybe by mistake)
select productName
from products p1
where productName in
(select productName from products p2 where p2.productLine <> p1.productLine);

	-- Average Time for Shipping an Order
select avg(datediff(shippedDate, orderDate)) as 'Average Days'
from orders;

	-- Average Time for Delivering an Order
select avg(datediff(requiredDate, orderDate)) as 'Average Days'
from orders;

	-- order status types
select distinct(status)
from orders;

	-- order counts for each order status
select Status, count(orderNumber) 'Number Of Orders'
from orders
group by Status
order by   'Number of Orders' desc;

	-- Employees and their Managers
select concat_ws(" ", e1.firstName, e1.lastName) as Name,
		concat_ws(" ", e2.firstName, e2.lastName) as Manager
from employees e1
join employees e2 on e1.reportsTo = e2.employeeNumber;

	-- Name of all Managers
select concat_ws(" ", firstName, lastName) as Name
from employees
where employeeNumber in (
	select distinct(reportsTo)
    from employees
);

	-- Count employees of each manager
select 
	e1.reportsTo, 
	concat_ws(" ", e2.firstName, e2.lastName) as Manager, 
    count(e1.employeeNumber) as EmployeeCounts
from employees e1
join employees e2 on e1.reportsTo = e2.employeeNumber
group by e1.reportsTo
order by EmployeeCounts desc;

	-- Which employee is manager Mami Nishi supervising?
select *
from employees
where reportsTo = 1621;

	-- Count of Sales Representatives
select count(employeeNumber) as 'Number of Sales Representatives'
from employees
where jobTitle = 'Sales Rep';

	-- Sales of each sales representative
select e.EmployeeNumber,
		concat_ws(" ", firstName, lastName) as EmployeeName,
        sum(od.quantityOrdered * od.priceEach) as Sales
from
employees e
left join customers c on e.employeeNumber = c.salesRepEmployeeNumber
join orders o on c.customerNumber = o.customerNumber
join orderdetails od on o.orderNumber = od.orderNumber
group by e.EmployeeNumber
order by Sales desc;

	-- Top 10 Sales Representatives by Sales
select e.EmployeeNumber,
		concat_ws(" ", firstName, lastName) as EmployeeName,
        sum(od.quantityOrdered * od.priceEach) as Sales
from
employees e
left join customers c on e.employeeNumber = c.salesRepEmployeeNumber
join orders o on c.customerNumber = o.customerNumber
join orderdetails od on o.orderNumber = od.orderNumber
group by e.EmployeeNumber
order by Sales desc
limit 10;

	-- Bottom 10 Sales Representatives by Sales
select e.EmployeeNumber,
		concat_ws(" ", firstName, lastName) as EmployeeName,
        sum(od.quantityOrdered * od.priceEach) as Sales
from
employees e
left join customers c on e.employeeNumber = c.salesRepEmployeeNumber
join orders o on c.customerNumber = o.customerNumber
join orderdetails od on o.orderNumber = od.orderNumber
group by e.EmployeeNumber
order by Sales
limit 10;

	-- Received Sales of each sales representative
select e.EmployeeNumber,
		concat_ws(" ", firstName, lastName) as EmployeeName,
        sum(p.amount) as Sales
from
employees e
left join customers c on e.employeeNumber = c.salesRepEmployeeNumber
join payments p on c.customerNumber = p.customerNumber
group by e.EmployeeNumber
order by Sales desc;

	-- Difference between the Sales and Earned Sales of each sales representative
With Table1 as
(select e.EmployeeNumber,
		concat_ws(" ", firstName, lastName) as EmployeeName,
        sum(od.quantityOrdered * od.priceEach) as Sales
from
employees e
left join customers c on e.employeeNumber = c.salesRepEmployeeNumber
join orders o on c.customerNumber = o.customerNumber
join orderdetails od on o.orderNumber = od.orderNumber
group by e.EmployeeNumber
order by Sales desc),
Table2 as
(select e.EmployeeNumber,
		concat_ws(" ", firstName, lastName) as EmployeeName,
        sum(p.amount) as Sales
from
employees e
left join customers c on e.employeeNumber = c.salesRepEmployeeNumber
join payments p on c.customerNumber = p.customerNumber
group by e.EmployeeNumber
order by Sales desc)

select T1.employeeNumber, (T1.Sales - T2.Sales) as Difference
from Table1 as t1
left join Table2 as t2 on t1.employeeNumber = t2.employeeNumber
order by Difference desc;    
    
	-- Cumulative Yearly Distribution of Sale
select *, year(paymentDate) Year, Month(paymentDate) Month, cume_dist() over(partition by year(paymentDate) order by paymentDate, amount desc) as Cum_Dist
from payments;

	-- Create a procedure for getting Employee and their Manager names
delimiter //
create procedure get_managers()
begin
select concat_ws(" ", e1.firstName, e1.lastName) Employee,
		concat_ws(" ", e2.firstName, e2.lastName) Manager
from employees e1
join employees e2 on e1.reportsTo = e2.employeeNumber
order by Manager;
end //
delimiter ;

call get_managers;

	-- create all possible combinations of managers and employees
with Managers as
(select distinct(concat_ws(" ", e2.firstName, e2.lastName)) Manager
from employees e1
join employees e2 on e1.reportsTo = e2.employeeNumber
order by Manager),
Employees as
(select concat_ws(" ", firstName, lastName) Employee
from Employees)

select *
from Managers m
cross join Employees e on m.Manager <> e.Employee;

select * from employees;
select * from customers;
select * from orders;
select * from orderdetails;
select * from payments;
show tables;