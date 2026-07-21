# Analysis Contract

Canonical definitions and parameter choices for the lake-warming exploration.

This page is the canonical, human-readable contract for the active warming-acceleration analysis. It defines the quantities used in the draft chapters; producer-specific implementation and output provenance remain in `data-process/steps/*/README.md` and generated `METADATA.md` files.

> 本页是当前增暖探索的分析合同：统一指标定义、参数和适用边界。数据生产细节仍以各 Step 的 README、METADATA 和 SUMMARY 为准。

## Active analysis definitions

| Concept | Canonical definition | Role |
|----|----|----|
| Annual temperature | Calendar-year mean LSWT calculated directly from valid non-freezing daily GLAST reconstructed-product values. | Input for all primary warming and warming-speed metrics. |
| Long-term warming | Theil–Sen slope of the raw annual mean LSWT series, reported as °C per 40 years. | Primary descriptive warming metric. |
| Annual warming speed | Trailing 10-year Theil–Sen slope of raw annual mean LSWT, indexed to the endpoint year (e.g. 1981–1990 is indexed to 1990), in °C yr⁻¹. | Primary local warming-speed representation in the chapter; it describes temporal and spatial heterogeneity of reconstructed LSWT trajectories. |
| Warming-speed change | Sen slope of the raw trailing-10-year warming-speed sequence over its valid 1990–2020 support, in 10⁻³ °C yr⁻². | Defined operationally as a long-term change in local warming speed, not as a resolved instantaneous physical acceleration. The historical adjacent-difference metric is sensitivity-only. |
| Rolling temperature dynamics | Trailing 10-year Theil–Sen slopes of raw annual, DJF, MAM, JJA, SON, annual maximum 30-day, and annual minimum 30-day temperature, indexed to 1990–2020 endpoints. | Descriptive within-lake local-rate sequences for seasonal and extreme-temperature heterogeneity; not additive annual-trend contributions. A frozen all-ice / no-valid-nonfreezing period is finite `0.0 °C`, not missing. |
| Seasonal thermal asymmetry | Annual `JJA - DJF` warm–cold contrast, four-season range, and four-season standard deviation each receive an endpoint-aligned trailing-10-year Theil–Sen rate. | Positive contrast/range change means warm-season temperature changes faster relative to cold-season temperature; negative change means observed seasonal thermal states converge. These are descriptive relative-asymmetry metrics, not seasonal contribution fractions; frozen-state interpretation remains separate from seasonal ice days. |
| Rolling ice-duration state | Trailing 10-year arithmetic mean of annual ice days, indexed to the same 1990–2020 endpoints. | Descriptive ice-state background for comparison with local temperature rates; not a warming-speed measure or glacier proxy. |
| Seasonal ice dynamics | DJF, MAM, JJA, and SON ice-day sums constructed from monthly ice-day counts. Step 14 retains both trailing-10-year seasonal ice means and ice-loss rates, defined as the negative trailing-10-year Sen slope of seasonal ice days (positive = fewer ice days yr⁻¹). | Descriptive seasonal ice state/change context. Alignment with annual temperature rate is not causal attribution. |
| Sign-conditioned alignment | Overall Spearman alignment is supplemented by alignments evaluated only at positive or only at negative annual local-rate endpoints; at least eight finite endpoint pairs are required. | Separates warming-state and cooling-state co-variation. It does not yield additive seasonal contributions, independent-observation inference, or a causal driver ranking. |
| PCA input | Annual mean of the STL trend with period=12, robust=false, ni=5, no=0, and nt=99; each lake is centred on its 1981–1990 mean, then trajectories are averaged within occupied equal-area spherical cells before PCA. | Low-frequency trajectory representation only; not a substitute for the primary warming metrics. A centred 7-, 9-, and 11-year raw-annual moving-average branch is retained as a sensitivity test, not an alternative active input: it changes secondary spatial scores and does not retain the external JJA NAO/AO PC2–PC3 association. |
| PCA interpretation set | PC1–PC5. | PC1 is the robust global low-frequency mode. PC2–PC5 are recurring secondary descriptive modes whose rank and separation remain sensitivity-dependent; the 95% variance threshold is a diagnostic, not a retention rule. |
| PCA role | Defines continuous low-frequency trajectory-score geometry for a typical represented spatial cell. Lake scores are projections onto fixed cell-PCA loadings, not lake-level refits. | PCA components are covariance modes, not intrinsic lake categories or physical mechanisms. |
| PCA external interpretation | Fixed PCA score geometry is compared with predeclared cell-aggregated predictor families: geography/lake morphology, then available ERA5-Land wind and precipitation summaries. PC1 is a scalar response; PC2–PC3 is evaluated as a joint two-dimensional response so component rank exchange does not determine the estimand. Raw long-term warming and raw warming-speed change are parallel outcomes. | Spatial-block held-out prediction measures association only. A predictor family requires positive held-out gain at all tested block scales and support in a parallel raw outcome before entering the manuscript interpretation. Current panel lacks air temperature, radiation, humidity, evaporation, runoff, and independent forcing data; surface pressure is not a heat-budget driver. |
| Teleconnection sensitivity screen | Lake-level Pearson correlations between detrended raw annual LSWT anomalies and predeclared annual teleconnection indices are Fisher-z transformed, then aggregated to PCA equal-area cells. The screen uses Niño 3.4, PDO, NAO, and AO at index leads 0 and 1 year; NAO/AO form one correlated family. It evaluates whether PC1 or the joint PC2–PC3 spatial score subspace adds held-out prediction beyond geography/lake morphology. | A spatial co-location diagnostic only. It does not correlate PCA loading time series with indices, use lake-level nominal p values or best-index fields, identify a driver, or attribute PCA structure. AMO is excluded because the 40-year overlap cannot resolve its multidecadal behaviour. Any promoted result requires positive increment at all block scales, grid sensitivity, and LOCO checks. |
| Seasonal teleconnection discovery branch | Step 17 repeats the detrended-anomaly sensitivity calculation separately for matching DJF, MAM, JJA, and SON temperature/index seasons, at lags 0 and 1 years. Frozen `0.0 °C` seasonal states are excluded. It uses NAO, AO, PDO, and Niño 3.4; AMO remains excluded. This branch is a discovery screen designed to recover seasonal phase and spatial sign information lost by annual means. | A screen-selected result remains exploratory until it has positive PC2–PC3 increment across target-grid blocks, all three equal-area grids, and LOCO refits; NAO requires AO-family replication. It may describe where and when sensitivity fields differ, but cannot identify a circulation pathway or establish that a teleconnection causes a low-frequency PCA trajectory. |
| Seasonal lag-surface discovery branch | Step 18 computes a descriptive 72 × 21 equal-area **cell-mean residual** lag surface. Seasonal LSWT uses lag 0–12 quarters: lag 0 is matching season, lag 1 is preceding season, lag 4 is matching season in prior year, and lag 12 is three years earlier. Annual LSWT is paired with each predictor season at lags 0–3 years. | It describes seasonal and regional lag heterogeneity. It does not select a best global/cell lag, replace Step 17’s lake-level Fisher-z field, or support causal/pathway claims. Candidate lags chosen after inspection require a new lake-level grid, LOCO, and LODO validation pass. |
| Selected seasonal-lag confirmation branch | Step 19 fixes a small set of candidates after Step 18 inspection, then recalculates lake-level detrended LSWT/index correlations and four leave-one-decade-out fields. It intentionally does not use the global median absolute correlation to rank candidates: a field may have modest typical local correlation yet align strongly with PCA score geometry. | A candidate is described by its response season, index season, and exact quarter/year lag. Its Fisher-z cell field is tested against geography/lake morphology, PC1, PC2, PC3, and their combinations using spatial hold-out prediction. Three grid resolutions, leave-one-continent-out PCA refits, and leave-one-decade-out correlations distinguish broad stability from continent- or decade-sensitive observations. |
| Clustering status | K-means in projected PC1–PC5 score space is retained only as a documented exploratory sensitivity branch. | It is not part of the active Chapter 2 evidence or a claim that lakes belong to intrinsic discrete response types. |

