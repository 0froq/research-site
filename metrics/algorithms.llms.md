# Algorithms

## STL

Seasonal-Trend decomposition using LOESS (Cleveland et al. 1990). Decomposes a time series into seasonal, trend, and remainder components.

Key parameters:

- **Period**: seasonal cycle length (12 for monthly data)
- **nt**: width of the trend LOESS window — controls smoothness. Larger nt → smoother trend, less short-term detail. Sensitivity to nt should always be tested.
- **ni / no**: inner/outer iterations for robustness

Used in: [warming-acceleration](../explorations/index.llms.md#warming-acceleration).

For the active PCA branch, STL is not treated as an interchangeable moving average. It first estimates and removes monthly seasonality, then estimates a low-frequency trend. A 7-, 9-, and 11-year centred annual moving-average sensitivity branch produced internally smooth, LOCO-stable PCs, but did not retain the external JJA NAO/AO association pattern carried by the STL PC2–PC3 score subspace. Therefore the project retains STL `nt=99` for PCA only.

The teleconnection association itself remains calculated from linearly detrended, un-smoothed seasonal LSWT. Smoothed trajectories are never used to estimate a lag-0 or lag-1 teleconnection correlation.

## STARS (retired for this exploration)

Sequential T-test Analysis of Regime Shifts (Rodionov 2004). Detects abrupt, persistent shifts in the **mean** of a time series.

- Sequential: processes data in order, near-real-time capable
- Two parameters: cut-off length \\l\\ and significance level \\p\\
- Uses a t-test critical difference and a cumulative Regime Shift Index (RSI) to require persistence after a candidate shift
- A shift in a series mean is distinct from a breakpoint in that series’ slope

STARS is historical/retired in the warming-acceleration exploration and is not an active chapter input. The current manuscript uses sliding Theil–Sen local speed rather than persistent-regime detection.

Originally designed for PDO regime shifts. Applied to lake surface temperature by Woolway et al. (2017).

Alternatives: Bai-Perron (multiple breakpoints, regression-based), Pettitt (single shift, rank-based), CUSUM (cumulative sum). All are sensitive to algorithm choice and parameterisation; STARS is favoured for its simplicity and climatological track record.

Paper notes: [Rodionov (2004)](../notes/papers/rodionov2004.llms.md).

Used in: [warming-acceleration](../explorations/index.llms.md#warming-acceleration).

## K-means clustering

Partitions \\n\\ observations into \\K\\ groups by minimising within-cluster sum of squared distances. Requires pre-specification of \\K\\; sensitive to feature scaling.

Common workflow: z-score features → run K-means → order clusters by a meaningful axis (e.g. mean temperature).

In this project, projected PC1–PC5 clustering is retained only as an exploratory sensitivity branch. It is not active Chapter 2 evidence: PCA score geometry and score-pole composites are used instead.

## Spatially balanced PCA

PCA ordinarily gives every input row equal weight. For lake trajectories, this means a lake-dense region can dominate covariance merely because it contributes many nearby, similar lakes. Spatial balancing changes target population: it first centres each lake’s nt=99 STL trajectory on its 1981–1990 mean, averages trajectories within occupied equal-area spherical cells, and fits PCA to one trajectory per cell.

Active grid has 72 longitude bins and 21 bins equally spaced in \\\sin(\mathrm{latitude})\\ over 60°S–85°N. Equal spacing in \\\sin(\mathrm{latitude})\\, rather than degrees of latitude, makes cells equal in spherical surface area. It does **not** assert that each cell has equal ecological importance; it estimates covariance for a typical represented spatial cell rather than a typical sampled lake.

Let \\\bar{\mathbf{x}}\_c\\ be each occupied cell trajectory and \\\boldsymbol{\mu}\\ be mean trajectory across occupied cells. PCA is fitted to \\(\bar{\mathbf{x}}\_c-\boldsymbol{\mu})\\. Lake-level score is then

\\ s\_{ik} = (\mathbf{x}\_i-\boldsymbol{\mu})^\mathsf{T}\mathbf{v}\_k, \\

where \\\mathbf{x}\_i\\ is lake’s baseline-centred trajectory and \\\mathbf{v}\_k\\ is fixed cell-PCA loading \\k\\. This projects lakes onto spatial-balanced axes; it is not a second, lake-equal PCA.

### External interpretation of PCA scores

PCA is an unsupervised covariance decomposition. External interpretation keeps its loading vectors fixed and models cell scores against predeclared external predictor families. PC1 can be evaluated as a scalar response. When adjacent secondary PCs exchange rank under sensitivity tests, model their score vector jointly; total squared prediction error for an orthogonal score subspace does not depend on a relabelling or rotation inside that subspace.

For this exploration, predictors are aggregated to the same equal-area cells as PCA and tested by contiguous spatial-block hold-outs. Geography/lake morphology forms the baseline. Currently available ERA5-Land wind and precipitation summaries form a restricted second family. A held-out increment is an association, not attribution; it must be stable across block scales and agree with a parallel raw-temperature outcome before supporting interpretation.

### Teleconnection sensitivity screen

Teleconnection indices are not regressed against PCA loading time series here: the PCA representation is low-frequency, while annual indices and their interannual lake responses operate on a different time scale. Instead, each lake’s correlation between detrended annual LSWT anomalies and a predeclared index/lead combination is Fisher-z transformed and aggregated to PCA cells. The resulting spatial sensitivity field can be tested against fixed PC scores after geography/lake morphology is controlled by spatial block hold-outs.

This asks whether locations expressing different PCA score geometry also differ in their interannual teleconnection sensitivity. It does not establish that an index drives a PCA mode. Do not use nominal lake-level correlation p values, post-hoc best-index labels, or a 40-year AMO screen as evidence.

The predeclared screen is Niño 3.4, PDO, NAO, and AO, at lags 0 and 1 only; at least 30 valid paired years are required. Lake correlations are transformed as \\z=\operatorname{atanh}(r)\\ and aggregated within each cell with weight \\n-3\\. Geography/lake morphology is the baseline. PC1 and the joint PC2–PC3 score pair are additions, evaluated by contiguous spatial block held-out \\R^2\\. A finding is retained only when its positive PC increment repeats across three block partitions, three equal-area PCA grids, and leave-one-continent-out PCA refits. NAO and AO are a correlated family, so passing results cannot rank them as separate mechanisms. See [teleconnection-sensitivity screen](../explorations/warming-acceleration/prose/pca-teleconnection-screen.llms.md) for result-specific boundaries.

### Seasonal lagged association screen

Step 17 repeats this association construction for DJF, MAM, JJA, and SON, using matching-season three-month index means. For DJF year \\y\\, the index is December \\y-1\\ plus January–February \\y\\, matching the temperature producer. All-ice seasonal observations encoded as 0 °C are excluded before a per-lake linear seasonal detrend. The active discovery subset is JJA temperature in year \\t\\ against JJA NAO/AO in \\t-1\\; its cell response is called a **lagged seasonal association field**, not a causal sensitivity field.

Screen promotion requires positive PC2–PC3 spatial-block gain at three equal-area grids and every LOCO refit. Targeted leave-one-decade-out checks recompute lake trends and correlations after removing an entire decade; their 28-pair minimum is a deliberate consequence of lagged 30-year samples, not a replacement for the main 30-pair screen. See [seasonal teleconnection association](../explorations/warming-acceleration/prose/pca-seasonal-teleconnection.llms.md) for retained result, figures, and interpretation limits.

Available lake and watershed attributes can enter an explicit exclusion check, not a post-hoc causal model. The active expanded context is residence time, discharge, watershed area, volume, shoreline development, local slope, and reservoir fraction. It must use one shared context-complete cell set, compare the expanded baseline with PC additions under the same spatial blocks, and repeat its PC2–PC3 increment across grid, LOCO, and LODO checks. See [lake context exclusion](../explorations/warming-acceleration/prose/pca-seasonal-teleconnection-lake-context.llms.md).

## Theil–Sen slope

Non-parametric slope estimator: median of all pairwise slopes. Robust to outliers, no normality assumption. Widely used in climate trend analysis.

## Mann–Kendall test

Non-parametric trend test. Tests whether a monotonic trend exists. Often paired with Theil–Sen for trend magnitude. Sensitive to autocorrelation — pre-whitening may be needed.

Back to top
