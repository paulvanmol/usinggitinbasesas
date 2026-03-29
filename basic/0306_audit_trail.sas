/* =============================================================
   06_audit_trail.sas
   Build a commit history dataset for the current branch.

   FIX vs. original git_audit_trail_example.sas:
   - Filter on in_current_branch="TRUE" so only commits
     belonging to the active branch are included.
   - Original iterated all commits without branch filtering,
     which returns commits from all branches.

   Useful for:
   - Regulatory audit trails (21 CFR Part 11)
   - Change reports per study/per programmer
   - Finding the latest commit SHA before branching
   ============================================================= */

%let repopath = d:/workshop/usinggitinbasesas2;

/* ── Full branch-scoped commit history ── */
data commit_history;
  length id $1024 author $256 email $256
         msg $1024 time $17 in_branch $6;

  n = git_commit_log("&repopath");
  put n=;

  if n > 0 then do;
    do i = 1 to n;
      rc = git_commit_get(i, "&repopath", "id",               id);
      rc = git_commit_get(i, "&repopath", "author",           author);
      rc = git_commit_get(i, "&repopath", "email",            email);
      rc = git_commit_get(i, "&repopath", "message",          msg);
      rc = git_commit_get(i, "&repopath", "time",             time);
      rc = git_commit_get(i, "&repopath", "in_current_branch",in_branch);

      /* Only keep commits on the current branch */
      if in_branch = "TRUE" then output;
    end;
  end;

  drop rc i n;
run;

proc print data=commit_history; run;

/* ── Capture latest commit SHA for branching ── */
data _null_;
  set commit_history(obs=1);
  call symputx('latest_id', id);
run;
%put latest commit id = &latest_id;
