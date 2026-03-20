%let repopath = d:/workshop/usinggitinsasstudio;

/* Step 2: Get the commit ID of the UPSTREAM branch
(e.g., main) to rebase onto.
Check out main temporarily to capture its HEAD commit. */
data _null_;
	rc=git_branch_chkout("&repopath", "his-branch");
	put rc=;
run;

/*Get the latest commit-id of the his-branch */
data commit_get_rebase;
	length id $ 1024 in_current_branch $6 time $17;
	if _n_=1 then call missing (in_current_branch, time, id);
	*format time datetime.;
	n=git_commit_log("&repopath");
	put n=;

	if n > 0 then
		do;

			do i=1 to n;
				rc=git_commit_get(i, "&repopath", "id", id);
  				rc=git_commit_get(i, "&repopath", "time", time);
				rc=git_commit_get(i, "&repopath", "in_current_branch", in_current_branch);
				if in_current_branch="TRUE" then idnum+1;
/* most recent commit = position 1 */
				if idnum=1 and in_current_branch="TRUE"  then
					call symputx('upstream_commit_id', id);
				output;
			end;
		end;
run;

%put upstream_commit_id = &upstream_commit_id;

/* Step 3: Check your feature branch back out */
data _null_;
	rc=git_branch_chkout("&repopath", "your-branch");
	put rc=;
run;

/*Get the latest commit-id of the his-branch */
data commit_get_current;
	length id $ 1024 in_current_branch $6 time $17;
	*format time datetime.;
	n=git_commit_log("&repopath");
	put n=;

	if n > 0 then
		do;

			do i=1 to n;
				rc=git_commit_get(i, "&repopath", "id", id);
				rc=git_commit_get(i, "&repopath", "time", time);
				rc=git_commit_get(i, "&repopath", "in_current_branch", in_current_branch);
                if in_current_branch="TRUE" then idnum+1;
				/* most recent commit = position 1 */
				if idnum=1 and in_current_branch="TRUE"  then
					call symputx('current_commit_id', id);
				output;
			end;
		end;
run;

%put current_commit_id = &current_commit_id;

/* Step 4: Rebase your-branch onto the upstream commit */
data _null_;
	rc=GIT_REBASE("&repopath", /* 1: local repo path           */
    "&current_commit_id" ,   /* 2: current branch            */
    "&upstream_commit_id", /* 3: commit to rebase ONTO     */
    "paulvanmol", /* 4: author name               */
    "paul.van.mol@gmail.com" /* 5: author email             */);
	put rc=;
run;


data _null_;
   rc = git_rebase_op(
   "&repopath",
    "ABORT",
    "your-branch",
    "paulvanmol",
    "paul.van.mol@gmail.com");
put rc=;
run;