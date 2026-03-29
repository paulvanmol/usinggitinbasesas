/* =============================================================
   03_stage_commit.sas
   Stage changed files and commit to the local repository.

   FIX vs. original git_stage_commit_example.sas:
   - git_index_add() 3rd argument must reflect the actual file
     state: "New", "Modified", or "Deleted".
   - Original hardcoded "New" for all files.
   - Use git_status() / git_status_get() to detect each file's
     actual state before staging.
   ============================================================= */

%let repopath = d:/workshop/usinggitinbasesas2;
%let gituser  = paulvanmol;
%let gitemail = paul.van.mol@gmail.com;

/* ── Stage individual files with correct status ───────────────
   Query status first, then pass the matching status string.
   Valid status values: "New" | "Modified" | "Deleted"
   ─────────────────────────────────────────────────────────── */
data _null_;
  /* Build a status dataset first */
  n = git_status("&repopath");
  put n=;       /* n = number of changed files */
run;

/* Retrieve status per file and stage each one */
data _null_;
  length filepath $1024 filestatus $20;

  n = git_status("&repopath");

  do i = 1 to n;
    rc = git_status_get(i, "&repopath", "path",   filepath);
    rc = git_status_get(i, "&repopath", "status", filestatus);
    put filepath= filestatus=;

    /* Stage with the correct status string */
    rc = git_index_add("&repopath", filepath, filestatus);
    put rc=;
  end;

  rc = git_status_free("&repopath");   /* always free after use */
run;

/* ── Commit everything staged ── */
data _null_;
  rc = git_commit(
    "&repopath",           /* 1: local repo path   */
    "HEAD",                /* 2: parent commit ref */
    "&gituser",            /* 3: author name       */
    "&gitemail",           /* 4: author email      */
    "Update SAS programs"); /* 5: commit message   */
  put rc=;
run;
