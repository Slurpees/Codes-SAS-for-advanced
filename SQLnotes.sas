libname orion "S:\ST556\ORION\macro_materials\macro_materials";
/**2.2 challenge 4 **/
proc sql ;
  create table orion.staff
  select Employee_ID, 
    case (scan(Job_title, -1, " "))
      when "Manager" then "Manager"
	  when  
	  when 
	  else "N/A"
	end as Level,
    Salary,
    case(calculated Level)
	  when "Manager" then 
	    case
		  when (Salary>72000) then "high"
		  when then 
		  else "low"
		end
	  when
        case 
	    end
    end as Salary_Range
  from orion.staff
  where calcualted level ne "N/A"
  order by Level, Salary desc
  ;
quit;

/*Section 2.3*/
proc sql;
  select distinct city 
  from orion.employee_addresses
  ;
quit;

proc sql;
  select Employee_ID, Recipients, sum(Qtr1) as Total
  from orion.employee_donations
  where calculated Total > 90
;
quit;

/*section 3 */
proc sql;
  title "Single Male Employee Salaries";
  select Employee_ID, Salary format = comma10.2, Tax format = comma10.2
  from orion.employee_payroll
  order by Salary DESC
  ;
quit;

proc sql;
  title"Australian Clothing Products.";
  select Supplier_Name format = $18. label = "Supplier", 
         Product_Group format = $12., 
         Product_Name format = $30.
  from orion.product_dim
  where Product_Category = "Clothes" and Supplier_Country = "AU"
  order by Product_Name
  ;
quit;


proc sql;
  title "this is a title";
  select Customer_ID format = z7., catx(",", Customer_LastName,Customer_FirstName) as customer_name format = $20. label = "Last_name, First_name",
         Gender, int((-Birth_Date+"02FEB2013"d)/365.25) as Age
  from orion.customer
  where calculated Age > 50 and country = "US"
  order by age DESC, customer_name
  ;
quit;
title;

/*section 3.2*/
proc sql;
  select City, count(*) as Count 
  from orion.employee_addresses
  group by City
  order by City
  ;
quit;

proc sql;
  select Employee_ID, Birth_Date, Employee_Hire_Date, int((Employee_Hire_Date-Birth_Date)/365.25) as Age
  from orion.employee_payroll
  ;
quit;

proc sql;
  select count(*) as num_customers, sum(Gender="M") as num_male, sum(Gender="F") as num_female,
         calculated num_male / calculated num_customers as Pct
  from orion.customer
  group by counTry
  order by Pct
  ;
quit;

proc sql;
  title "Countries with More Female than Male Customers.";
  select Country, sum(Gender="M") as num_male, sum(Gender="F") as num_female
  from orion.customer
  group by counTry
  having num_male < num_female
  order by num_female DESC
  ;
quit;
title;

proc sql;
  select upcase(country), propcase(city), count(*) as Employees
  from orion.employee_addresses
  group by 1, 2
  order by 1, 2
  ;
quit;

/*Section 4*/
proc sql;
  select a.Employee_Name as Name, 
         int(('1FEB2013'd - p.Employee_Hire_Date)/365.25) as YOS
  from orion.employee_addresses as a inner join orion.employee_payroll as p 
    on a.Employee_ID = p.Employee_ID
  where calculated YOS > 30
  order by Name
  ;
quit;

proc sql;
  select d.Product_ID, Product_Name, Sum(Quantity) as total "Total Sold"
  from orion.product_dim as d inner join orion.order_fact as o
    on d.Product_ID = o.Product_ID and Order_Date>='01Jan2010'd
  group by d.Product_ID, Product_Name
  order by total DESC, Product_Name
  ;
quit;

proc sql;
  select Customer_Name, Count(*) as Count
  from orion.product_dim as d inner join orion.order_fact as f
    on d.product_id = f.product_id inner join orion.customer as c
	on f.Customer_id = c.Customer_ID
  where d.Supplier_country ne Country and Country in ("US", "AU")
        and EMployee_ID = 99999999
  group by Customer_Name
  order by Count DESC, Customer_Name
  ;
quit;

/*section 4.3*/
proc sql;
  select Employee_Name, City, Job_Title
  from orion.sales as s right join orion.employee_adresses as a
    on s.Employee_ID = a.Employee_ID
  order by city, job_title, Employee_name
  ;
quit;

proc print data = orion.order_fact(obs =10);

