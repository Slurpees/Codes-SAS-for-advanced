libname orion "S:\advancedexamreciewnotes\makedataATE\atefiles";

proc fcmp outlib = work.functions.DataType;
  function CustAge(Date) $ 15;
  age=int(('13Dec2010'd-date)/365.25);
   if age < 30 then return('Under 30');
      else if age < 45 then return('30 to 44 years');
      else if age < 60 then return('45 to 60 years');
      else return('Over 60');
  endsub;
quit;
options cmplib = work.functions;
proc format ;
  value  $ CUSTFROUP
  other = [CustAge()];
run;

proc print data = orion.customerdim(obs=5) noobs label;
   var CustomerID CustomerName CustomerBirthDate;
   title 'Customer Age Group Information';
   format CustomerBirthDate CUSTFROUP.;
   label CustomerID='Customer ID' CustomerName='Customer Name'
         CustomerBirthDate='Age Group';
run;

proc format library = orion;
  invalue $gender(upcase)
  'F' = 'Female'
  'M' = 'Male'
  ;
  invalue $Country(upcase)
  'AU' = "Australia"
  'US' = 'United States'
  ;
run;

Options fmtsearch=(orion);
data sales_staff;
   infile "&path\sales1.dat";
   input  @1 Employee_ID 6.
         @40 Gender :$gender.
         @43 Job_Title $20.
		 
@64 Salary Dollar8.
@73 Country :$country.
@87 Hire_Date mmddyy10.;
run;

/*Section6.3*/
proc sort data = orion.orderfact out = orderfact;
  by CustomerID;
run;

data temp nopurchases(keep=CustomerID CustomerName);
   merge orderfact(in=O)
         orion.customerdim(keep=CustomerID CustomerName in=C);
   by CustomerID;
   if O and C then output temp;
   else if C and not O then output nopurchases;
run;
proc sort data=temp;
   by ProductID;
run;
data purchases(keep=Customerid CustomerName ProductID
                      OrderID Quantity TotalRetailPrice)
     noproducts(keep=ProductID ProductName
                     SupplierName);
   merge temp(in=T)
         orion.productdim(keep=ProductID ProductName
                               SupplierName in=P);
   by ProductID;
   if P and T then output purchases;
   else if P and not T then output noproducts;
run;

data managernames;
  merge orion.organizationdim(in = a)
        orion.employeeaddresses(in = b);
run;

proc sql;
  create table managernames as
  select ManagerLevel1-ManagerLevel6, 
quit;


proc sql;
  create index EmployeeID
  on orion.organizationdim(EmployeeID);
quit;

data salesemps;
  
  set orion.salesstaff;
  set orion.organizationdim (keep=EmployeeID Department
    Section OrgGroup)key=EmployeeID;
  if _IORC_ = 0;
run;

proc print data=salesemps(obs=5) noobs;
   title 'Sales Employee Data';
   title2 '(First 5 Observations)';
run; title;

proc sql;
  create index ProductID
  on orion.shoeprices(ProductID);
quit;

data work.shoes work.error(keep = ProductID ProductName SupplierName);
  set orion.shoevendors(keep = ProductID ProductName SupplierName MfgSuggestedRetailPrice);
  set orion.shoeprices key = ProductID(keep=ProductID TotalRetailPrice
                        CostPriceperUnit);
  if _IORC_ = 0 then do;
    output shoes;
  end;
  else do;
    _error_ = 0;
	output error;
  end;
run;

proc datasets lib = orion;
  modify shoeprices;
  index delete ProductID;
run;

data processedorders;
  set orion.firstinternetorder;
  set orion.internet key = OrderID;
  select(_IORC_);
    when (%sysrc(_sok)) do;
      Commemt = "order has been processed";
	  test_sok = _sok;
	  teststsrc = %sysrc(_sok);
	  output;
	end;
	when (%sysrc(_dsenom)) do;
	_ERROR_=0;
      Comment = "Order has not been processed";
	  test_sok = _sok;
	  teststsrc = %sysrc(_sok);
	  output;
	end;
	otherwise;
  end;
run;


proc summary data = orion.customerdim;
  var customerage;
  output out = summary mean = avgage;
run;

data agedif;
  if _N_  = 1 then do;
    set work.summary(keep = avgage);
  end;
  set orion.customerdim(keep = CustomerID CustomerAge);
  agedif = customerage - avgage;
