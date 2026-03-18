/*Create a new local repository*/
%let repopath=d:/workshop/usinggitinbasesas;
/*create directory for path*/ 
options dlcreatedir; 
libname repo "&repopath"; 
libname repo clear; 

/*do a Git_init_repo*/
data _null_;
  rc= git_init_repo(
    "&repopath");
  put rc=;
run;

/*do a git remote */
data _null_;
   rc = git_set_url(
    "&repopath",
    "https://github.com/paulvanmol/usinggitinbasesas");
put rc=;
run;
