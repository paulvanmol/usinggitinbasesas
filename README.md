# basic/ — Basic Git Workflow in Base SAS

This folder contains a complete end-to-end basic Git workflow implemented using SAS `GIT_` functions. Work through the files in numbered order.

## Prerequisites

- SAS 9.4 M8 / M9 or SAS Viya (uses `GIT_` functions, not the deprecated `GITFN_` functions)
- A GitHub/Gitlab account with a Personal Access Token (PAT) that has `repo` scope
- A local folder for your working repository, e.g. `d:/workshop/mygitclone`
- Set these macro variables before running any script:

```sas
%let repopath = d:/workshop/usinggitinbasesas2;
%let gituser  = your_github_username;
%let gitemail = your@email.com;
options nosymbolgen;
%let mygitpw  = your_github_pat;
```

---

## Files

| File | Function(s) | What it does |
|------|-------------|-------------|
| `0301_init_repo.sas` | `GIT_INIT_REPO()` | Initialise a brand-new local repository |
| `0302_clone.sas` | `GIT_CLONE()` | Clone an existing remote repository to your machine |
| `0303_stage_commit.sas` | `GIT_STATUS()`, `GIT_INDEX_ADD()`, `GIT_INDEX_ADD_ALL()`, `GIT_COMMIT()` | Stage changed files and commit to the local repo |
| `0304_git_push.sas` | `GIT_PUSH()` | Push committed changes to the remote (GitHub) |
| `0305_git_pull.sas` | `GIT_PULL()` | Pull the latest commits from the remote |
| `0306_audit_trail.sas` | `GIT_COMMIT_LOG()`, `GIT_COMMIT_GET()` | Build a full commit history dataset filtered to the current branch |
| `0307_stage_commit_macro.sas` | macro wrapping above | Recursive macro that walks subdirectories and stages all `*.sas` files |

---

## Key patterns

### Always call `GIT_STATUS_FREE()` after `GIT_STATUS()`

```sas
data _null_;
  n  = git_status("&repopath");   /* returns count of changed files */
  rc = git_status_free("&repopath");   /* release the handle */
run;
```

### `GIT_INDEX_ADD()` — pass the correct status string

The third argument must match the actual file state:

| Situation | Status string |
|-----------|---------------|
| New file not yet tracked | `"New"` |
| File already tracked, modified | `"Modified"` |
| File deleted from disk | `"Deleted"` |

### Always `PUT rc=` after every function call

All `GIT_` functions return `0` on success and a non-zero code on failure. Printing `rc` is your first debugging step.

---

## Notes on this folder vs. the original examples

The scripts in this folder are updated versions of the original flat-root examples. Key corrections:

- `0303_stage_commit.sas` — the original always passed `"New"` as the status. The updated version detects actual file status using `GIT_STATUS_GET()` and passes `"Modified"` or `"Deleted"` where appropriate.
- `0306_audit_trail.sas` — the original iterated all commits without filtering. The updated version filters on `in_current_branch="TRUE"` so only commits on the active branch are returned.

See `advanced/` for branching, stash, and rebase workflows.
