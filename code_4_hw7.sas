/*
ST556 HW7, Kaida Lou, 4-8-2022
This program is used for hw7.
It read or require the data set employee_addresses,
                       order_fact, product_dim, staff
					   mlb2010, employee_organization
*/
libname hw7 "S:\ST556\HW7";
/*Problem 1
  Write a defined macro called firstletter that can be used
  to generate the same code as in your solution for HW6,
  problem 2, but for any letter.
*/
%macro firstletter(start);
  proc sql feedback;
    select Employee_Name, Employee_ID
    from hw7.employee_addresses
    where employee_name contains ", &start"
    ;
  quit;
%mend firstletter;

%firstletter(D)
/*************************/
/*Problem 2(a)
  List the MLB teams that scored fewer runs (rs variable) 
  than average in 2010
*/
proc sql;
  title "Records of team that have runs less than the average";
  select team, league, rs
  from hw7.mlb2010
  having rs < avg(rs)
  ;
quit;

/*Problem 2(b)
 List the MLB teams that scored fewer runs than the 
 average in their league (AL,NL) in 2010.
*/
proc sql;
  title "Records of team that scored fewer runs than the
         average in their league";
  select team, league, rs
  from hw7.mlb2010
  group by league
  having rs < avg(rs)
  order by rs 
  ;
quit;
/*Problem 2(c)
  reproduce the table in part (b) using constant text, “<”,
  in an appropriate place to help a reader better see the 
  relationship between a team’s runs and the league average.
*/
proc sql;
  title "Records of team that scored fewer runs than the
         average in their league";
  select team, league, rs, "<", avg(rs) lable="league avg"
  from hw7.mlb2010
  group by league
  having rs < avg(rs)
  order by rs DESC
  ;
quit;

/**********************/
/*Problem3. explain what a left outer join is:
  Answer: Combining tables into one by returing all matching 
  rows(key values) plus nonmatching rows from left table.
*/

/********************/
/*Problem4.How many rows would be in a cartesian join 
 two tables A and B, if the number of respective rows is 
 rA = 15,rB = 100?
Answer: 15*100 = 1500
*/

/********************/
/*Problem 5
Using an inner join with orion.product dim and orion.order fact, 
compute the profit for each of the three items sold at a discount
and generate the following table :
*/
title;
proc sql;
  select coalesce(a.Product_ID) format = best., Product_Name,
         (total_retail_price - quantity*costprice_per_unit)'total profi',
         discount 'disc'
  from hw7.product_dim as a, hw7.order_fact as f
  
  where discount is not missing and a.product_id = f.product_id
  order by a.Product_Id desc
  ;
quit;
/***************/
/*Problem6.Use two or three of these tables: orion.employee 
addresses, orion.staff and orion.employee organization 
to create a report of all trainees and temporary workers at Orion.
*/
proc sql;
  select o.employee_id, a1.employee_name, o.Job_title, 
         o.Manager_ID, a2.employee_Name 'Manager_Name'
  from hw7.employee_addresses as a1
       inner join 
	   hw7.employee_organization as o
	   on a1.employee_ID = o.employee_ID
	   inner join 
       hw7.employee_addresses as a2
	   on o.manager_Id = a2.employee_ID
  where o.job_title contains "Trainee" OR o.job_title contains "Temp"
  order by a2.employee_Name, a1.Employee_Name
  ;
quit;