run;

proc sql;
  create table compare as 
  select mean(sum(Qtr1,Qtr2,Qtr3,Qtr4)) as avg, 
         sum(Qtr1,Qtr2,Qtr3,Qtr4) as Totaldonations,
         calculated totaldonations - calculated avg as dif,
		 e.*
  from orion.employeedonations as e
  ;
quit;

proc sort data = orion.orderfact out = orderfact;
  by productID;
run;
data procducts(keep=CustomerID CostPricePerUnit Quantity
                   Percent ProductName);
  if _N_ = 1 then do;
    do i = 1 to totobs;
	set orderfact nobs = totobs;
    Total_each= Quantity * CostPRicePerunit;
	Total_all + Total_each;
	end;
  end;
  set orderfact;
  set orion.productdim;
  by ProductID;
  percent = Quantity * CostPRicePerunit/Total_all;
  format percent percent8.2;
run; 

proc sql;
  create table agegroups as 
  select customerID, Customername, 
         Int(yrdif(BirthDate,'01Jan2012'd, 'AGE')) as age, description
  from orion.agesmod, orion.customer
  where calculated age between Firstage and Lastage
  order by customerID
  ;
quit;

data agegroups;
   keep CustomerID CustomerName BirthDate Age Description;
   set customer;
   Age=int(yrdif(BirthDate, '01Jan2012'd, 'AGE'));
   do while (not (FirstAge le Age lt LastAge));
     set orion.agesmod;
   end;
run;

data orders;
  length saletype $ 20;
  keep OrderID OrderType SaleType;
  if _N_ = 1 then do;
  declare hash Orderhash();
  call missing(saletype);
  Orderhash.definekey('OrderType');
  orderhash.definedata('SaleType');
  orderhash.definedone();
  orderhash.add(key:1, data:"Retail Sale");
  orderhash.add(key:2, data:"Catalog Sale");
  orderhash.add(key:3, data:"Internet Sale");
  end;
  set orion.orders;
  
  Orderhash.find();
run;

data emps;
  length StateName $15 CountryName $15;
  if _N_ = 1 then do;
  declare hash location();
  call missing(StateName, CountryName);
  location.definekey('State', 'country');
  location.definedata('StateName', 'CountryName');
  location.definedone();
  location.add(key:'FL', key:'US', data:'Florida',data:'United States');
  location.add(key:'PA', key:'US', data:'Pennsylvania',data:'United States');
  location.add(key:'CA', key:'US', data:'California',data:'United States');
  location.add(key:' ', key:'AU', data:' ', data:'Australia');
  end;
  set orion.employeeaddresses;
  rc = location.find();
  if rc = 0;
run;

/*Loading a hadh object from a SAS date Set*/
data customers;
  if 0 then set orion.customertype;
  declare hash C(dataset:"orion.customertype");
  C.definekey('CustomerTypeID');
  C.definedata('CustomerType');
  C.definedone();
  set orion.customer;
  if C.find() = 0;
run;

data billing;
  
  if 0 then do;
    set orion.productlist(keep=ProductID ProductName);
	set orion.customerdim(keep=CustomerID
                                           CustomerCountry
                                           CustomerName);
  end;
  if _N_ = 1 then do;
  declare hash P(dataset : 'orion.productlist');
  P.definekey('ProductID');
  P.definedata('Productname');
  P.definedone();
  declare hash C(dataset: 'orion.customerdim');
  C.definekey('CustomerID');
  C.definedata('CustomerCountry', 'CustomerName');
  C.definedone();
  end;
  set orion.orderfact(keep=CustomerID OrderDate ProductID Quantity TotalRetailPrice);
  rc1 = P.find();
  rc2 = C.find();
  if rc1 = 0 and rc2 = 0;
run;

data manager;
  keep EmployeeID EmpName ManagerID ManagerName Salary;
  if _N_= 1 then do;
    if 0 then set orion.employeeaddresses orion.staff;
  declare hash E(dataset: 'orion.employeeaddresses');
  E.definekey('EmployeeID');
  E.definedata('EmployeeName');
  E.definedone();
  declare hash S(dataset:'orion.staff');
  S.definekey('EmployeeID');
  S.definedata('ManagerID');
  S.definedone();
  end;
  set orion.employeepayroll(keep=EmployeeID Salary);
  rc1 = S.find(key:EmployeeID);
  rc2 = E.find(key:EmployeeID);
  if rc2 = 0 then EmpName = EmployeeName;
  else Empname = '';
  rc3= E.find(key:ManagerID);
  if rc3 = 0 then ManagerName = EmployeeName;
  else Managername = '';
