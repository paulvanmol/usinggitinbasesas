*options mprint mlogic symbolgen; 
options nomprint nomlogic nosymbolgen; 
%macro git_stage_recursive(repopath=, dir=, author=, email=, message=) / minoperator;
  %local fileref rc did n memname didc relpath;

  /* On first call, open git status */
  %if %superq(dir) = %then %do;
    %let dir = &repopath;
    data _null_;
      n = git_status("&repopath");
      put "git_status n=" n;
    run;
  %end;

  /* Assign fileref and open directory */
  %let rc  = %sysfunc(filename(fileref, &dir));
  %let did = %sysfunc(dopen(&fileref));

  %if &did = 0 %then %do;
    %put ERROR: Could not open directory &dir;
    %return;
  %end;

  /* Loop through all entries */
  %do n = 1 %to %sysfunc(dnum(&did));
    %let memname = %sysfunc(dread(&did, &n));

    /* Skip hidden entries and .git folder */
    %if %qsubstr(&memname,1,1) = . %then %goto next;

    %if %upcase(%qscan(&memname,-1,.)) = SAS %then %do;
      /* It's a .sas file — build relative path and stage it */
      %let relpath = %sysfunc(substr(&dir/&memname,
                       %eval(%length(&repopath) + 2)));
      data _null_;
        rc = git_index_add(
               "&repopath",
               "&relpath",
               "New");
        put "Staged: &relpath rc=" rc;
      run;
    %end;
    %else %if %qscan(&memname,2,.) = %then %do;
      /* No extension — treat as subdirectory, recurse */
      %git_stage_recursive(
        repopath = &repopath,
        dir      = &dir/&memname,
        author   = &author,
        email    = &email,
        message  = &message);
    %end;

    %next:
  %end;

  /* Close directory */
  %let didc = %sysfunc(dclose(&did));
  %let rc   = %sysfunc(filename(fileref));

  /* On return to top-level call, commit */
  %if %superq(dir) = %superq(repopath) %then %do;
    data _null_;
      rc = git_status_free("&repopath");
      n  = git_status("&repopath");
      put "git_status after staging n=" n;
    run;

    data _null_;
      rc = git_commit(
             "&repopath",
             "HEAD",
             "&author",
             "&email",
             "&message");
      put "git_commit rc=" rc;
    run;
  %end;

%mend git_stage_recursive;


/* Example call */
%git_stage_recursive(
  repopath = d:/workshop/usinggitinbasesas2,
  author   = paulvanmol,
  email    = paul.van.mol@gmail.com,
  message  = Staged all SAS programs including subdirectories
);