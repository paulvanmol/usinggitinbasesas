data _null_;
 rc= git_push(                    /*1*/
  "&path",        /*2*/
  'paulvanmol',            /*3*/
  "&mygitpw");           /*4*/
run;