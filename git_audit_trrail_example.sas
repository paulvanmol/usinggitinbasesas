/* ================================================================
   Audit trail report for SAS 9.4 M8/M9
   Uses GITFN_ functions (still correct for SAS 9.4 — GIT_ functions
   are Viya-only and have not been ported to SAS 9.4)
   ================================================================ */
%let repo = D:\workshop\dev\ABC-001\programs;

data work.git_audit;
  length hash     $40
         author   $100
         email    $100
         message  $500;
  format commit_dt datetime20.;

  n_commits = gitfn_commit_log("&repo");

  do i = 1 to n_commits;
    hash      = gitfn_commit_get(i, "&repo", "SHA");
    author    = gitfn_commit_get(i, "&repo", "AUTHOR_NAME");
    email     = gitfn_commit_get(i, "&repo", "AUTHOR_EMAIL");
    message   = gitfn_commit_get(i, "&repo", "MESSAGE");
    commit_dt = input(gitfn_commit_get(i, "&repo", "AUTHOR_DATE"),
                      anydtdtm.);
    output;
  end;

  call gitfn_commitfree("&repo");
  drop i n_commits;
run;

proc print data=work.git_audit noobs label;
  var commit_dt author message hash;
  label commit_dt = "Date / Time"
        author    = "Author"
        message   = "Commit message"
        hash      = "Commit hash (SHA)";
  title "Git audit trail — &repo";
  title2 "Generated: &sysdate9 &systime";
run;
