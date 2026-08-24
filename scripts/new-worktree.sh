#!/usr/bin/env bash
# new-worktree.sh — bikin git worktree isolated untuk satu task, di repo mana pun.
# Ini pengganti "isolation: worktree" secara manual & engine-netral
# (dipakai baik untuk sesi Claude Code maupun OpenCode).
#
# Usage: ./scripts/new-worktree.sh <path-ke-repo> <TASK-ID> [base-branch]
# Contoh: ./scripts/new-worktree.sh ../backend-api TASK-042 main

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <path-ke-repo> <TASK-ID> [base-branch]"
  echo "Contoh: $0 ../backend-api TASK-042 main"
  exit 1
fi

REPO_PATH="$1"
TASK_ID="$2"
BASE_BRANCH="${3:-main}"
BRANCH_NAME="task/${TASK_ID}"
WORKTREE_PATH="${REPO_PATH}-wt-${TASK_ID}"

cd "$REPO_PATH"
git fetch origin "$BASE_BRANCH" --quiet || true
git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME" "origin/${BASE_BRANCH}" 2>/dev/null \
  || git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME" "$BASE_BRANCH"

echo "Worktree dibuat: $WORKTREE_PATH (branch: $BRANCH_NAME)"
echo "Jalankan Claude Code / OpenCode dari dalam folder tersebut untuk task ini."
