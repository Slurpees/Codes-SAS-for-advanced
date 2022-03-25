/*
ST556 HW6, Kaida Lou, 3-25-2022
This program is used for hw6.
It read or require the data set employee_addresses,
                       order_fact, product_dim, sal2015
*/
libname hw6 "S:\ST556\HW6";
/*Problem 1(a)(b)
take a glance at tables of order_fact and product_dim
*/
proc sql;
  describe table hw6.order_fact;
quit;

proc sql;
  describe table hw6.product_dim;
quit;

/*Problem 2(c)
  Print the first five rows of orion.product dim after 
  sorting by Product ID, selecting only those columns with
  these labels: Product ID., Product Category and Product Name.
*/
proc sql outobs = 5;
  select Product_id "Product ID.",
         Product_category "Product Category",
         Product_name "Prodcut Name"
  from hw6.product_dim
  order by Product_id
  ;
quit;

/*Problem 2(d)
  using the count() funtion in order to get how many rows are 
  in the order_fact. The answer is 617.
*/
proc sql;
  select count(*) as number "#rows"
  from hw6.order_fact
  ;
quit;

/*Problem 2(e)
  count the different values of order_id in table order_fact.
  The answer is 490.
*/
proc sql;
  select count(distinct order_id) as number "# diff order_id"
  from hw6.order_fact
  ;
quit;

/*Problem 2(f)
  count the different values of discount in table order_fact.
  The answer is 2.
*/
proc sql;
  select count(distinct discount) as number "# diff discount"
  from hw6.order_fact
  ;
quit;

/*Problem 2
  Modify the program below (s102a05) so that only those employees
  with first names starting with J are selected in the query.
*/
proc sql feedback;
  select Employee_Name, Employee_ID
  from hw6.employee_addresses
  where employee_name like "J%"
  ;
quit;

/*Problem 3(a)  */
libname mlb "S:\ST556\HW6";
proc sql feedback ;
  select * from mlb.sal2015 ;
run;
proc sql feedback ;
  select * from mlb.sal2015 ;
quit;
proc sql ;
  describe table mlb . sal2015 ;
quit;

/*Problem 3(a)
  What message was included in the log because of
  the use of the run; statement?

  The answer is: NOTE: PROC SQL statements are executed immediately;
                 The RUN statement has no effect.
*/

/*Problem 3(b)
  What variable type is the column named opening? 
  Is it character? numeric?

  The answer is: num.
*/

/*Problem 3(c)
 Describe and contrast the function of the feedback option 
 and the DESCRIBE statement in PROC SQL

 Answer:
 The feedback option expands a select * satement into the list 
   of columns that statement represents. For example, in this program
   the select * was expanded to "select SAL2015.year, SAL2015.sport, 
   SAL2015.Team, SAL2015.rank, SAL2015.opening,SAL2015.Current, 
   SAL2015.Avgsal, SAL2015.medsal". 
 The describe statement in proc sql displays a sql definition in the 
   SAS log. For example, in this program the describe table displays
   the table mlb.sal2015's buffzie and names and attributes of all 
   columns.
  The difference between the two ones is that the former is a debug 
  process for the coding. But the latter is to display a result.
*/

/*Problem 3(d)
  Modify the style of the middle proc sql code (three lines) by 
  putting all SAS syntax into upper case and all user-specified 
  names in lower case. Include here your modified (but equivalent!)
  code.
  It is prettier now I think !!
*/
PROC SQL FEEDBACK;
  SELECT * FROM mlb.sal2015 ;
RUN;
PROC SQL FEEDBACK;
  SELECT * FROM mlb.sal2015 ;
RUN;
PROC SQL;
  DESCRIBE TABLE mlb.sal2015 ;
QUIT;

/*Problem 3(e)
   Write an SQL query that produces a table with two columns, 
   team name and opening salary (unformatted).
*/
proc sql;
  create table three_e as 
  select team, opening
  from mlb.sal2015
  ;
quit;

/*
  Problem 3(f)
  Modify your query so that the column with opening salary, 
  which is in the hundreds of millions of samoleans (dollars), 
  has the heading "Opening Salary" and has a format of the form
  $xxx,xxx,xxx.
*/
proc sql;
  create table three_f as 
  select team, 
         opening "Opening Salary" format = dollar12.
  from mlb.sal2015
  ;
quit;

/*Problem 3(g)
  Modify your code so that it the teams are ordered by opening 
  salary, in increasing order, so that the (dis)Astros come first, 
  (for once). Include an appropriate title to the report created by the
  query.
*/
proc sql;
  title "Report ordered by the opening salary";
  select team, 
         opening "Opening Salary" format = dollar12.
  from mlb.sal2015
  order by opening
  ;
quit;
title"";
