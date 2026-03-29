options nosymbolgen;
data _null_;
 rc= git_pull(                       /*1*/
 "&repopath",        /*2*/
  "&mygituser",            /*3*/
  "&mygitpw");           /*4*/
 put rc=;                            /*5*/
run;