# Warming acceleration — execution plan

> **Status:** implementation plan for subsequent agents.
>
> **Implementation note (2026-07-12):** Work package A is complete and `12-warming-speed-regimes` has been implemented and run. The canonical `L=7`, `p=0.05` branch yields 251,922 events across 92,245 lakes, or 2.73 shifts per lake, consistent with the established interpretation that a lake typically has roughly three warming-speed shifts. Its `multiple_shifts` prevalence represents sequential speed-regime dynamics, not an implementation failure. `L=10` is retained only as a sensitivity branch. Chapter 02 should use the canonical `L=7` output while explicitly explaining that a lake can traverse several speed regimes.
>
> **Scope:** canonical data products, analysis scripts, and the `site/explorations/warming-acceleration/draft/` narrative.
>
> **Do not treat this as a results document.** It separates established inputs, candidate signals, and results that require spatially robust modelling.

## 0. Contracts, current truth, and non-negotiable rules

### Applicable contracts

- `site/AGENTS.md` does **not** exist. Use the repository-root `AGENTS.md` for site rules and `data-process/AGENTS.md` for producer-step rules.
- The root `AGENTS.md` section headed “Current draft status” is historical and stale: it still describes K=8 clustering and an old teleconnection chapter. Do not restore those assumptions.
- `data-process/steps/*/output/` is the source of truth. QMD files may read curated outputs and make figure-scale joins/reshapes through `site/shared/R/*-helpers.R`; they must not create durable scientific data during render.
- Do not reuse paths mentioned only in `data-process-audit.md` such as old `analysis/r-data/regime_*` outputs. They are historical audit references, not canonical inputs.

### Canonical study scope

- Sample: 92,245 GLAST lakes, 1981–2020.
- Canonical low-frequency series: `steps/05-annual-stl-trend/output/period12_robustfalse_ni5_no0_nt99/annual_stl_trend.csv`.
- Canonical clusters: `steps/07-warming-response-clustering/output/stl_trend_period12_robustfalse_ni5_no0_nt99_baseline1981_1990_pca095_k4-8/`, selected K=5.
- Canonical joined predictor table: `steps/11-warming-attribution-data/output/lake_warming_attribution_data.csv`.
- ERA5-Land precipitation has been corrected for the `moda` convention: monthly `tp` is m/day and annual/seasonal totals are day weighted. Preserve this interpretation in every subsequent figure and prose statement.

### Canonical kinematic definitions

For lake *i*, let `τ_i(t)` be the annual STL trend in °C.

``` txt
v_i(t) = τ_i(t) − τ_i(t − 1)                 annual warming speed, °C/yr
S_i    = SenSlope[τ_i(t)] × 40                long-term warming speed, °C/40 yr
a_i    = SenSlope[v_i(t)] × 1000              acceleration, 10⁻³ °C/yr²
```

Use `S_i` and `a_i` together in the core narrative. Raw annual-temperature Sen slopes are valid robustness/descriptive quantities, but must not be labelled the main “warming speed” in a figure whose acceleration is derived from the STL trend.

### Scientific interpretation boundary

- `a_i > 0` means the low-frequency temperature trend becomes more positive through time. It does **not** by itself mean that the lake has the fastest absolute warming.
- STARS on `v(t)` detects a persistent **mean-level shift in warming speed**.
- A segmented regression on `v(t)` detects a **change in acceleration** (a slope change of speed).
- Per-lake teleconnection correlation coefficients are outcome-derived **sensitivity descriptors**. Never put `tele_*_r` into a cross-sectional model explaining the same lake’s warming speed, acceleration, or cluster; that would be leakage.
- All current forcing/teleconnection correlations are candidate signals. Do not call them causal effects before spatial block CV and residual spatial-autocorrelation checks.

------------------------------------------------------------------------

## 1. Narrative target and chapter architecture

The project’s central claim should be:

> Global lake warming is nearly universal, but its kinematics are heterogeneous: lakes warm at different long-term speeds, accelerate or decelerate differently, and undergo persistent changes in warming speed at different times and in different regions.

Build three chapters around that claim.

| Chapter | File | Question | Main output type |
|----|----|----|----|
| 01 | `draft/01-global-kinematics.qmd` | How widespread are warming, acceleration, and their spatial separation? | Global descriptive distributions/maps |
| 02 | `draft/02-response-types.qmd` | How do response types differ in temporal trajectory, spatial organisation, and warming-speed regime sequence? | Clusters + STARS event timing/spatial patterns |
| 03 | `draft/03-mechanisms.qmd` (new) | Which geographic, morphometric, and local climatic conditions are associated with divergent pathways; which regions show teleconnection sensitivity? | Spatially robust attribution + regional sensitivity |

