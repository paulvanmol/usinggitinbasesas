# usinggitinbasesas

Examples of `GIT_` functions in Base SAS — covering basic and advanced Git workflows entirely in SAS code.

> These examples were developed independently and later cross-referenced against the official SAS documentation. See the **Corrections** section below for what changed.

---

## Repository structure

```
usinggitinbasesas/
├── basic/
│   ├── README.md
│   ├── 01_init_repo.sas
│   ├── 02_clone.sas
│   ├── 03_stage_commit.sas        ← updated: correct status strings
│   ├── 04_push.sas
│   ├── 05_pull.sas
│   ├── 06_audit_trail.sas         ← updated: in_current_branch filter
│   └── 07_stage_commit_macro.sas  ← updated: detect status per file
│
└── advanced/
    ├── README.md
    ├── 01_branch_new.sas           ← updated: SHA not integer
    ├── 02_branch_checkout.sas
    ├── 03_stash.sas
    └── 04_rebase.sas               ← updated: macro variables
```

Work through `basic/` first, then `advanced/`. Each folder has its own README with prerequisites and key patterns.

---

## Requirements

- SAS 9.4 M8 or M9 (uses `GIT_` functions — **not** the deprecated `GITFN_` prefix)
- A remote repository on GitHub, GitLab, Azure Repos, or Bitbucket
- A Personal Access Token (PAT) with `repo` scope stored in a macro variable

---

## Quick start

```sas
/* Set once before running any script */
%let repopath = d:/workshop/usinggitinbasesas2;
%let gituser  = your_github_username;
%let gitemail = your@email.com;
options nosymbolgen;
%let mygitpw  = your_github_pat;

/* Clone */
data _null_;
  rc = git_clone("https://github.com/your/repo", "&repopath");
  put rc=;
run;
```

---

## Corrections from documentation review

The original examples were written before consulting the official SAS documentation. After cross-referencing, four corrections were identified:

| File | Issue | Fix |
|------|-------|-----|
| `03_stage_commit.sas` | `GIT_INDEX_ADD()` always called with `"New"` | Must pass `"New"`, `"Modified"`, or `"Deleted"` based on actual file state |
| `06_audit_trail.sas` | Iterated all commits without branch scoping | Filter on `in_current_branch="TRUE"` |
| `01_branch_new.sas` | Passed `n` (integer count) as commit ID to `GIT_BRANCH_NEW()` | Must pass the SHA string from `git_commit_get(1,...,"id",...)` |
| `04_rebase.sas` | Used hardcoded branch name strings inside DATA step | Use `%let` macro variables for all branch names |

---

## References

- [SAS GIT Functions reference](https://documentation.sas.com/doc/en/pgmsascdc/v_070/lefunctionsref/n1mlc3f9w9zh9fn13qswiq6hrta0.htm)
- [Demystifying Git — SAS Communities Library](https://communities.sas.com/t5/SAS-Communities-Library/bg-p/library)
