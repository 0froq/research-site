# Metric Caveat and PCA Interpretation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make the active chapters distinguish provisional raw-difference acceleration from robust conclusions, and interpret PCA components without sign, hiatus, or teleconnection overclaim.

**Architecture:** Keep data production unchanged. Add a visible caveat for the current acceleration estimator, expose distribution diagnostics through the Chapter 1 helper, and rewrite Chapter 2 around score-loading algebra and sign indeterminacy.

**Tech Stack:** Quarto, R, dplyr, ggplot2.

------------------------------------------------------------------------

### Task 1: Mark acceleration as provisional

**Files:** - Modify: `explorations/warming-acceleration/draft/01-global-kinematics.qmd` - Modify: `docs/analysis-contract.qmd`

**Step 1:** Add a caveat: raw annual first-difference Sen slope has high dispersion and is descriptive pending estimator revision.

**Step 2:** Render Chapter 1 with `quarto render <absolute-qmd-path> --to html --no-cache`.

### Task 2: Correct PCA semantics

**Files:** - Modify: `explorations/warming-acceleration/draft/02-warming-patterns.qmd`

**Step 1:** Replace causal labels with temporal contrasts.

**Step 2:** Explain PC sign indeterminacy and score × loading reconstruction before interpreting PC1.

**Step 3:** Remove hiatus and ENSO attribution claims from labels, maps, prose, and future-Chapter-3 language.

**Step 4:** Render Chapter 2.

### Task 3: Verify and publish

**Files:** - Modify: `deploy.sh` only if validation exposes a deployment defect.

**Step 1:** Render project.

**Step 2:** Check source and output references for `hiatus`, `ENSO`, and unsupported `acceleration` claims.

**Step 3:** Commit and deploy only after both chapters pass.

Back to top
