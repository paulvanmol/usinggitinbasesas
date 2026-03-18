/*specify path to local repository*/
%let path=d:/workshop/usinggitinbasesas2;

data _null_;
	n=git_status("&path");
	put n=;
run;

data _null_;
	n=git_status("&path");

	/*1*/
	rc=git_index_add("&path", "checkencoding.sas", "New");

	/*2*/
	rc=git_index_add("&path", "git_clone_example.sas", "New");

	/*2*/
	rc=git_index_add("&path", "git_init_repo.sas", "New");
	rc=git_index_add("&path", "git_clone_sas_dummy_blog.sas", "New");
	rc=git_index_add("&path", "git_stage_commit_example.sas", "New");
	rc=git_index_add("&path", "git_push_example.sas", "New");

	/*2*/
	rc=git_status_free("&path");
	n=git_status("&path");

	/*3*/
run;

data _null_;
	rc=git_commit(/*1*/
    "&path", /*2*/
    "HEAD", /*3*/
    "paulvanmol", /*4*/
    "paul.van.mol@gmail.com", /*5*/
    "git functions examples");

	/*6*/
	put rc=;
run;