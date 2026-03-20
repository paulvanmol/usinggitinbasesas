%macro git_discover_sas_files(repopath=);

  /* Initialize the file results table and directory queue */
  data _sasfiles;
    length filename $ 512;
    stop;
  run;

  data _dirqueue;
    length dirpath $ 512;
    dirpath = "&repopath";
    output;
  run;

  /* Process directories until the queue is empty */
  %let dirs_remaining = 1;

  %do %while(&dirs_remaining > 0);

    /* Grab the first directory from the queue */
    data _null_;
      set _dirqueue(obs=1);
      call symputx('current_dir', dirpath);
    run;

    /* Remove it from the queue */
    data _dirqueue;
      set _dirqueue(firstobs=2);
    run;

    /* Scan current directory */
    filename _curdir "&current_dir";

    data _scan_results;
      length filename $ 512 dirpath $ 512 entry $ 256;
      did = dopen("_curdir");

      if did = 0 then do;
        put "WARNING: Could not open directory &current_dir";
        stop;
      end;

      nentries = dnum(did);

      do i = 1 to nentries;
        entry = dread(did, i);

        /* Skip hidden files and . / .. */
        if entry =: "." then continue;

        /* Build full path */
        fullpath = cats("&current_dir", "/", entry);

        /* Check if it is a subdirectory by trying to DOPEN it */
        length subref $ 8;
        subref = "tmpref";
        filename tmpref (fullpath);  /* NOT portable — use fileref trick below */

        /* Determine if directory: assign fileref and test */
        rc_sub = filename(subref, fullpath);
        sub_did = dopen(subref);

        if sub_did > 0 then do;
          /* It's a directory — add to queue */
          dirpath = fullpath;
          output _dirqueue;
          rc2 = dclose(sub_did);
        end;
        else do;
          /* It's a file — check extension */
          if length(entry) > 4
            and lowcase(substr(entry, length(entry)-3)) = ".sas" then do;
            filename = fullpath;
            output _sasfiles;
          end;
        end;

        rc3 = filename(subref, "");  /* clear the temp fileref */
      end;

      rc4 = dclose(did);
      drop did nentries i entry fullpath subref rc: sub_did dirpath;
    run;

    filename _curdir clear;

    /* Check if queue still has entries */
    proc sql noprint;
      select count(*) into :dirs_remaining trimmed from _dirqueue;
    quit;

  %end;

%mend git_discover_sas_files;
%macro git_stage_commit_all(repopath=, author=, email=, message=);

  /* 1. Discover all .sas files recursively */
  %git_discover_sas_files(repopath=&repopath);

  %let filecount = 0;
  proc sql noprint;
    select count(*) into :filecount trimmed from _sasfiles;
  quit;
  %put INFO: Found &filecount .sas file(s) to stage across all subdirectories.;

  %if &filecount = 0 %then %do;
    %put WARNING: No .sas files found under &repopath — nothing staged or committed.;
    %return;
  %end;

  /* 2. Open git status */
  data _null_;
    n = git_status("&repopath");
    put "git_status n=" n;
  run;

  /* 3. Stage each file — path must be relative to repo root */
  data _null_;
    set _sasfiles;
    /* Strip the repopath prefix to get the relative path */
    length relpath $ 512;
    relpath = substr(filename, length("&repopath") + 2);  /* +2 for the slash */
    rc = git_index_add("&repopath", trim(relpath), "New");
    put relpath= rc=;
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
    delete _sasfiles _dirqueue;
  quit;

%mend git_stage_commit_all;


/* Example call */
%git_stage_commit_all(
  repopath = d:/workshop/usinggitinbasesas2,
  author   = paulvanmol,
  email    = paul.van.mol@gmail.com,
  message  = Staged all SAS programs including subdirectories
);
