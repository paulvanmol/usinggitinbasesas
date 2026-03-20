%let repopath = d:/workshop/usinggitinsasstudio;

data _null_;
   rc = git_stash(
    "&repopath",
    "paulvanmol", /* 4: author name               */
    "paul.van.mol@gmail.com" /* 5: author email             */);
   put rc=;
run;

/*Using Git_STASH_POP() to restore STASH to the current repository*/
%let repopath = d:/workshop/usinggitinsasstudio;
data _null_;
   rc = git_stash_pop("&repopath");
   put rc=;
run;

/*Other Git_Stash functions*/
/*
data _null_;
   rc = git_stash_apply("&repopath");
   put rc=;
run;
data _null_;
   rc = git_stash_drop("C:\LocalGitRepo");
   put rc=;
run;
*/