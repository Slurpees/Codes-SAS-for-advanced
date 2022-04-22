/*
ST556 HW8, Kaida Lou, 4-21-2022
This program is used for hw8.
It read or require the data set employee_addresses,
                       order_fact, product_dim, staff
					   mlb2010, employee_organization
*/

data A;
  do i = 1 to 3;
     ID = i;
     name = i;
	 output;
  end;
run;

data B;
  do i = 1 to 4;
     ID = i;
     status = i;
	 output;
  end;
run;

proc sql;
  select * 
  from A left join B 
  on A.ID = B.ID;
quit;

proc sql;
  select * 
  from B left join A 
  on A.ID = B.ID;
quit;

PROC SQL nonumber;
SELECT * FROM a,b WHERE a.ID=b.ID;
QUIT;


PROC SQL;
SELECT * FROM a NATURAL JOIN b;
QUIT;

Libname HW8 "S:\ST556\HW8";
Filename rawdata "S:\ST556\HW8\runsathome2011.csv";

proc import file = rawdata
    out=hw8.runsathome2011
    dbms=csv;
run;

proc sql;
  select mean(hruns) as mean_runs 'clasulate mean of all team hruns'
  from hw8.Runsathome2011
  ;
quit;

proc sql;
  title"team with average runs fewer than overall average";
  select vteam, mean(hruns) 'means of hruns'
  from hw8.Runsathome2011
  group by vteam
  having mean(hruns) lt (select mean(hruns)
  from hw8.Runsathome2011)
  ;
quit;


data hw8.reshaped;
  keep id dose id phytate response block aminoacid;
  array data{17} DIG_LYS3 DIG_THR3 DIG_ALA3 DIG_ARG3 
				 DIG_ASP3 DIG_CYS3 DIG_GLU3 DIG_GLY3 
				 DIG_HIS3 DIG_ILE3 DIG_LEU3 DIG_MET3 
				 DIG_PHE3 DIG_PRO3 DIG_SER3 DIG_TYR3
				 DIG_VAL3;
  array name{17} $("DIG_LYS3" "DIG_THR3" "DIG_ALA3"
				   "DIG_ARG3" "DIG_ASP3" 'DIG_CYS3' 'DIG_GLU3'
				   'DIG_GLY3' 'DIG_HIS3' 'DIG_ILE3' 'DIG_LEU3'
                   'DIG_MET3' 'DIG_PHE3' 'DIG_PRO3' 'DIG_SER3'
                   'DIG_TYR3' 'DIG_VAL3');
  set hw8.Dig_aminoa;
  do i = 1 to dim(data);
    aminoacid = name{i};
	response = data{i};
	output;
  end;
run;
proc sort data =hw8.reshaped;
by aminoacid ;
run ;
ods listing close ;
proc mixed data =hw8.reshaped;
by aminoacid ;
class block phytate dose ;
model response = phytate | dose block ;
run ;


/*******************************************/
data flights2;
keep Flight Temp WSpeed wc wcform;
  array wcarray {8,9} _temporary_ (
-22 , -16 , -11 , -5 ,1 ,7 ,13 ,19 ,25 ,
-28 , -22 , -16 , -10 , -4 ,3 ,9 ,15 ,21 ,
-32 , -26 , -19 , -13 , -7 ,0 ,6 ,13 ,19 ,
-35 , -29 , -22 , -15 , -9 , -2 ,4 ,11 ,17 ,
-37 , -31 , -24 , -17 , -11 , -4 ,3 ,9 ,16 ,
-39 , -33 , -26 , -19 , -12 , -5 ,1 ,8 ,15 ,
-41 , -34 , -27 , -21 , -14 , -7 ,0 ,7 ,14 ,
-43 , -36 , -29 , -22 , -15 , -8 , -1 ,6 ,13);
attrib Flight length =$8; *$;
attrib Temp length =8;
attrib WSpeed length =8;
attrib wc length =8;
attrib wcform format = 8.4;
infile datalines dsd ;
input Flight$ Temp WSpeed;
row = round(wspeed,5)/ 5;
col =(round(temp,5)/5)+3;
wc = wcarray{row,col};
c =(temp-32)*5/9;
v= wspeed*.44704;
wcform1 =35.74+.6215 * temp -35.75 * wspeed ** .16+.4275 * temp * wspeed ** .16;
wcform = round(wcform1, 0.0001);
datalines;
IA1234, 14, 29
IA3456, 12, 27
IA2736, -7, 9
IA6352, -4, 11
IA1234, 32, 4
IA3456, 22, 21
IA2736, 15, 18
IA6352, 0, 10
;
run;
proc print ; run ;
