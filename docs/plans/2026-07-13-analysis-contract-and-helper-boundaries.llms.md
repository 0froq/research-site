# Analysis Contract and Helper Boundaries Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make the active raw-annual analysis definitions explicit and remove retired STARS data preparation from the live research site.

**Architecture:** Keep the canonical, renderable analysis contract in `site/docs/`, with a data-process symlink as a local entry point. Move chapter-level ingestion and reusable preparation into focused R helpers; retain only plot composition, tables, and prose in draft QMD files.

**Tech Stack:** Quarto, R, dplyr, readr, tidyr, ggplot2.

------------------------------------------------------------------------

### Task 1: Publish canonical definitions

**Files:**

- Create: `docs/analysis-contract.qmd`
- Modify: `../AGENTS.md`
- Modify: `../data-process/AGENTS.md`
- Create: `../../data-process/ANALYSIS_CONTRACT.md` (symlink)

**Step 1:** State raw annual LSWT as the source for warming, annual warming speed, and acceleration.

**Step 2:** State that `nt=99` STL is a PCA-only low-frequency representation and that PC1–PC5 are the interpretation set.

**Step 3:** State that STARS/ST_AIS is excluded from the active workflow.

**Step 4:** Verify all canonical documentation agrees through a targeted text search.

### Task 2: Create focused rendering helpers

**Files:**

- Create: `shared/R/kinematics-helpers.R`
- Create: `shared/R/pca-helpers.R`
- Modify: `shared/R/descriptive-helpers.R`
- Modify: `shared/R/regional-helpers.R`

**Step 1:** Move Chapter 1 CSV loading, metric summaries, state summaries, and continent aggregation into `prepare_kinematics_data()`.

**Step 2:** Move Chapter 2 PCA loading, metadata joining, regression preparation, and table accessors into `prepare_pca_data()`.

**Step 3:** Make spatial hex preparation use raw annual warming values.

**Step 4:** Delete the retired STARS loader and transformations.

### Task 3: Reduce chapters to composition

**Files:**

- Modify: `explorations/warming-acceleration/draft/01-global-kinematics.qmd`
- Modify: `explorations/warming-acceleration/draft/02-warming-patterns.qmd`

**Step 1:** Replace source-data reads and reusable transformations with helper setup objects.

**Step 2:** Correct prose and captions so PCA is described as STL-trend anomaly analysis and only five PCs are interpreted.

**Step 3:** Remove the retired STARS section/link from Chapter 2.

### Task 4: Validate without running producers

**Files:**

- Verify: `shared/R/*-helpers.R`
- Verify: both edited draft QMD files

**Step 1:** Source the helper scripts in R and call their preparation functions.

**Step 2:** Run structural scans for retired STARS paths and QMD-level CSV reads.

**Step 3:** Render each edited QMD only after helper execution succeeds, then inspect for cross-reference and inline-value errors.

Back to top