Do **not** resurrect `draft/03-teleconnection.qmd.bak` wholesale. It belongs to an obsolete K=8 / prior-attribution structure and should be inspected only for reusable visual ideas.

------------------------------------------------------------------------

## 2. Work package A — unify Chapter 01 around STL kinematics

### Objective

Make Chapter 01 establish the vocabulary and global descriptive evidence before any clustering or causal language.

### Required edits

1.  Rename the section currently titled `Long-term warming && acceleration` to `Global warming kinematics`.
2.  Replace core uses of `raw_annual_mean_temp_sen_slope_40yr` labelled “warming speed” with `stl_annual_trend_sen_slope_40yr`.
3.  Keep raw annual-temperature slope only as a clearly labelled robustness comparison or move it to an appendix/supplement.
4.  Add a compact conceptual figure before statistical summaries:

``` txt
Panel A: τ(t), annual STL trend
Panel B: v(t) = Δτ(t), warming speed
Panel C: three idealized examples: constant speed, accelerating warming, decelerating warming
```

The figure must explain why acceleration is a trend of `v(t)`, not a second estimate of total warming. 5. Simplify the current raw/STL dual summary table. The chapter needs one canonical warming-speed summary, one acceleration summary, and perhaps a small robustness note. 6. Retain the spatial hex maps, but label panels consistently as `STL-trend warming speed` and `acceleration`. 7. Retain the continent table only as descriptive aggregation. Do not present it as area-weighted climate inference.

### Suggested figure order

``` txt
fig-lake-density-map
fig-kinematics-definition                 [new]
tbl-stl-speed-acceleration-summary         [refactor existing tables]
fig-warming-acceleration-scatterplot-matrix [simplify labels to STL speed]
fig-spatial-warming-acceleration-hex
```

### Acceptance criteria

- No main-text figure mixes raw annual slope as “speed” with STL-difference acceleration.
- Every acceleration statement explicitly says it describes change in low-frequency warming speed.
- All data joins / reusable summaries live in `shared/R/descriptive-helpers.R`; figure chunks contain composition and styling only.
- Render with `quarto render explorations/warming-acceleration/draft/01-global-kinematics.qmd --to html`.

------------------------------------------------------------------------

## 3. Work package B — create canonical Step 12: warming-speed regimes

### Objective

Create the missing time layer: persistent transitions in each lake’s warming speed.

### New producer

``` txt
data-process/steps/12-warming-speed-regimes/
  run.jl
  README.md
  output/<parameter-signature>/
```

This is parameter-sensitive and must follow `data-process/AGENTS.md`: `--force`, `--test-n-lakes`, `METADATA.md`, `SUMMARY.md`, and QC CSV.

### Inputs

``` txt
steps/05-annual-stl-trend/output/period12_robustfalse_ni5_no0_nt99/
  annual_stl_trend.csv
steps/00-lake-metadata/output/lake_metadata.csv  # only if continent is needed in summaries
```

Do not input clusters at this stage. Step 12 should produce general lake-level events; cluster joins belong in the site helper or a later thin join step.

### Parameters

``` txt
--parameter-signature period12_robustfalse_ni5_no0_nt99
--cutoff-length 7       # canonical
--probability 0.05      # canonical
```

Required sensitivity runs:

``` txt
L = 5, 7, 10 at p = 0.05
```

Use a parameter directory such as:

``` txt
output/period12_robustfalse_ni5_no0_nt99_l7_p005/
```

### Algorithm

1.  Read annual STL trend `τ(t)` for 1981–2020.
2.  Derive annual warming speed `v(t) = τ(t) − τ(t−1)` for 1982–2020.
3.  Run Rodionov STARS on `v(t)` to detect persistent shifts in its mean.
4.  For every accepted shift, compute:

``` txt
shift_year
pre_regime_start / end / length
post_regime_start / end / length
pre_speed_mean_C_per_yr
post_speed_mean_C_per_yr
delta_speed_C_per_yr = post − pre
direction = speed_up / speed_down
pre_speed_sign = negative / near_zero / positive
post_speed_sign = negative / near_zero / positive
RSI or equivalent standardized shift magnitude
```

5.  Derive one lake-level pathway label from the ordered event sequence. Do not force a rich taxonomy before inspecting actual event counts. Start with:

``` txt
no_persistent_shift
single_speed_up
single_speed_down
multiple_shifts
```

