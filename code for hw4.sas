/*
ST556 HW4, Kaida Lou, 2-13-2022
This program is used for hw4.
It does not read or require any external files.
*/
libname orion "S:\ST556\ORION\macro_materials\macro_materials";
ods trace on;

/*generate the data set named owf with the freqs of the three 
customer groups*/
ods output onewayfreqs=owf;
proc freq data=orion.customer_dim;
tables customer_group;
run;

/*sort so that the first observation 
in owf corresponds to the most abundant group*/
proc sort data = owf;
  by descending Percent ;
run;

/*use the symputx routine to create a macro variable 
called most and assign its valuede as the namel of the 
most frequent customer group*/
data _null_;
  set owf;
  if _n_ = 1 then do;
    call symputx("most",Customer_Group);
  end;
run;
%PUT &most;

/*most frequent group*/
proc print data=orion.customer_dim(obs=5);
  where customer_group="&most";
  title "the most abundant group is &most";
  var customer_name customer_gender customer_age customer_group;
run;

/*(d)use the %upcase macro function write the title
in all caps*/
proc print data=orion.customer_dim(obs=5);
  where customer_group="&most";
  title "%upcase(the most abundant group is &most)";
  var customer_name customer_gender customer_age customer_group;
run;

/*(f)use the %sysfunc macro function write the title
in all caps*/
proc print data=orion.customer_dim(obs=5);
  where customer_group="&most";
  title %sysfunc(catx(,%upcase("the most abundant group is &most"),!!!));
  var customer_name customer_gender customer_age customer_group;
run;

/*(g)this is a program used by a user for querying the most or least
frequency customer list*/
/*%let frequent = most;*users supply one parameter;*/
%let frequent = least;
/*sort the owf dataset*/
proc sort data = owf;
  by descending Percent ;
run;
/*create the macro variable  called most or least 
and assign its valuede as the namel of the 
corresponding frequent customer group*/
options symbolgen;
data test;
  set owf end = last;
      if _n_ = 1 and "&frequent"='most' then
        call symputx("&frequent",Customer_Group);
      if last = 1 and "&frequent" ='least' then
        call symputx("&frequent",Customer_Group);
run;
%put &least;
/*print the observations and approciate title*/
proc print data=orion.customer_dim(obs=5);
  where customer_group="&&&frequent";
  title "%upcase(the &frequent abundant group is &&&frequent)";
  var customer_name customer_gender customer_age customer_group;
run;

/*problem 2*/
%put %sysfunc(mdy(2,13,1997),weekdate.);

/*problem 3*/
/*(a)*/
proc freq data = orion.customer;
  title "Souther Hemisphere";
  tables country;
  where country in ("AU", "ZA");
run;
title;

proc freq data = orion.customer;
  title "North Hemisphere";
  tables country;
  where country not in ("AU", "ZA");
run;
title;

/*(b)*/
options MCOMPILENOTE=ALL;
options noMLOGIC;
options mprint;
%macro hemifreq(hemi) / MINOPERATOR;
    %let hemi=%upcase(&hemi);
	%put &hemi;
    %if &hemi in SOUTHERN S SOUTH %then %do; 
      proc freq data = orion.customer;
        title "Souther Hemisphere";
        tables country;
        where country in ("AU", "ZA");
      run;
      title;
    %end;
    %else %if &hemi in NORTHERN N NORTH %then  %do; 
      proc freq data = orion.customer;
        title "North Hemisphere";
        tables country;
        where country not in ("AU", "ZA");
      run;
      title;
    %end;
    %else %do;  
      %put please input a vaild parameter;
    %end;
%mend hemifreq;
%hemifreq(s)

/*problem 4*/
options ls=75 nocenter mlogic ;
data NC;
   length  county $20 city $20;
   input county_id county $ city_id city  $ popn income;
   call symputx("county"||left(county_id),county);
   call symputx("city"||left(city_id),city);
   datalines;
1 Wake 1 Raleigh 404 32.6
1 Wake 2 Cary 135 32.6
2 Mecklenburg 3 Charlotte 731 31.8
2 Mecklenburg 4 Davidson 11 31.8
;
run;

/*use the proc means procedure to report*/
proc means data = NC mean;
  var popn income;
  by county_id;
run;

/*(b)*Use indirect macro variable references to 
complete the macro below*/
%macro countysum(id);
  proc means data=NC;
    title "report for county=&&county&id";
    where county="&&county&id";
    var popn income;
  run;
%mend countysum;

%countysum(1)
%countysum(2)

/*(d)*/
%macro munisum(mtype,id);
  proc means data=NC;
    title "&mtype report";
    title2 "&&&mtype&id";
    where &mtype = "&&&mtype&id";
    var popn income;
  run;
%mend munisum;

%munisum(county,1)
%munisum(county,2)
%munisum(city,1)
%munisum(city,2)
