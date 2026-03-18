/*specify path to local repository*/
%let path=d:/workshop/usinggitinbasesas2;

data _null_;
	n=git_status("&repopath");
	put n=;
run;

data _null_;
	n=git_status("&repopath");

	/*1*/
	rc=git_index_add("&repopath", "checkencoding.sas", "New");

	/*2*/
	rc=git_index_add("&repopath", "git_clone_example.sas", "New");

	/*2*/
	rc=git_index_add("&repopath", "git_init_repo.sas", "New");
	rc=git_index_add("&repopath", "git_clone_sas_dummy_blog.sas", "New");
	rc=git_index_add("&repopath", "git_stage_commit_example.sas", "New");
	rc=git_index_add("&repopath", "git_push_example.sas", "New");
		rc=git_index_add("&repopath", "git_branch_new.sas", "New");

	/*2*/
	rc=git_status_free("&repopath");
	n=git_status("&repopath");

	/*3*/
run;

data _null_;
	rc=git_commit(/*1*/
    "&repopath", /*2*/
    "HEAD", /*3*/
    "paulvanmol", /*4*/
    "paul.van.mol@gmail.com", /*5*/
    "git functions examples");

	/*6*/
	put rc=;
run;