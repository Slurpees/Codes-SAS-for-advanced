/*
ST556 HW3, Kaida Lou, 2-4-2022
This program is used for hw3.
It does not read or require any external files.
*/
/*Problem 7.*/
%let dsn1=shoes5;
%let dsn2=shoes9;
/*add a macro statement for extracting numeric parts, then send sum 
  of these numbers to the log*/
%put %eval(%scan(&dsn1,-1,,a)+%scan(&dsn2,-1,,a));

/*Problem 8.*/
x "cd S:/ST556/HW3";
%let year =2010;
data records&year ;
infile "records&year..dat" firstobs =3 dsd ;
length team $ 15;
input team $ w l t wpct pf pa ; *w= wins l= losses ;
run ;

/*Problem 9.*/
ods noproctitle;
libname hw3 "S:/ST556/HW3";
/*
  problem 9(a) **********
  Use a do loop to generate a random sample of n = 10 independent uniformly distributed RVs.
*/
data hw3.Third_a;
  call STREAMINIT(369);
  do i = 1 to 10;
    u = rand("UNIF");
    output;
  end;
run;

/*
  problem 9(c) **********
  Use results of parts(a) and (b) to generate a sample of n=10
  independent observations from exp dist with mean 5.
*/
data hw3.Third_c;
  call STREAMINIT(369);
  do i = 1 to 10;
    q = rand("unif");
    y = log(1-q) * (-5);
    output;
  end;
run;

/*
  report the sample along with the sample mean and sample standard deviation
*/
proc means data = hw3.third_c mean stddev;
  var y;
run;

/*
  problem9(d)********
  i.Draw a larger sample of uniform RVs by increasing the sample size to n = 1000.
*/
data hw3.Third_d;
  call STREAMINIT(369); 
  do i = 1 to 1000;
    q = rand("unif");
    y = log(1-q) * (-5);
    output;
  end;
run;

proc means data = hw3.third_d mean stddev;
  var y;
run;

/*
 ii.Generate another random sample using built-in SAS function, RANEXP.
*/
data hw3.Third_e;
  do i = 1 to 1000;
    x2 = 5 * ranexp(1234);
    output;
  end;
run;

proc means data = hw3.third_e mean stddev;
  var x2;
run;


