#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# 1. Render
echo "==> Rendering Quarto site..."
quarto render

# 2. Commit & push source changes to main
echo "==> Pushing source to main..."
git add -A
git commit -m "Update $(date -u +'%Y-%m-%d %H:%M UTC')" || echo "(nothing to commit)"
git push origin main

# 3. Deploy _output to gh-pages branch
DEPLOY_DIR="$(mktemp -d)"
trap 'rm -rf "$DEPLOY_DIR"' EXIT

echo "==> Preparing gh-pages branch..."
if git rev-parse --verify gh-pages >/dev/null 2>&1; then
  git worktree add "$DEPLOY_DIR" gh-pages
  # Clean existing content (keep .git)
  find "$DEPLOY_DIR" -mindepth 1 -not -name '.git' -delete
else
  git worktree add --orphan -b gh-pages "$DEPLOY_DIR"
fi

echo "==> Copying _output to gh-pages..."
cp -R _output/* "$DEPLOY_DIR/"

echo "==> Committing..."
cd "$DEPLOY_DIR"
git add -A
git commit -m "Deploy $(date -u +'%Y-%m-%d %H:%M UTC')" || echo "(nothing to commit)"

echo "==> Pushing gh-pages..."
git push origin gh-pages

echo "==> Done. Site will be live at https://0froq.github.io/research-site/"
