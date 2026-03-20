%macro git_stage_commit_all(repopath=, author=, email=, message=);

  /* 1. Discover all .sas files using DOPEN/DREAD/DNUM */
  filename _repodir "&repopath";

  data _sasfiles;
    length filename $ 256;
    
    did = dopen("_repodir");
    if did = 0 then do;
      put "ERROR: Could not open directory &repopath";
      stop;
    end;
    
    nfiles = dnum(did);
    put "INFO: " nfiles "entries found, scanning for .sas files...";
    
    do i = 1 to nfiles;
      filename = dread(did, i);
      if lowcase(substr(filename, length(filename)-3)) = ".sas" 
        then output;
    end;
    
    rc = dclose(did);
    drop did nfiles i rc;
  run;

  filename _repodir clear;

  %let filecount = 0;
  proc sql noprint;
    select count(*) into :filecount trimmed from _sasfiles;
  quit;
  %put INFO: Found &filecount .sas file(s) to stage.;

  %if &filecount = 0 %then %do;
    %put WARNING: No .sas files found in &repopath — nothing staged or committed.;
    %return;
  %end;

  /* 2. Open git status */
  data _null_;
    n = git_status("&repopath");
    put "git_status n=" n;
  run;

  /* 3. Stage each file */
  data _null_;
    set _sasfiles;
    rc = git_index_add("&repopath", trim(filename), "New");
    put filename= rc=;
  run;

  /* 4. Refresh status */
  data _null_;
    rc = git_status_free("&repopath");
    n  = git_status("&repopath");
    put "git_status after staging n=" n;
  run;

  /* 5. Commit */
  data _null_;
    rc = git_commit(
      "&repopath",
      "HEAD",
      "&author",
      "&email",
      "&message");
    put rc=;
  run;

  /* 6. Cleanup */
  proc datasets lib=work nolist;
    delete _sasfiles;
  quit;

%mend git_stage_commit_all;


/* Example call */
%git_stage_commit_all(
  repopath = d:/workshop/usinggitinbasesas2,
  author   = paulvanmol,
  email    = paul.van.mol@gmail.com,
  message  = Staged all SAS programs
);