#!/usr/bin/env bash
set -euo pipefail

# Render the ten main-text figures at 600 dpi and copy only the retained
# numbered panels to a local submission staging area. This is intentionally a
# rendering/export step: it never runs data-process producers.

site_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stage_dir="$site_dir/explorations/warming-temporal-pathways/manuscript/submission/figure-export-draft"
mkdir -p "$stage_dir"

declare -a sources=(
  "explorations/warming-temporal-pathways/manuscript/02-methods.qmd|fig-data-coverage|Figure-01"
  "explorations/warming-temporal-pathways/manuscript/results/01-global-kinematics.qmd|fig-long-term-warming-distribution|Figure-02"
  "explorations/warming-temporal-pathways/manuscript/results/01-global-kinematics.qmd|fig-long-term-warming-geographic-distributions|Figure-03"
  "explorations/warming-temporal-pathways/manuscript/results/02-within-period-pathways.qmd|fig-results-local-rate-dynamics|Figure-04"
  "explorations/warming-temporal-pathways/manuscript/results/02-within-period-pathways.qmd|fig-results-pathway-examples|Figure-05"
  "explorations/warming-temporal-pathways/manuscript/results/03-warming-patterns.qmd|fig-results-pca-trajectory-space|Figure-06"
  "explorations/warming-temporal-pathways/manuscript/results/04-spatial-organization.qmd|fig-results-spatial-primary-modes|Figure-07"
  "explorations/warming-temporal-pathways/manuscript/results/04-spatial-organization.qmd|fig-results-pathway-information-overlap|Figure-08"
  "explorations/warming-temporal-pathways/manuscript/results/05-trajectory-robustness.qmd|fig-results-robustness-envelope|Figure-09"
  "explorations/warming-temporal-pathways/manuscript/results/06-climate-links.qmd|fig-results-tele-primary-fields|Figure-10"
)

last_qmd=""
for item in "${sources[@]}"; do
  IFS='|' read -r qmd label target <<< "$item"
  staged_png="$stage_dir/${target}.png"
  if [[ -f "$staged_png" && "${FORCE:-0}" != "1" ]]; then
    printf 'Reusing staged %s (set FORCE=1 to rebuild)\n' "$target"
    continue
  fi
  if [[ "$qmd" != "$last_qmd" ]]; then
    printf 'Rendering %s at 600 dpi\n' "$qmd"
    (cd "$site_dir" && quarto render "$qmd" --execute --cache-refresh --no-clean --quiet -M fig-dpi:600)
    last_qmd="$qmd"
  fi
  base="${qmd%.qmd}"
  source_png="$site_dir/_output/${base}_files/figure-html/${label}-1.png"
  if [[ ! -f "$source_png" ]]; then
    printf 'Missing expected panel: %s\n' "$source_png" >&2
    exit 1
  fi
  cp "$source_png" "$staged_png"
  printf 'Staged %s\n' "$target"
done

printf 'Verifying staged pixel dimensions and metadata\n'
for png in "$stage_dir"/*.png; do
  sips -g pixelWidth -g pixelHeight -g dpiWidth -g dpiHeight "$png"
done
