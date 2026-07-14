# Algorithms

## STL

Seasonal-Trend decomposition using LOESS (Cleveland et al. 1990). Decomposes a time series into seasonal, trend, and remainder components.

Key parameters:

- **Period**: seasonal cycle length (12 for monthly data)
- **nt**: width of the trend LOESS window — controls smoothness. Larger nt → smoother trend, less short-term detail. Sensitivity to nt should always be tested.
- **ni / no**: inner/outer iterations for robustness

Used in: [warming-acceleration](../explorations/index.llms.md#warming-acceleration).

## STARS

Sequential T-test Analysis of Regime Shifts (Rodionov 2004). Detects abrupt, persistent shifts in the **mean** of a time series.

- Sequential: processes data in order, near-real-time capable
- Two parameters: cut-off length \\l\\ and significance level \\p\\
- Uses a t-test critical difference and a cumulative Regime Shift Index (RSI) to require persistence after a candidate shift
- A shift in a series mean is distinct from a breakpoint in that series’ slope

In the warming-acceleration exploration, STARS is applied to annual warming speed \\v(t)=\Delta\tau(t)\\, with \\L=7\\ and \\p=0.05\\. It therefore detects a persistent shift from one **mean warming-speed regime** to another. It does not detect an acceleration-slope breakpoint; segmented regression on \\v(t)\\ would answer that different question.

Originally designed for PDO regime shifts. Applied to lake surface temperature by Woolway et al. (2017).

Alternatives: Bai-Perron (multiple breakpoints, regression-based), Pettitt (single shift, rank-based), CUSUM (cumulative sum). All are sensitive to algorithm choice and parameterisation; STARS is favoured for its simplicity and climatological track record.

Paper notes: [Rodionov (2004)](../notes/papers/rodionov2004.llms.md).

Used in: [warming-acceleration](../explorations/index.llms.md#warming-acceleration).

## K-means clustering

Partitions \\n\\ observations into \\K\\ groups by minimising within-cluster sum of squared distances. Requires pre-specification of \\K\\; sensitive to feature scaling.

Common workflow: z-score features → run K-means → order clusters by a meaningful axis (e.g. mean temperature).

## Theil–Sen slope

Non-parametric slope estimator: median of all pairwise slopes. Robust to outliers, no normality assumption. Widely used in climate trend analysis.

## Mann–Kendall test

Non-parametric trend test. Tests whether a monotonic trend exists. Often paired with Theil–Sen for trend magnitude. Sensitive to autocorrelation — pre-whitening may be needed.

Back to top
