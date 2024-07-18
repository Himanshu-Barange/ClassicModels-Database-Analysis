use classicmodels;

show tables;

	-- create procedure
delimiter //
create procedure Employees()
begin
select * from employees;
end //
delimiter ;

	-- call procedure
call Employees;

	-- Add Comment to a procedure
alter procedure Employees comment 'This is a comment';

	-- Change a comment on a procedure
alter procedure Employees comment 'This procedure extracts all data from employees table';

	-- Changeable characteristics of a procedure
-- characteristic: {
--    COMMENT 'string'
--  | LANGUAGE SQL
--  | { CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA }
--  | SQL SECURITY { DEFINER | INVOKER }}

	-- Put kind of an annotation to a procedure
alter procedure Employees reads sql data;

	-- see comments and annotations on a procedure; see the Create Procedure cell of the result table
show create procedure employees;
    
    -- Add parameters to a procedure
delimiter //
create procedure find_employees(job_title varchar(50))
begin
select *
from employees
where jobTitle = job_title;
end //
delimiter ;

	-- call the parameterized procedure
call find_employees('Sales Rep');

	-- changing the query in the procedure
		-- first drop the previous then create new
        -- you cannot change the query or parameters in a procedure
drop procedure if exists find_employees;

delimiter //
create procedure find_employees(job_title varchar(50))
begin
select *
from employees
where jobTitle = job_title;
end //

delimiter ;

	-- call the changed procedure
call find_employees('VP Marketing');

	-- Using multiple parameters in a procedure
delimiter //
create procedure findEmployeeManagers(job_title varchar(50), manager_id int)
begin
select *
from employees e1
join employees e2 on e1.reportsTo = e2.employeeNumber
where e1.jobTitle = job_title and e1.reportsTo = manager_id;
end //
delimiter ;

call findEmployeeManagers('Sales Rep', 1056);
