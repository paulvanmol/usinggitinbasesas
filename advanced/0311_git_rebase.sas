/* =============================================================
   04_rebase.sas
   Rebase a feature branch onto the latest commit of main.

   FIX vs. original git_rebase_example_studio.sas:
   - Original used hardcoded string literals "his-branch" /
     "your-branch" inside the DATA step — those are not macro
     variables and do not resolve.
   - Capture both SHAs into macro variables using
     git_commit_get(1,...) BEFORE calling git_rebase().
   - Added %let declarations for all branch names.

   Workflow:
   1. Checkout main  → capture upstream commit SHA
   2. Checkout feature branch → capture current commit SHA
   3. Call git_rebase(repo, current_sha, upstream_sha, ...)
   4. On conflict: call git_rebase_op(..., "ABORT"|"CONTINUE")
   ============================================================= */

%let repopath      = d:/workshop/usinggitinbasesas2;
%let gituser       = paulvanmol;
%let gitemail      = paul.van.mol@gmail.com;
%let main_branch   = main;
%let feature_branch = feature/my_task;

/* Step 1: get upstream (main) HEAD commit id */
data _null_;
  length id $1024;
  rc = git_branch_chkout("&repopath", "&main_branch");
  n  = git_commit_log("&repopath");
  rc = git_commit_get(1, "&repopath", "id", id);  /* 1 = most recent */
  put id=;
  call symputx('upstream_id', id);
run;
%put upstream_id = &upstream_id;

/* Step 2: switch back to feature branch, get its HEAD */
data _null_;
  length id $1024;
  rc = git_branch_chkout("&repopath", "&feature_branch");
  n  = git_commit_log("&repopath");
  rc = git_commit_get(1, "&repopath", "id", id);
  put id=;
  call symputx('current_id', id);
run;
%put current_id = &current_id;

/* Step 3: rebase feature onto main */
data _null_;
  rc = GIT_REBASE(
    "&repopath",       /* 1: local repo path          */
    "&current_id",     /* 2: current branch tip SHA   */
    "&upstream_id",    /* 3: upstream commit to rebase onto */
    "&gituser",        /* 4: author name              */
    "&gitemail");      /* 5: author email             */
  put rc=;
  /* rc=0 : success
     rc<>0: conflicts present — use git_rebase_op() below */
run;

/* Step 4 (only if conflicts): choose one operation */
/* CONTINUE — after manually resolving a conflict     */
/* SKIP     — skip this commit and proceed            */
/* ABORT    — cancel the entire rebase                */

/*
data _null_;
  rc = git_rebase_op(
    "&repopath",
    "ABORT",             <- change to "CONTINUE" or "SKIP"
    "&feature_branch",
    "&gituser",
    "&gitemail");
  put rc=;
run;
*/
