/*Create a new local repository*/
%let path=d:/workshop/usinggitinbasesas;
/*create directory for path*/ 
options dlcreatedir; 
libname repo "&path"; 
libname repo clear; 

/*do a Git_init_repo*/
data _null_;
  rc= git_init_repo(
    "d:/workshop/usinggitinbasesas");
  put rc=;
run;

/*do a git remote */
data _null_;
   rc = git_set_url(
    "&path",
    "https://github.com/paulvanmol/usinggitinbasesas");
put rc=;
run;