run;

proc print data = orion.product_dim(obs =10);

run;

proc sql;
  select Product_Name,
       p.Product_ID,
        Quantity
  from orion.order_fact as o right join orion.product_dim as p 
    on o.product_id = p.product_id
  where order_id is missing
  ;
quit;

/*section 4.4*/
proc sql;
  select s1.employee_ID, e1.employee_Name, s1.Job_title, s1.Manager_ID, e2.Employee_Name
  from orion.staff as s1,
	   orion.employee_addresses as e1,
	   orion.employee_addresses as e2
  where s1.Employee_id = e1.Employee_ID and s1.Manager_ID = e2.Employee_ID and((Job_Title contains 'Trainee' or
          Job_Title contains 'Temp'))
  order by s1.employee_ID
  ;
quit;

proc print data = orion.employee_addresses (obs = 1);
run;
proc print data = orion.employee_payroll (obs = 1);
run;

proc print data = orion.employee_organization (obs = 1);
run;


proc sql;
  select a1.employee_Name,
         int(("01FEB2013"d - b.Employee_Hire_Date)/365.25) as YOS,
         c.Manager_ID,a2.Employee_Name
  from orion.employee_addresses as a1,
       orion.employee_addresses as a2,
       orion.employee_payroll as b, 
       orion.employee_organization as c
  where YOS > 30 and a1.employee_ID = b.employee_ID and 
        a1.employee_ID = c.employe_ID and
        a2.employee_ID = c.Manager_ID
  order by a2.Employee_Name, YOS DESC, a1.employee_Name
;
quit;

/*Section 5*/
proc sql;
  select avg(Total_Retail_Price)
  from orion.order_fact
  where order_Type = 1
  ;
quit;

proc sql;
  select Customer_ID, avg(Total_Retail_Price) as MeanPrice
  from orion.order_fact
  where Order_Type = 1
  group Customer_ID
  having MeanPrice > (select avg(Total_Retail_Price)
  from orion.order_fact
  where order_Type = 1)
  ;
quit;

proc sql;
  select Employee_ID
  from orion.employee_payroll
  where month(Employee_Hire_Date) = month(today())
  ;
quit;

proc sql;
  select month(today()), employee_ID, scan(employee_name,1,",") as First
         , scan(employee_name,2,",") as Second
  from orion.employee_addresses
  where employee_ID = any( select Employee_ID
  from orion.employee_payroll
  where month(Employee_Hire_Date) = month(today()))
  ;
quit;

proc sql;
  select Employee_ID, Job_Title, Birth_Date, 
         int(("02FEB2013"d - Birth_Date) / 365.25)as Age
  from orion.staff
  where Job_title in ("Purchasing Agent I", "Purchasing Agent II")
  and calculated age 
      > all(select int(("02FEB2013"d - Birth_Date) / 365.25) 
            from orion.staff
            where Job_Title = "Purchasing Agent III"
            )
  ;
quit;

title 'Latest Order Date for';
title2 'Orion Club Low Activity Members';
proc sql;
select distinct Customer_ID,
max(Order_Date) 'Order Date' format=date11. from orion.order_fact
where Order_Date < '01Jan2012'd and
         Customer_ID in (
            select Customer_ID
			from orion.customer
where Customer_Type_ID =
                  (select Customer_Type_ID
                        from orion.customer_type
                        where Customer_Type =
                    'Orion Club members low activity'))
   group by Customer_ID;
quit;
title;

/*using in-line views*/
proc sql;
  select country, First_name, Last_Name, sum(Total_Retail_Price) as Value_Sold
         , count(distinct Order_ID) as Orders, calculated Value_Solde/calculated Orders as Avg_Order
  from orion.order_fact as of,
        orion.sales as s
  where of.Employee_ID=s.Employee_ID
         and year(Order_date) = 2011
  group by Country, First_Name, Last_Name
  having Value_Sold >= 200
  order by Country, Value_Sold desc, Orders DESC
  ;
quit;

proc sql;
  select Country, max(Value_Sold), Orders, min(Avg_Order)
  from (select country, First_name, Last_Name, sum(Total_Retail_Price) as Value_Sold
         , count(distinct Order_ID) as Orders, calculated Value_Solde/calculated Orders as Avg_Order
  from orion.order_fact as of,
        orion.sales as s
  where of.Employee_ID=s.Employee_ID
         and year(Order_date) = 2011
  group by Country, First_Name, Last_Name
  having Value_Sold >= 200
  )
  group by country
  order by Country
  ;
