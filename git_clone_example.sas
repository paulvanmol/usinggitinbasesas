options dlcreatedir;
%let repoPath = %sysfunc(getoption(WORK))/usinggitinbasesas;
%let repoPath = d:/workshop/usinggitinbasesas2;
libname repo "&repoPath.";
libname repo clear;  

/* Fetch latest code from GitHub */
data _null_;
rc = git_clone("https://github.com/paulvanmol/usinggitinbasesas/", "&repoPath.");
put rc=; 
run;

/* run the code in this session */
%include "&repoPath./checkencoding.sas"; 
