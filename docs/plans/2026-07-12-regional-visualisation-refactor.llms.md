# Regional Visualization Refactor Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Separate Chapter 2 regional rendering-time data preparation from plotting and remove obsolete commented experiments.

**Architecture:** Keep durable inputs in `data-process/`; add `shared/R/regional-helpers.R` for loading, joins, summary statistics, point-size derivation, metric-long data, and contour input preparation. Keep `02-regional.qmd` limited to helper calls, plot layers, Quarto tables, and explanatory text.

**Tech Stack:** Quarto, R, dplyr, tidyr, readr, ggplot2, GGally, patchwork, sf/rnaturalearth.

------------------------------------------------------------------------

### Task 1: Remove obsolete experiments

**Files:**

- Modify: `explorations/warming-acceleration/draft/02-regional.qmd:431-1125`

**Step 1: Delete HTML-commented R blocks**

Delete the four ```` <!-- ```{r} ... ``` --> ```` regions: the old cluster map/ridges, continent heatmap, regime-shift composition, and empty placeholder. Do not alter the rendered chapter text or the two active figures.

**Step 2: Confirm cleanup**

Run a structural scan and confirm no ```` <!-- ```{r} ```` marker remains and that only active chunks remain.

### Task 2: Add regional data helpers

**Files:**

- Create: `shared/R/regional-helpers.R`
- Modify: `explorations/warming-acceleration/draft/02-regional.qmd:5-10`

**Step 1: Add stable response-type definitions**

Define the K=5 cluster palette, names, and interpretations in the helper file. Keep these chapter-specific semantic definitions out of the generic figure-style file.

**Step 2: Add `prepare_regional_cluster_data()`**

Read the three curated CSV inputs, join cluster assignment, metadata and thermal metrics, derive `point_size`, construct the cluster summary including the 2020 anomaly and display label, and return all data required by the map, violin plots, and inline table.

**Step 3: Add `prepare_cluster_metric_long()` and `prepare_cluster_density_data()`**

Move metric reshaping, finite-value filtering, and density-panel limits to helpers. Return data frames only; keep density contour breaks and visual encodings in qmd.

**Step 4: Source helpers and add an invisible setup chunk**

Source `regional-helpers.R` from the Chapter 2 setup chunk. Add a cached, `include: false` setup chunk that calls the helper and exposes named objects for plotting and inline table access.

### Task 3: Reduce the cluster map/violin figure to plotting

**Files:**

- Modify: `explorations/warming-acceleration/draft/02-regional.qmd:active cluster figure`

**Step 1: Delete local ingestion, joins, summary functions, coastline conversion, and violin reshaping**

Replace them with the setup outputs. Keep `cluster_table_value()`, `cluster_table_count()` and `cluster_table_anomaly()` in the invisible setup because they serve inline Quarto table cells.

**Step 2: Use shared map elements and tokens**

Replace manual coastline conversion with `the_geom_coastline()`, and replace hardcoded coastline/grid styles with `theme_map_grid()` and tokens. Preserve the existing map extent, legend labels, point-size encoding, and composed output.

**Step 3: Keep plot-specific style local**

Leave patchwork geometry, violin width, alpha, legend override, title text and figure layout in qmd because they are part of the figure’s presentation rather than data preparation.

### Task 4: Reduce the cluster-density figure to plotting

**Files:**

- Modify: `explorations/warming-acceleration/draft/02-regional.qmd:active density figure`

**Step 1: Consume helper-provided density data**

Replace the in-chunk `density_df` filter with `cluster_density_data` from the invisible setup.

**Step 2: Remove dead continuous-colour legend configuration**

The current polygons and contours use discrete cluster colour plus alpha; the unused continuous `scale_colour_gradient()` conflicts conceptually with that encoding and should be removed. Preserve the native discrete cluster legend and the per-cluster normalized density contours.

**Step 3: Use shared theme/token primitives**

Use `theme_map_grid()` or a narrowly scoped theme built from `theme_base(grid = TRUE)`, replacing hardcoded grey grid/contour tokens where their shared equivalents express the same purpose.

### Task 5: Validate rendered figures

**Files:**

- Modify: `shared/R/regional-helpers.R`
- Modify: `explorations/warming-acceleration/draft/02-regional.qmd`

**Step 1: Execute active figure chunks**

Source both shared helper files and run the Chapter 2 setup, map/violin, and density chunks in R.

**Step 2: Render Chapter 2**

Run Quarto render for `02-regional.qmd`; confirm both figures and the inline cluster summary table render without errors.

**Step 3: Inspect output**

Verify K=5 labels, map geography, violin facets, cluster colours, and contour panel legends remain semantically unchanged.

Back to top
