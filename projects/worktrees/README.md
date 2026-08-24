# Worktree Isolation

Worktrees are local execution folders. They are not part of the root orchestration repo.

Because M2S-IMS uses three repositories, worktrees must be created from the correct child repository.

## Backend Worktree

Backend repository:

```text
https://github.com/fajarcandraaa/backend-m2s-ims.git
```

Example:

```bash
cd backend-m2s-ims
git fetch origin
git worktree add ../worktrees/backend/be-001-auth-api -b feature/be-001-auth-api origin/main
```

## Frontend Worktree

Frontend repository:

```text
https://github.com/fajarcandraaa/frontend-m2s-ims.git
```

Example:

```bash
cd frontend-m2s-ims
git fetch origin
git worktree add ../worktrees/frontend/fe-001-login-page -b feature/fe-001-login-page origin/main
```

## Rules

- One coding agent = one worktree.
- Backend agent only works in backend worktrees.
- Frontend agent only works in frontend worktrees.
- QA tests from integration branches or approved integration worktrees.
- Do not run two agents on the same worktree.
- Root repo ignores `worktrees/backend/*` and `worktrees/frontend/*` except README files.