> 原始年均温度负责描述增暖、年增暖速度与增温速度变化；STL nt=99 只在 PCA 前提取低频轨迹。PCA 在等面积格网轨迹上拟合，湖泊仅投影到固定轴；正文解释前 5 个主成分，不以累计 95% 方差作为保留阈值。

> PCA 定义典型空间格网的连续轨迹空间。clustering 仅保留为已记录的探索性敏感性分支，不进入 Ch2 主证据，也不把 cluster 当作自然离散类别。

## Analysis layers

The project uses two complementary representations rather than a single series for every question.

> 项目使用两个互补层，而非让所有问题强行共用一条序列。

| Layer | Representation | Scientific role |
|----|----|----|
| Reconstructed-temperature layer | Raw daily GLAST LSWT-product values aggregated to raw annual or seasonal means. | Long-term reconstructed-LSWT change and rolling seasonal/extreme-temperature/ice dynamics. |
| Background-trajectory layer | Monthly STL trend with `nt=99`, then annualised. | Smoothed low-frequency trajectory and its evolving background warming speed. |

> 原始层回答实际观测到的长期增温与季节/冰期问题；STL 背景层回答低频轨迹及其速度演化。

GLAST is not direct lake-temperature observation: it is a corrected/reconstructed product built from station-temperature information and FLAKE simulations driven by ERA5-Land. “Raw” here means un-smoothed values from that product, not unmodelled in-situ measurements. STL does not replace this reconstructed series. Its trend is parameter-dependent; its remainder is not automatically an extreme-event series or a teleconnection signal.

