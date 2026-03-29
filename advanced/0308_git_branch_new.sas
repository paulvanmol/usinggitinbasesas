/* =============================================================
   01_branch_new.sas
   Create a feature branch from the latest commit on main.

   FIX vs. original git_branch_new.sas:
   - git_branch_new() arg 2 must be the SHA commit ID string,
     not the integer returned by git_commit_log().
   - Use git_commit_get(1,...,"id",...) to retrieve the SHA.
   ============================================================= */

%let repopath  = d:/workshop/usinggitinbasesas2;
%let branchname = feature/my_task;

/* Step 1: capture the most recent commit ID on the current branch */
data _null_;
  length id $1024;
  n  = git_commit_log("&repopath");
  rc = git_commit_get(1, "&repopath", "id", id);   /* position 1 = most recent */
  put id=;
  call symputx('latest_id', id);
run;
%put latest_id = &latest_id;

/* Step 2: create the new feature branch from that commit */
data _null_;
  rc = git_branch_new(
    "&repopath",     /* 1: local repo path               */
    "&latest_id",    /* 2: base commit SHA (not a count) */
    "&branchname",   /* 3: new branch name               */
    1);              /* 4: overwrite=1 if branch exists  */
  put rc=;
run;

/* Step 3: switch to the new branch */
data _null_;
  rc = git_branch_chkout("&repopath", "&branchname");
  put rc=;
run;
