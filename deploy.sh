#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
	cat <<'EOF'
Usage: ./deploy.sh [commit message]

Renders the site, commits source changes to main, and deploys _output to gh-pages.
When omitted, the source commit keeps the timestamp-based default message.
EOF
	exit 0
fi

COMMIT_MESSAGE="${*:-Update $(date -u +'%Y-%m-%d %H:%M UTC')}"

# 0. Prune stale worktrees early (before slow render)
git worktree prune

# 1. Render
echo "==> Rendering Quarto site..."
quarto render --cache-refresh

# 2. Commit & push source changes to main
echo "==> Pushing source to main..."
git add -A -- .gitignore '*.md' '*.qmd' '*.R' '*.scss' '*.yml' '*.sh' '*.bib' '*.svg'
if git diff --cached --quiet; then
	echo "(nothing to commit)"
else
	git commit -m "$COMMIT_MESSAGE"
fi
git push origin main

# 3. Deploy _output to gh-pages branch
DEPLOY_DIR="$(mktemp -d)"
cleanup() {
	cd "$SCRIPT_DIR"
	git worktree remove --force "$DEPLOY_DIR" 2>/dev/null || true
	git worktree prune
	rm -rf "$DEPLOY_DIR"
}
trap cleanup EXIT

echo "==> Preparing gh-pages branch..."
if git rev-parse --verify gh-pages >/dev/null 2>&1; then
	git worktree add --force "$DEPLOY_DIR" gh-pages
	find "$DEPLOY_DIR" -mindepth 1 -not -name '.git' -delete
else
	git worktree add --orphan -b gh-pages "$DEPLOY_DIR"
fi

echo "==> Copying _output to gh-pages..."
cp -R _output/* "$DEPLOY_DIR/"

echo "==> Committing..."
cd "$DEPLOY_DIR"
git add -A
if git diff --cached --quiet; then
	echo "(nothing to commit)"
else
	git commit -m "Deploy: $COMMIT_MESSAGE"
fi

echo "==> Pushing gh-pages..."
git push origin gh-pages

echo "==> Done. Site will be live at https://0froq.github.io/research-site/"
