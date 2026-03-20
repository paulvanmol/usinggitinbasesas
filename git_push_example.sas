/*Create a macrovariable %let mygitpw=*/
%let repopath=d:/workshop/usinggitinbasesas2;
data _null_;
 rc= git_push(                    /*1*/
  "&repopath",        /*2*/
  "&mygituser",            /*3*/
  "&mygitpw");           /*4*/
run;