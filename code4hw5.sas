/*
ST556 HW5, Kaida Lou, 2-23-2022
This program is used for hw5.
It read or require the data set pickles.sas7bdat.
*/
libname hw5 "S:\ST556\HW5";
/*A program for problem 1(a) which defines a macro 
to accomplish the one-time typing for proc glm and 
appending one-way ANOVA results*/
%macro onetime_proglm(response_var);
  proc glm data=hw5.pickles;
    class &response_var;
    model Nitrite Nitrate Ascorbic PolyP = &response_var; 
    ods output modelanova=myanova;
  run;
  proc append base=allanova data=myanova; 
  run;
%mend onetime_proglm;

/*calling the macro 4 times in order to produce the 
necessary output and create the dataset called allanova*/
ods listing close;
%onetime_proglm(Type)
%onetime_proglm(Name)
%onetime_proglm(Product)
%onetime_proglm(Producer)

/*Validate the output with demo given by the hw5 instruction*/
/*ods listing ;*/
/*proc sort data=allanova;*/
/*  by dependent source; */
/*run;*/
proc print data=allanova; 
  where hypothesistype =1;
run;

/*Problem 1 (b) store the macro and make it portable*/
options mstored sasmstore=hw5; *Enable storage and id a 
                                permanent lib where to store;
%macro onetime_proglm(response_var)/ store source; 
/*specify the store and source options in the macro definition*/
  proc glm data=hw5.pickles;
    class &response_var;
    model Nitrite Nitrate Ascorbic PolyP = &response_var; 
    ods output modelanova=myanova;
  run;
  proc append base=allanova data=myanova; 
  run;
%mend onetime_proglm;

/*problem2 (a)*/
filename Rawdata "S:\ST556\HW5";
/*From the raw dataset file hoops2020.txt read the data 
It seems that the hoops2020.txt is the same as hoops2019.txt*/
/*rewrite*/;
data hoops;
  drop i j;
  length team $14.;
  array gd[2] $5 _temporary_ ("Men", "Women");
  array fis[2] $8 _temporary_ ("Champion","Runnerup");
  infile Rawdata("hoops2020.txt")  firstobs = 3;
  input year @;
  do i = 1 to 2;
    gender = gd[i];
    do j = 1 to 2;
      finish = fis[j];
	  input team @;
	  output;
	end;
  end;
run;
proc print data = hoops(obs =5);
run;
/*Problem2 (b)*/
/*create sequences of macro variables and startyear, endyear macro 
variables using symputx call rutine and loop syntax*/
proc sort data=hoops; 
  by year; 
run; 
data _null_;
  set hoops end=eod;
  if _n_=1 then call symput("startyear",compress(year)); 
  if eod then call symput ("endyear",compress(year));
  call symput(compress(gender||"s_"||finish||year),team);
run;
%put _user_;

/*problem 2 (c) */
%put years: &startyear - &endyear;

/*problem 2 (d)*/
/*replace the ???s inorder to accomplish these fucntion 
described by the instruction*/
%macro announce(mw,outcome,year);
%put;
%put This macro would like to announce that the %upcase(&outcome) of the %sysfunc(propcase(&mw)) NCAA; 
%put basketball tournament of &year is ... ;
%put !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!;
%put !!!!!! &&&mw._&outcome&year   !!!!!;
%put !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!;
%put;
%mend announce;
%announce(mens,runnerup ,2012)
%announce(womens ,champion ,2016)
