#!/usr/bin/env bash
# new-task.sh — bikin task contract baru dari template.
# Bukan task-runner/CLI orkestrasi — cuma helper copy-paste supaya konsisten.
#
# Usage: ./scripts/new-task.sh TASK-042

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <TASK-ID>"
  echo "Contoh: $0 TASK-042"
  exit 1
fi

TASK_ID="$1"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$ROOT_DIR/tasks/TASK-TEMPLATE.md"
TARGET="$ROOT_DIR/tasks/${TASK_ID}.md"

if [ -f "$TARGET" ]; then
  echo "Task $TASK_ID sudah ada di $TARGET"
  exit 1
fi

sed "s/TASK-XXX/${TASK_ID}/" "$TEMPLATE" > "$TARGET"
echo "Dibuat: $TARGET"
echo "Silakan isi repo, role, allowed/forbidden paths, dan acceptance criteria."
