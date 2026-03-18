data _null_;
 n = git_commit_log("&repopath");      /*1*/
 put n=;                                      /*2*/
run;

data _null_;
 n = git_commit_log("&repopath");      /*1*/
 put n=;                                      /*2*/
 length attribute_out $ 1024;           /*1*/
 attribute_out = "";                    /*2*/
 rc = git_commit_get(                 /*3*/
  n,                                    /*4*/
  "&repopath",                          /*5*/
  "id",                          /*6*/
  attribute_out);                       /*7*/
 put attribute_out=;                    /*8*/
call symputx('commit_id',attribute_out);
run;

data _null_;
 rc = git_branch_new(
  "&repopath",           /*1*/ 
  "&commit_id",           /*2*/ 
  "feature/task_branch",
  1);          /*4*/ 
 put rc=;
run;
/*Specify your local Git repository.

Specify the commit ID to build the new branch from.

Specify a name for the new branch.

Specify whether to overwrite an existing branch with the same name.*/