Then add crossing labels only if both pre/post signs are robustly classified.

6.  Emit a shift calendar by event year, direction, and signed count.

### Required outputs

``` txt
lake_annual_warming_speed.csv                # lake_id,lat,lon,1982,...,2020
lake_speed_regime_events.csv                 # one row per event
lake_speed_regimes.csv                       # one row per lake × regime
lake_speed_regime_pathways.csv               # one row per lake
speed_regime_shift_calendar.csv              # global event-year summary
speed_regime_qc.csv
METADATA.md
SUMMARY.md
```

### Important edge handling

- Mark the terminal detection window explicitly. With `L=7`, the final approximately seven years cannot be assessed with equivalent confidence. Any time plot must shade or omit this terminal zone.
- Do not interpret STARS events as instantaneous physical discontinuities; they are detected starts of persistent mean-speed regimes.
- If the implementation supports autocorrelation adjustment, expose it as an explicit parameter and document the default. Do not silently prewhiten.
- Do not use old `analysis/r-data/regime_*` outputs as validation data.

### Validation

1.  Smoke test 100 lakes.
2.  Manually inspect 20 stratified lakes: no-shift, single-up, single-down, multiple, high-latitude frozen, tropical.
3.  Confirm `delta_speed = post − pre` and direction labels agree for every inspected event.
4.  Compare L=5/7/10 at global event-calendar and pathway-count level. The exact event count need not be invariant; the major temporal/region patterns should not be wholly parameter artifacts.

------------------------------------------------------------------------

## 4. Work package C — expand Chapter 02 into modes and transitions

### Rename / role

The canonical filename is `02-response-types.qmd`; the former regional and temporal-response-mode filenames are retired because the chapter now unifies temporal trajectory, spatial organisation, and warming-speed regimes as properties of response types.

``` txt
Response types
```

The present chapter is not yet genuinely “regional”; it is primarily a trajectory-mode chapter.

### Section 1: trajectory modes

Retain and refine existing content:

- canonical K=5 STL baseline-anomaly clustering;
- cluster map + metric violins;
- cluster summary table;
- two-dimensional density of canonical STL warming speed and acceleration.

Change helper data ingestion so `warming_speed` is `stl_annual_trend_sen_slope_40yr`, not raw annual slope.

### Section 2: persistent transitions in warming speed \[new\]

Read only Step 12 canonical output through a new `shared/R/speed-regime-helpers.R`.

Required figures:

1.  **Global shift calendar**
    - x: event year
    - y: number of speed-up minus speed-down shifts, or two signed bars
    - show global total and continent facets or carefully selected major regions
    - terminal non-detectable years shaded
2.  **Cluster × pathway composition**
    - stacked proportion plot or heatmap
    - paths: no persistent shift / speed-up / speed-down / multiple
    - supports or falsifies the interpretation of C1/C2 versus C4/C5
3.  **Cluster median speed curves**
    - median `v(t)` with IQR ribbon by cluster
    - use one panel/facet per cluster
    - no 92k-line spaghetti plot
    - optionally annotate group-level STARS events
4.  **Spatial transition map**
    - show modal pathway or proportion speed-up minus speed-down within 5° cells
    - only after pathway QC is stable

### Section 3: aggregate acceleration-regime changes \[optional, deferred\]

Use segmented regression only on aggregated speed curves:

``` txt
cluster median speed curve
cluster × continent median speed curve
```

Do not fit flexible multi-breakpoint segmented models per lake.

If implemented, report:

``` txt
breakpoint year
pre-break acceleration slope
post-break acceleration slope
slope change
uncertainty/bootstrap interval
```

This section is optional. It should be added only if Step 12 shows a small number of coherent aggregate speed transitions. STARS is the canonical lake-level method.

### Acceptance criteria

- Every figure distinguishes a shift in **speed mean** from a shift in **acceleration slope**.
- The chapter answers: what modes exist, where they occur, and when speed states changed.
- It does not claim drivers yet.
- Remove superseded HTML-commented code and stale legend experiments before final render.

------------------------------------------------------------------------

## 5. Work package D — add geographic context missing from Step 11

### Rationale

The stated research question includes coast–interior contrast, but current Step 11 has no distance-to-coast measure. Latitude and longitude are insufficient substitutes.

### New producer: Step 13 geographic context

``` txt
data-process/steps/13-geographic-context/
```

### Minimum outputs

``` txt
lake_id
lat
lon
distance_to_coast_km
coastal_class                    # predeclared bins, e.g. <50, 50–200, >200 km
```

