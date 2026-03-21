/* ----------------------------------------------------------------
   Audit trail report using GIT_COMMIT_LOG / GIT_COMMIT_GET
   Works in SAS 9.4M6+ with GIT_ functions
   ---------------------------------------------------------------- */
%let repo = D:\workshop\dev\ABC-001\programs;

data work.git_audit;
  length hash $40 author $100 email $100 message $500 commit_dt 8;
  format commit_dt datetime20.;

  /* get total number of commits */
  n_commits = git_commit_log("&repo");

  do i = 1 to n_commits;
    hash      = git_commit_get(i, "&repo", "SHA");
    author    = git_commit_get(i, "&repo", "AUTHOR_NAME");
    email     = git_commit_get(i, "&repo", "AUTHOR_EMAIL");
    message   = git_commit_get(i, "&repo", "MESSAGE");
    commit_dt = input(git_commit_get(i, "&repo", "AUTHOR_DATE"),
                      anydtdtm.);
    output;
  end;

  drop i n_commits;
run;

proc print data=work.git_audit noobs;
  var commit_dt author message hash;
  title "Audit trail — &repo";
run;
