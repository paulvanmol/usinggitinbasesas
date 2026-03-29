# advanced/ — Advanced Git Workflow in Base SAS

This folder covers branching, stashing, and rebasing using SAS `GIT_` functions. These are the building blocks for team-based feature-branch workflows.

**Complete the `basic/` workflow first** — these scripts assume you can already clone, stage, commit and push.

## Prerequisites

Same as `basic/` plus:
- At least one commit in your repository (branching requires a commit to branch from)
- Set these macro variables:

```sas
%let repopath       = d:/workshop/usinggitinbasesas2;
%let gituser        = your_github_username;
%let gitemail       = your@email.com;
%let main_branch    = main;
%let feature_branch = feature/my_task;
```

---

## Files

| File | Function(s) | What it does |
|------|-------------|-------------|
| `0308_git_branch_new.sas` | `GIT_COMMIT_GET()`, `GIT_BRANCH_NEW()`, `GIT_BRANCH_CHKOUT()` | Get the latest commit SHA, create a feature branch from it, and switch to it |
| `0309_git_branch_chkout.sas` | `GIT_BRANCH_CHKOUT()` | Switch between branches |
| `0310_git_stash.sas` | `GIT_STASH()`, `GIT_STASH_POP()`, `GIT_STASH_APPLY()`, `GIT_STASH_DROP()` | Shelve and restore in-progress work |
| `0311_git_rebase.sas` | `GIT_REBASE()`, `GIT_REBASE_OP()` | Replay feature branch commits onto main |

---

## Branching — the most important fix

### ❌ Original (incorrect)

```sas
data _null_;
  n = git_commit_log("&repopath");    /* n = count of commits, e.g. 7 */
  rc = git_branch_new(
    "&repopath",
    n,                  /* WRONG: passing integer count, not a SHA */
    "feature/task",
    1);
run;
```

### ✅ Corrected

```sas
data _null_;
  length id $1024;
  n  = git_commit_log("&repopath");
  rc = git_commit_get(1, "&repopath", "id", id);  /* position 1 = most recent */
  call symputx('latest_id', id);
run;

data _null_;
  rc = git_branch_new(
    "&repopath",
    "&latest_id",       /* CORRECT: SHA string like "a3f9c1..." */
    "feature/task",
    1);
run;
```

`git_commit_get()` at position `1` returns the most recent commit on the current branch. The SHA string is what `GIT_BRANCH_NEW()` expects as argument 2.

---

## Stash — the four operations

| Function | What happens to the stash entry |
|----------|--------------------------------|
| `GIT_STASH(repo, name, email)` | Saves uncommitted work; clears working directory |
| `GIT_STASH_POP(repo)` | Restores top stash **and removes** it from the stack |
| `GIT_STASH_APPLY(repo)` | Restores top stash but **keeps** it on the stack |
| `GIT_STASH_DROP(repo)` | **Deletes** the top stash entry without restoring |

Typical scenario: stash → switch branch for hotfix → commit hotfix → switch back → pop stash.

---

## Rebase — branch parameterisation fix

### ❌ Original (string literals in DATA step)

```sas
data _null_;
  rc = git_branch_chkout("&repopath", "his-branch");  /* hardcoded */
  ...
  call symputx('upstream_commit_id', id);
run;
```

### ✅ Corrected (macro variables throughout)

```sas
%let main_branch    = main;
%let feature_branch = feature/my_task;

/* capture upstream SHA */
data _null_;
  length id $1024;
  rc = git_branch_chkout("&repopath", "&main_branch");
  n  = git_commit_log("&repopath");
  rc = git_commit_get(1, "&repopath", "id", id);
  call symputx('upstream_id', id);
run;
```

Using `%let` for all branch names means you only change one line to adapt the script to a different branch pair.

---

## Note on `GIT_BRANCH_DELETE()`

`GIT_BRANCH_DELETE()` only deletes **local** branches. To delete a remote branch on GitHub, use the GitHub web UI or the CLI:

```bash
git push origin --delete feature/my_task
```

There is no SAS function for remote branch deletion.

---

## Note on tags

SAS provides no `GIT_TAG()` function and SAS Studio has no tag UI. Tag releases from the GitHub web UI or CLI.