Optional only if a defensible source exists:

``` txt
continentality proxy
basin outlet/coastal routing class
```

### Method requirements

- Use a documented coastline source and geodesic distance, not planar degree distance.
- Preserve lake coordinates from Step 00.
- State coastline resolution, land-mask assumptions, and treatment of islands.
- Do not compute it in a QMD.

### Validation

Manually check representative known lakes: Great Lakes, inland Siberian lake, coastal Scandinavian lake, island lake.

After validation, extend Step 11 to join this table. Do not edit the 308 MB attribution CSV manually; rerun Step 11 when this is a new predictor block.

------------------------------------------------------------------------

## 6. Work package E — mechanisms chapter and spatially robust attribution

### New chapter

Create:

``` txt
site/explorations/warming-acceleration/draft/03-mechanisms.qmd
site/shared/R/mechanism-helpers.R
```

This chapter reads `lake_warming_attribution_data.csv` and later geographic-context output. Helpers may do figure-scale joins and predeclared transformations; model fitting / large resampling must live in a dedicated analysis script, not in QMD chunks.

### Outcomes

Main continuous outcome:

``` txt
acceleration = stl_annual_trend_diff_sen_slope_1e3
```

Secondary continuous outcome:

``` txt
STL warming speed = stl_annual_trend_sen_slope_40yr
```

Supplementary categorical outcome:

``` txt
K=5 cluster membership
```

Do not use both raw annual slope and STL speed as co-equal primary outcomes.

### Predictor blocks

| Block | Variables | Role |
|----|----|----|
| Spatial background | spherical `lon/lat` smooth, abs latitude, elevation, continent, distance to coast | required baseline/confounding control |
| Morphometry | log area, lake depth, shape factor, shoreline development, residence time, watershed area, reservoir | lake response capacity |
| Local forcing | wind / pressure / precipitation annual and seasonal means/trends | regional climatic correlates |
| Teleconnection | index-to-anomaly sensitivity only | separate temporal pathway analysis; not cross-sectional predictor |

### Feature discipline

Do not put all ERA5 annual + four-season means + trends into one model. They are strongly collinear.

For each region, predeclare a small hypothesis set based on current screening:

``` txt
Europe:        DJF precipitation trend, DJF/JJA pressure trends, AO/NAO sensitivity follow-up
North America: annual/JJA precipitation trend, wind background
Asia:          depth, seasonal wind trend
South America: precipitation trend, ENSO sensitivity
Africa:         ENSO sensitivity, pressure background
```

Before model fitting:

1.  inspect pairwise correlation and VIF within each predictor block;
2.  retain one representative from highly redundant variables, or use a clearly documented block PCA;
3.  transform skewed morphometric variables as already provided by Step 00;
4.  record exact feature sets in the model output metadata.

### Model sequence

#### E1. Spatial baseline

Fit a GAM or equivalent spatial model:

``` r
acceleration ~
  s(lon, lat, bs = "sos") +
  s(abs_lat) +
  s(Elevation) +
  Continent
```

Purpose: establish how much geographic structure is predictable before lake-specific properties.

#### E2. Add morphometry

``` r
baseline +
  s(log_Lake_area) +
  s(era5_lake_total_depth_m) +
  s(era5_lake_shape_factor) +
  is_reservoir
```

Test region-specific depth effects where justified, e.g. `s(depth, by = Continent)` or separate continent models. Current screening suggests Europe/Asia differ from North America.

#### E3. Add local forcing

Fit regional models, not one indiscriminate global seasonal model. Compare against E2 by spatial-block CV.

Required reporting:

``` txt
out-of-fold R² / RMSE
ΔR² over previous block
residual Moran's I
partial-effect curves with uncertainty
```

#### E4. Cluster classification \[supplementary\]

Use multinomial logistic regression or a spatially blocked tree model to predict C1–C5. Report balanced accuracy and confusion matrix, not only overall accuracy because clusters are unbalanced.

### Spatial validation

Random split validation is forbidden as the primary metric.

Use predeclared spatial blocks, for example:

``` txt
10° × 10° grid cells assigned to 5 folds
or contiguous spatial folds with comparable lake counts
```

Report:

``` txt
fold definition
n lakes / n cells per fold
out-of-fold performance
residual spatial autocorrelation
```

The model analysis script should save tables and metadata in a documented non-QMD analysis location. If it becomes a durable producer, convert it into a proper `data-process/steps/<nn>/` producer rather than leaving opaque saved R objects.

### Candidate signals to test, not to assert

These are preliminary screening hypotheses from the current corrected data:

