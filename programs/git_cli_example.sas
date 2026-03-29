%let repopath = d:/workshop/usinggitinsasstudio;

/* Pull latest main */
data _null_;
  rc = system("git -C ""&repopath"" checkout main");
  rc = system("git -C ""&repopath"" pull origin main");
  rc = system("git -C ""&repopath"" checkout your-branch");
  rc = system("git -C ""&repopath"" rebase main");
  put rc=;
run;