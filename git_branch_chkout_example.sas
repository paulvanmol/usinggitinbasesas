%let repoPath = d:/workshop/usinggitinbasesas2;
data _null_;
 rc= git_branch_chkout(
  "&repopath",       /*1*/
  "main");         /*2*/
  put rc=;
run;