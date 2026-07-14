# Current Research Roadmap Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Turn the current exploratory outputs into a coherent, reproducible descriptive study of heterogeneous observed lake-warming trajectories, with constrained seasonal/ice and ERA5 association follow-up.

**Architecture:** Keep durable lake-scale computation in `data-process/steps/14-trajectory-diagnostics/`; expose small prepared tables through focused R helpers; keep QMD files to prose, figure composition, and tables. The study has two representations: raw annual LSWT is the observed-temperature layer; `nt=99` monthly STL trend is a sensitivity/background layer and PCA input, not the main Chapter 1 measure.

**Tech Stack:** Julia, CSV.jl, DataFrames.jl; R/readr/dplyr/tidyr/ggplot2; Quarto.

---

## Audit of the superseded plan

`explorations/warming-acceleration/EXECUTION_PLAN.md` is historical, not executable. It assumes STL `nt=199`, STARS regime detection, cluster chapter filenames, and a causal/teleconnection trajectory that conflict with the current analysis contract. Preserve it only as history; do not implement its Work Packages A--C.

The valid work already completed is:

- raw annual long-term Theil--Sen warming for 92,245 lakes;
- Step 14 raw seasonal/ice diagnostics, rolling 7- and 10-year Sen speeds, and raw/STL sensitivity products;
- descriptive late-period cooling result and ERA5 scope/gap record;
- PCA PC1--PC5 draft and a contract for stability checking.

The current weak points are:

- Ch1 still contains old adjacent-difference tables/maps and needs full visual refactoring;
- the raw 10-year speed sequence has not yet been turned into its full temporal/spatial figure set;
- PCA stability is specified but not run;
- ERA5 analysis is only unadjusted association, not spatially validated;
- seasonal/ice results are prose-only, without a reproducible chapter figure/helper.

### Task 1: Finish Chapter 1 refactor around raw 10-year local speed

**Files:**
- Modify: `shared/R/kinematics-helpers.R`
- Modify: `explorations/warming-acceleration/draft/01-global-kinematics.qmd`

1. Source `figure-style.R`, `descriptive-helpers.R`, and `kinematics-helpers.R`; assert the Step 14 input has 92,245 rows and 1990--2020 valid local-speed columns.
2. Replace all remaining adjacent-difference labels, values, maps and continent table fields with `annual_roll10_sen_accel_1e3`, named *warming-speed change*.
3. Add three figures: global median/IQR local speed through time; selected endpoint-year maps of local speed; map of long-term local-speed change.
4. Keep long-term raw Theil--Sen warming separate from local speed.
5. Render the QMD with an absolute path and inspect figure captions, inline values, legends and translations.

### Task 2: Make cooling/ice diagnostics a reproducible result

**Files:**
- Create: `shared/R/seasonal-ice-helpers.R`
- Modify: `explorations/warming-acceleration/prose/seasonal-ice-diagnostics.qmd`

1. Read only Step 14 diagnostics and generate cohort, latitude-band, seasonal-slope and ice-day summary data.
2. Report full-period and late-period cooling in parallel; do not privilege a late window.
3. Plot seasonal trends for cooling/non-cooling lakes, stratified by baseline ice duration and latitude band.
4. Map the summer-associated subset descriptively.
5. State glacier meltwater only as a hypothesis requiring upstream catchments, glacier linkage, discharge and inflow-temperature data.

### Task 3: Run PCA stability tests before extending interpretation

**Files:**
- Create: `data-process/steps/15-pca-stability/run.jl`
- Create: `data-process/steps/15-pca-stability/README.md`
- Create: `shared/R/pca-stability-helpers.R`
- Modify: `explorations/warming-acceleration/draft/02-warming-patterns.qmd`

1. Smoke-test PCA stability producer on 20 lakes.
2. Run repeated random half-sample PCA, sign-align components, and output PC1--PC5 variance/loading congruence.
3. Run leave-one-continent-out PCA and output matched-component congruence.
4. Render one compact stability figure/table in Ch2; weaken or remove any unstable PC interpretation.
5. Do not introduce causal language.

### Task 4: Convert existing ERA5 data into a constrained association analysis

**Files:**
- Create: `shared/R/era5-association-helpers.R`
- Modify: `explorations/warming-acceleration/prose/era5-association-scope.qmd`

1. Build geography-only and geography-plus-available-ERA5 models for PC scores and raw trajectory metrics.
2. Use deterministic geographic blocks for held-out validation.
3. Report performance increment and coefficient instability, not causal effects.
4. Update missing-variable register: T2m, short/longwave, humidity/latent heat, glacier/catchment/inflow data, and lake/catchment process covariates.

### Task 5: Consolidate and release

**Files:**
- Modify: `docs/analysis-contract.qmd`, `AGENTS.md`, affected prose and draft files

1. Reconcile every definition and unit with Step 14 metadata.
2. Remove/redirect obsolete narrative references, but preserve archival files outside active navigation.
3. Render all edited QMDs individually, then render the site.
4. Inspect generated HTML and run `git diff --check`.
5. Commit source changes with a semantic message and deploy only after render validation.
