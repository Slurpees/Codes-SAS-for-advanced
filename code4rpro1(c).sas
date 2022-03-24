/*Problem 1 (c) */
options mstored sasmstore=hw5;
libname hw5 "S:\ST556\HW5";
/*run following program by retrieving the stored macro
and produce the same produce as part(a)*/
ods listing close;
%onetime_proglm(Type)
%onetime_proglm(Name)
%onetime_proglm(Product)
%onetime_proglm(Producer)

/*Validate the output with demo given by the hw5 instruction*/

proc print data=allanova; 
  where hypothesistype =1;
run;