run;

data expensive leastexpensive;
  if 0 then set orion.shoesales;
  declare hash S(dataset:'orion.shoesales',ordered:'descending');
  S.definekey('TotalRetailPrice');
  S.definedata('ProductID','ProductName', 'TotalRetailPrice');
  S.definedone();
  declare hiter Sh('S');
  Sh.first();
  do i = 1 to 5;
    output expensive;
	Sh.next();
  end;
  Sh.last();
  do i = 1 to 5;
    output leastexpensive;
	Sh.prev();
  end;
  stop;
run;

data different;
drop rc;
keep CustomerID OrderType;
  if 0 then set orion.orderfact;
  if _N_ = 1 then do;
    declare hash O(dataset: 'orion.orderfact', ordered : 'yes');
	O.definekey('CustomerID','OrderType');
    O.definedata('CustomerID','OrderType');
	O.definedone();
	declare hiter Oh('O');
  end;
  rc = Oh.first();
  do while (rc = 0);
    output;
	rc = Oh.next();
  end;
  stop;
run;

data compare;
if _N_ = 1 then do;
  array MRP{1:12} Month1-Month12;
  set orion.retailinformation(where =(Statistic = 'MedianRetailPrice'));
end;
set orion.retail;
month = month(orderdate);
MRP1 = MRP{month};
run; 

data trans;
set orion.shoestats;
  array temp[21:24] Product21-Product24   ;
  do i = 21 to 24;
	ProductLine = i;
	Value = temp{i};
	output;
  end;
run;

proc sort data=orion.orderfact
           out=orderfact(keep=CustomerID OrderType OrderDate
                              DeliveryDate Quantity);
   where CustomerID in (89, 2550)
     and year(OrderDate)=2011;
   by OrderType;
run;
 
proc sql;
title 'Count by Order Type';
select OrderType,
       count(*) as count
   from orderfact
group by OrderType;
quit;

data all;
  array OD{*} OrderDate1-OrderDate4;
  array DD{1:4} DeliveryDate1-DeliveryDate4;
  array OQ{*} Quantity1-Quantity4;
  N = 0 ;
  do until(Last.OrderType);
    set orderfact;
	by ordertype;
	N+1;
	OD{N} = OrderDate;
	DD{N} = DeliveryDate;
	OQ{N} = Quantity;
  end;
run;

data customercoupons;
  array coupon{3,6} _temporary_ (10, 10, 15, 20, 20, 25
                     10, 15, 20, 25, 25, 30
                     10, 15, 15, 20, 25, 25);
  set orion.orderfact;
  CouponValue = coupon{Ordertype, Quantity};
run;

data combine;
  array advice{21:24,2} _temporary_ (.,70.79,173.79,174.40,.,.,29.65,287.8);
  set orion.shoesales;
  Productline = input(substr(ProductID, 1, 2), 2.);
  ProductCategory = input(substr(ProductID, 3, 2), 2.);
  suggestedprice = advice{Productline, ProductCategory};
run;


data warehouses;
   set orion.productlist(keep=ProductID ProductName ProductLevel
                         where=(ProductLevel=1));
   ProdID=put(ProductID,12.);
   ProductLine=input(substr(ProdID,1,2),2.);
   ProductCategory=input(substr(ProdID,3,2),2.);
   ProductLocID=input(substr(ProdID,12,1),1.);
   if ProductLine in (21,22) and ProductCategory<=2 and ProductLocID<2;
run;


data warehouse;
  array t{21:22,0:2,0:1} $ 5  _temporary_
        ('A2100','A2101','A2110','A2111','A2120',
         'A2121','B2200','B2201','B2210','B2211',
         'B2220','B2221');
   set orion.productlist(keep=ProductID ProductName
                              ProductLevel
                         where=(ProductLevel=1));
    ProdID=put(ProductID,12.);
   ProductLine=input(substr(ProdID,1,2),2.);
   ProductCategory=input(substr(ProdID,3,2),2.);
   ProductLocID=input(substr(ProdID,12,1),1.);
   if ProductLine in (21,22) and ProductCategory<=2
      and ProductLocID<2;
   Warehouse=W{ProductLine, ProductCategory, ProductLocID};
