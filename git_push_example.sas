/*Create a macrovariable %let mygitpw=*/

data _null_;
 rc= git_push(                    /*1*/
  "&repopath",        /*2*/
  "&mygituser",            /*3*/
  "&mygitpw");           /*4*/
run;