> GLAST 不是直接湖温观测，而是站点温度信息与 ERA5-Land 驱动 FLAKE 模拟经校正后的重建产品。raw 指该产品未经平滑的值，不是未经模型处理的站点实测；STL 不替代该重建序列。

## Explicit exclusions

STARS / ST_AIS persistent-regime detection is not part of the active analysis workflow. Historical Step 12 outputs and any helper code written for them are not inputs to the current chapters. Do not revive the method by accident through a default helper or an undocumented parameter branch.

> STARS / ST_AIS 当前不属于分析流程。历史 Step 12 输出与对应 helper 不得作为正文输入，也不应因默认路径而被意外重新启用。

## Provenance and change rule

Every chapter must name the producer branch it reads. A change to any definition above requires the same change in: this contract, the relevant `data-process` producer documentation, `AGENTS.md`, and the affected chapter prose/captions. If only a sensitivity analysis uses a different branch, label it as such rather than changing the canonical wording.

> 每章应明确读取的 producer branch。改动本页定义时，要同步更新 Step 文档、AGENTS 和相关正文/图注；敏感性分支必须明确标记，不能替换 canonical 叙述。

## Frozen manuscript decision

For the current first-author descriptive manuscript, do not introduce a new primary time-series algorithm, a new global partitioning method, STARS, a causal attribution model, or a teleconnection-centred narrative. New analyses are admissible only when they directly implement the definitions above, test their stated sensitivity branches, or complete the modular cooling/ice and constrained association work already specified.

> 当前第一作者描述性论文冻结主方法：不再新增主时间序列算法、全球分区方法、STARS、因果归因模型或遥相关主叙事。后续分析只能实现本契约、完成列明敏感性，或完成既定冰模块与受限关联模块。

## Related workflow

For the focused R workflow used to validate one figure’s rendering-time data preparation before a chapter render, see [Debugging Figure Helpers](../docs/helper-debugging.llms.md).

Back to top