run;

data customercoupons;
  drop quantity1-quantity6 i j;
  if _N_ = 1 then do;
  array q{3, 6} _temporary_;
  do i = 1 to 3;
    set orion.coupons;
	array qu{1:6} Quantity1-Quantity6;
    do j = 1 to 6;
      q{i, j} = qu{j};
	end;
  end;
  end;
  set orion.orderfact;
  CouponValue = q{ordertype, quantity};
run;

data customercoupons;
  ARRAY Q{1:3, 1:6} _temporary_;
  if _N_ = 1 then do;
  do i = 1 to 3;
    do j = 1 to 6;
      set orion.couponpct;
	  Q{i, j} = Value;
	  output;
    end;
  end;
  end;
  set orion.orderfact;
  couponvalue = Q{ordertype, Quantity};
run;

data combine;
  array R{21:24, 1:2} _temporary_;
  keep ProductID ProductName TotalRetailPrice
       ManufacturerSuggestedPrice;
  if _N_ = 1 then do i = 1 to totobs;
    set orion.msp nobs = totobs;
	pID = put(prodcatid,4.);
	cateID = input(substr(pID, 3, 2),12.);
	R{Prodline, cateID} = AvgSuggestedRetailPRice;
    end;
  set orion.shoesales;
  numID = input(ProductID, 12.);
  Line = Substr(numID, 1, 2);
  cateID = Substr(numID, 3, 2);
  ManufacturerSuggestedPrice = R{Line, CateID};
run;
 
data warehouse;
  array threew{21:24, 0:8, 0:9} $ _temporary_;
  if _N_ = 1 then do i = 1 to totobs;
    set orion.warehouses nobs = totobs;
	Threew{ProductLine, ProductCatID, ProductLocID} = Warehouse;
  end;
  keep ProductID ProductName Warehouse;
  
  set orion.productlist;
  where ProductLevel = 1;
  ProductLine = input(substr(put(ProductID, 12.),1,2),2.);
  ProductCatID = input(substr(put(ProductID, 12.),3,2),2.);
  ProductLocID = input(substr(put(ProductID, 12.),5,1),1.);
  Warehouse = Threew{ProductLine, ProductCatID, ProductLocID};
run;

data productsample;
  do i = 10 to totobs by 10;
      set orion.productdim(keep = ProductLine ProductID
      ProductName SupplierName) 
      point = i nobs = totobs;
	  output;
  end;
  stop;
run;

proc sort data = orion.totalsalaries out = work.totalsalaries;
   by descending Deptsal;
run;

data highest lowest;
  do i = 1 to 5;
  set totalsalaries(obs = 5);
  output highest;
  end;
    do i = totobs-4 to totobs;
      set totalsalaries nobs = totobs point = i;
	  output lowest;
	end;
  
  stop;
run;


data underforty fortyplus;
  samplesize = 50;
  do i = 1 to samplesize;
    point = ranuni(5)*totobs;
	  set orion.customerdim point = i nobs = totobs;
	  if customerage < 30 then do;
	    output underforty;
	  end;
	  else if customerage >= 30 then do;
	    output fortyplus;
	  end;
  end;
stop;
run;

options msglevel=i;
data orders(index=(CustomerID OrderID/unique));
   set orion.orders;
   DaysToDelivery=DeliveryDate-OrderDate;
run;

proc sql;
  drop index OrderID from orders;
quit;

proc datasets library = work nolist;
  modify orders;
  index create Ordate = (orderID OrderDate);
run;

proc contents data = oders;

run;

options msglevel = i;

data pricelist(index = (ProductID/unique));
set orion.pricelist;
  UnitProfit = UnitSalesPrice - UnitCostPrice;
  
run;

data allstaff(index = (AgeHired));
 keep EmployeeID BirthDate HireDate AgeHired;
  set orion.sales orion.nonsales(rename = (First = FirstName Last=LastName ));

  AgeHired = intck('year',BirthDate,Hiredate,'c');
    if AgeHired > 30;
run;





