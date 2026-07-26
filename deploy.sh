#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
	cat <<'EOF'
Usage: ./deploy.sh [commit message]

Commits source changes, renders a clean Git worktree, and deploys its output to
gh-pages. When omitted, the source commit keeps the timestamp-based default
message.
EOF
	exit 0
fi

COMMIT_MESSAGE="${*:-Update $(date -u +'%Y-%m-%d %H:%M UTC')}"

# Commit the exact source revision to be rendered.
git worktree prune
echo "==> Committing source..."
git add -A -- .gitignore '*.md' '*.qmd' '*.R' '*.scss' '*.yml' '*.sh' '*.bib' '*.svg'
if git diff --cached --quiet; then
	echo "(nothing to commit)"
else
	git commit -m "$COMMIT_MESSAGE"
fi
SOURCE_COMMIT="$(git rev-parse HEAD)"

# A clean worktree contains no ignored `_output/` cache, so deleted pages can
# never be copied back into the published site.
BUILD_WORKTREE="../.site-render-$(date -u +'%Y%m%dT%H%M%SZ')-$$"
DEPLOY_DIR="$(mktemp -d)"
cleanup() {
	cd "$SCRIPT_DIR"
	git worktree remove --force "$BUILD_WORKTREE" 2>/dev/null || true
	git worktree remove --force "$DEPLOY_DIR" 2>/dev/null || true
	git worktree prune
	rm -rf "$BUILD_WORKTREE" "$DEPLOY_DIR"
}
trap cleanup EXIT

echo "==> Preparing clean render worktree..."
git worktree add --detach "$BUILD_WORKTREE" "$SOURCE_COMMIT"
echo "==> Rendering Quarto site..."
(
	cd "$BUILD_WORKTREE"
	quarto render --cache-refresh
	Rscript R/checks/route-checks.R
	Rscript R/checks/no-legacy-active-dependencies.R
)

echo "==> Pushing source to main..."
git push origin main

echo "==> Preparing gh-pages branch..."
if git rev-parse --verify gh-pages >/dev/null 2>&1; then
	git worktree add --force "$DEPLOY_DIR" gh-pages
	find "$DEPLOY_DIR" -mindepth 1 -not -name '.git' -delete
else
	git worktree add --orphan -b gh-pages "$DEPLOY_DIR"
fi

echo "==> Copying clean render to gh-pages..."
cp -R "$BUILD_WORKTREE/_output"/* "$DEPLOY_DIR/"

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