quit;

proc sql;
  select sum(salary) as Dept_Salary_Total
  from orion.employee_payroll as p, orion.employee_organization as o
  where p.Employee_ID = o.Employee_ID
  group by department
;
quit;

proc sql;
  select a.name, a.Id, o.department
  from orion.employee_addresses as a, orion.employee_organization as o
  where o.employee_ID = o.employee_ID
  ;
quit;

proc sql;
  select department, employee_name, salary, salary/Dept_Salary_Total as percent
  from orion.employee_payroll as pay,(select sum(salary) as Dept_Salary_Total
  from orion.employee_payroll as p, orion.employee_organization as o
  where p.Employee_ID = o.Employee_ID
  group by department) as aa, (select a.name, a.Id, o.department
  from orion.employee_addresses as a, orion.employee_organization as o
  where o.employee_ID = o.employee_ID
  ) as bb
  where sum.Department=emp.Department and
         pay.Employee_ID=emp.Employee_ID
  order by Department, Percent Desc
  ;
quit;

proc sql;
  select catx(' ',scan(mgr.Employee_Name,2,','),
as Manager,
catx(' ',scan(emp.Employee_Name,2,','),
scan(emp.Employee_Name,1,',')) format=$27. as Employee,
Sum(Total_Retail_Price) format=comma9.2
    as Total_Sales
  from orion.order_fact as f,
       orion.employee_organization as o,
       orion.employee_addresses as a1,
       orion.employee_addresses as a2
  where o.employee_ID = a2.Employee_ID and
        o.manager_ID = s1.Employee_ID and
		o.employee_ID = f.Total_Retail_Priceand year(Order_Date)=2011
     and order.Employee_ID ne 99999999
group by mgr.Country, mgr.Employee_Name, emp.Employee_Name
order by mgr.Country, mgr.Employee_Name, Total_Sales desc;
  ;
quit;

/*section 6*/
proc sql;
  select "Total Paid to All Female Sales Representatives",
         sum(salary), count(*) as total
  from orion.salesstaff
  where Gender = 'F' and Job_title = "Rep" 
  union
  select "Total Paid to All Male Sales Representatives",
         sum(salary), count(*) as total
  from orion.salesstaff
  where Gender = 'M' and Job_title = "Rep" 
  ;
quit;

proc sql;
  select *
  from orion.qtr1
  outer union corr
  select *
  from orion.qtr2
  ;
quit;

/*section 6.2*/
proc sql;
  select Employee_ID, Phone_number
  from orion.employee_phones
    except corr
  select Employee_ID, Phone_number
  from orion.employee_addresses
  ;
quit;

proc sql;
  select Customer_ID 
  from orion.order_fact
  INTERSECT
  select Customer_ID
  from orion.customer
  ;
quit;

/*level 2*/
proc sql;
  select coumt(*)
  from (select Employee_ID 
  from orion.employee_organization
  except
  select Employee_ID
  from orion.employee_donations) 
  ;
quit;

proc sql;
  select count(*) as count label= "the number of customers who places orders"
  from (
    select Customer_ID 
	from orion.order_fact
	intersect
	select Customer_ID
	from orion.customer
    )
;
quit;

/*challenge*/
proc sql number;
  select a.Employee_ID, a.Employee_Name
  from (select Employee_ID from orion.sales
        except 
        select Employee_ID from orion.order_fact) as e
		, orion.employee_addresses as a
  where e.Employee_ID = a.Employee_ID
  ;
quit;

proc sql;
  select customer_ID, customer_Name 
   from orion.customer
  where Customer_ID = any(select customer_Id from orion.order_Fact
          intersect 
          select customer_ID from orion.customer)
  ;
quit;

/*section 7*/
proc sql;
  create table orion.employees as
  select a.employee_ID, p.Employee_Hire_Date, p.salary,
         p.Birth_Date, p.Employee_Gender, a.Country, a.City
  from orion.Employee_Addresses as a, orion.Employee_Payroll as p
  where a.employee_ID = p.employee_ID and Employee_Term_Date is missing
  order by year(p.Employee_Hire_Date), p.Salary desc
  ;
quit;

proc sql;
  select *
  from orion.employees;
quit;

proc sql;
  create table orion.rewards
  (Purchased num format=comma9.2,
   Year num format=4.,
   Level char(9),
   Award cahr(50)
  );
  insert into orion.rewards
 values ( 200.00,2012,"Silver","25% Discount on one item over $25")
 values ( 200.00,2012,"Silver","25% Discount on one item over $25")
  ;
  select * from orion.rewards;
quit;

proc sql;
  create table work.direct_compensation 
  (
    Employ_ID num ,
	Name char(8),
	Level cahr(8),
	Salary num,
	Commission num,
	Direct_Compensation
  );
  insert into work.direct_compensation
  select Employee_ID, catx(' ', First_Name, Last_Name)
         ,scan(Job_Title,-1) as level, Salary,
          sales*.15 as Commission,
		 calculated Commission + Salary
  from orion.order_sales as s, 
       (select employee_ID,
 sum(Total_Prics) as sales 
 from orion.order_fact
  where year(order_date) = 2011
  group by employee_ID) as a
  where a.employee_ID = s.employee_ID and Job_Title like ('%Rep%')
  ;
  select *
   from work.direct_compensation
   order by Level, Direct_Compensation desc;
quit;

/*Section 7.2*/
proc sql;
  create view orion.phone_list as
  select Department, Employee_Name as Name, Phone_Number 'Home Phone'
  from orion.employee_addresses as a,
       orion.employee_organization_dim as o,
	   orion.employee_phones as p
  where Phone_Type = "Home" and a.employee_ID = o.employee_ID
        and a.employee_ID = p.employee_ID
  ;
quit;  

proc sql;
  title"Engineering Department Home Phone Numbers.";
  select Name, Phone_Number
  from orion.phone_list
  where Department="Engineering"
  order by name
  ;
quit;
title;

proc sql;
  create view orion.current_catalog as 
  select distinct pd.*, round(pl.Unit_Sales_Price * (Factor**(year(Today())-year(Start_Date))), .01) as Price,
         
  from orion.product_dim as pd, orion.price_list as pl
  where pd.Product_Id = pl.Product_ID
  ;

  select Supplier_Name, Product_Name, Price 
  from orion.current_catalog
  where lowcase(product_name) like '%Roller Skate%'
  order by supplier_Name, Price
  ;

  Select c.Product_Name, Unit_Sales_Price, Price, Price-Unit_Sales_Price as Increase
  from orion.current_catalog as c, orion.price_list as p
  where c.Product_ID=p.Product_id
         and calculated Increase gt 5
  order by Increase desc
  ;
quit;

/*Section 8*/
title 'Tables in the ORION Library';
proc sql;
select memname 'Table Name',
       nobs,nvar,crdate
   from dictionary.tables
   where libname='ORION';
quit;

proc sql;
  describe table dictionary.tables;
quit;

title 'SAS Objects by Library';
proc tabulate data=sashelp.vmember format=8.;
   class libname memtype;
   keylabel N=' ';
   table libname, memtype/rts=10
         misstext='None';
   where libname in ('ORION','SASUSER','SASHELP');
run;

proc sql;
  select distinct memname, memlabel
    from dictionary.dictionaries;
quit;

proc sql;
  select memname, type, length 
    from dictionary.columns
	where libname = "ORION" and upcase(Name) = 'CUSTOMER_ID'
  ;
quit;

proc sql flow=6 35;
  select memname, memlabel,count(*) as Columns
  from dictionary.dictionaries
  group by memname, memlabel
  ;
quit;

proc sql;
  select memname, nobs, nvar, filesize, maxvar, maxlabel
  from dictionary.tables
  where libname = "ORION" and memtype ne 'VIEW'
  order by memname;
quit;

/*challenge*/
proc sql flow = 2 25;
  select memname "Table",
         cats(nobs, 
              case 
                when nobs = max(nobs) then "*"
				else ''
				end
              ) "Rows",
		 cats(nvar,case
              when nvar = max(nvar) then "*"
			  else ''
         end) 'columns'
  from dictionary.tables
  where libname='ORION'
and memtype ne 'VIEW'
  ;
quit;

proc sql;
  select max(salary)
  from orion.employee_payroll
  ;
quit;

%let Dataset = employee_payroll;
%let Variablename = Salary;
%put DataSet = &DataSet, Variablename = &Variablename;
proc sql;
  select max(&Variablename)
  from orion.&Dataset
  ;
quit;

/*challenge*/