``` txt
Europe / Asia: deeper lakes tend toward lower acceleration.
North America: negative acceleration associates with increasing annual/JJA precipitation.
Europe: negative acceleration associates with increasing DJF precipitation and seasonal pressure structure.
```

They become results only if effects remain under spatial block CV and after spatial background control.

------------------------------------------------------------------------

## 7. Work package F — teleconnection as a temporal sensitivity pathway

### What exists

Step 10 computes annual-index to detrended LSWT-residual correlations for AMO, AO, NAO, Niño3.4, PDO and lags 0–2 years.

### What it may be used for

- maps of regional sensitivity;
- cluster/continent distributions of `r`;
- selecting theory-supported region/index/lag pairs;
- testing whether local forcing anomalies carry the same index signal.

### What it may not be used for

- predictor columns in E1–E4 cross-sectional acceleration models;
- global counts of nominal `p < 0.05` as evidence of a global teleconnection effect;
- causal claims from simple lake-index correlation.

### Regional hypotheses worth prioritizing

``` txt
Europe:        AO lag1 and NAO lag0, especially C2 versus C3
South America: Niño3.4 lag0 / lag1
Africa:        Niño3.4 lag1
```

### Required next producer: forcing–teleconnection associations

Create after Step 12 and before writing strong teleconnection prose. It should:

1.  derive annual detrended anomalies of wind, pressure, and corrected precipitation from Step 08 annual outputs;
2.  correlate them with the same indices/lags using the same valid-year logic as Step 10;
3.  output lake-level associations and regional summaries;
4.  allow a three-link descriptive test:

``` txt
index → local forcing anomaly
local forcing anomaly → LSWT anomaly
index → LSWT anomaly
```

Call this a pathway-consistency or mediation hypothesis, not formal causal mediation unless all temporal/confounding assumptions are explicitly modelled.

### Suggested Chapter 03 teleconnection figures

1.  Europe: AO lag1 sensitivity map + C2/C3 distributions.
2.  South America/Africa: Niño3.4 regional sensitivity maps with correct lag labels.
3.  A compact pathway panel only after forcing–teleconnection association outputs exist.

------------------------------------------------------------------------

## 8. Figure and prose rules

- Keep figures in QMD; factor all reusable loading, joins, derived labels, and table accessors into chapter helpers.
- Use `save_figure()` only as a cached asset; every figure must render inline.
- Use `@fig-*` / `@tbl-*` references; do not write “the figure above”.
- Every map of a spatially aggregated statistic must state grid size/minimum lake count and that it is descriptive.
- Every cluster contour must state that `ndensity` normalizes each cluster independently and does not show relative cluster abundance.
- Never use significance stars for 92k lake-level correlations as the main evidence. Prefer effect size, regional consistency, and spatially blocked validation.
- Remove dead HTML-commented plotting code and generated `*_cache/`, `*_files/`, and `Rplots.pdf` artifacts from source control after confirming they are not required.

------------------------------------------------------------------------

## 9. Execution order and handoff checklist

### Phase 1 — lock definitions

Update Chapter 01 and regional helper to use STL warming speed consistently.

Add kinematics definition figure and prose.

Render 01.

### Phase 2 — time structure

Implement Step 12 with L=7 canonical run and L=5/10 sensitivity runs.

Inspect stratified lake examples and event QC.

Build `speed-regime-helpers.R`.

Expand/render 02.

### Phase 3 — spatial context and mechanisms

Implement/validate coast-distance context if the variable is retained.

Join it through Step 11 by rerunning producer, never manual editing.

Build spatial-block attribution analysis outside QMD.

Create/render `03-mechanisms.qmd` with only validated block comparisons.

### Phase 4 — teleconnection pathways

Create forcing–teleconnection association producer.

Restrict analyses to theory-supported regions/lags.

Add regional sensitivity figures only after local-forcing pathway consistency is checked.

### Required final validation after every changed QMD

``` bash
cd site
quarto render explorations/warming-acceleration/draft/01-global-kinematics.qmd --to html
quarto render explorations/warming-acceleration/draft/02-response-types.qmd --to html
quarto render explorations/warming-acceleration/draft/03-mechanisms.qmd --to html
```

Before handing back:

Read generated `SUMMARY.md`, `METADATA.md`, and `*_qc.csv` for every new/changed producer.

Confirm no raw/archived output was silently used.

State which findings are descriptive, which survive spatial CV, and which remain hypotheses.

Stage source files changed in the current session; do not stage generated `_output/` render artifacts.

Back to top
