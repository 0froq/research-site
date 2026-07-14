# Seasonal and Ice Diagnostics for Cooling Trajectories

## Question and evidentiary boundary

Some lakes in mid- to high-latitude North America and mid-latitude Eurasia may show late-period cooling or a reduction in warming speed. One possible explanation is increased cold-season or warm-season inflow from glacier melt. This is a useful hypothesis, but the present lake-temperature and ice-duration outputs cannot establish it: they do not identify glacier-connected catchments or measure inflow temperature and discharge.

> 北美中高纬度和欧亚中纬度部分湖泊可能在后期降温或减速。冰川融水冷入流是可检验假说，但当前数据没有 glacier-catchment 连通性、入流温度或流量，不能直接归因。

The immediate objective is therefore diagnostic: determine whether cooling or deceleration has the seasonal signature expected from a warm-season cold-inflow mechanism, and distinguish that signature from changes in lake ice duration or broader atmospheric forcing.

> 近期目标是诊断而非归因：检验其季节性指纹是否符合暖季冷入流，并与冰期变化和大气强迫的替代解释区分。

## Predeclared diagnostic sequence

### 1. Define response cohorts before inspecting seasonal patterns

Use raw annual mean LSWT, the canonical primary series. Report both a full-period and a late-period definition:

| Cohort | Definition | Purpose |
|----|----|----|
| Full-period cooling | Raw annual Theil–Sen slope over 1981–2020 is below zero. | Identifies lakes whose long-run annual LSWT decreases. |
| Full-period deceleration | Sen slope of raw annual warming speed over 1982–2020 is below zero. | Identifies lakes whose annual warming speed becomes less positive or more negative. |
| Late-period cooling | Theil–Sen slope of raw annual LSWT over a predeclared late window, initially 2001–2020, is below zero. | Separates a late reversal from an overall cooling record. |
| Late-period slowdown | Late-window slope is lower than the corresponding early-window slope, initially 1981–2000. | Tests a change in trajectory without treating a detected breakpoint as a physical event. |

> 先定义湖泊 cohort，再看季节结果。全期与末段定义应并列报告；不要先看到 JJA 信号后再倒推筛选条件。

The current producer already supports full-period annual and seasonal slopes. Late-period slopes require an explicit parameterised producer extension or a documented analysis step; do not calculate them as an undocumented QMD-side convenience.

> 当前 producer 已有全期年/季节趋势。末段趋势需要显式、可追溯的 producer 参数或分析步骤，不能在 qmd 中临时计算。

### 2. Test the warm-season signature

Glacier meltwater is expected to be most relevant during the warm season, when melt and discharge are largest. The primary seasonal diagnostic is therefore the JJA raw LSWT slope. For every cohort, compare JJA with DJF, MAM, and SON slopes rather than examining JJA alone.

> 冰川融水的首要季节诊断是 JJA，但必须与 DJF、MAM、SON 并列比较，不能只挑选夏季结果。

Support for the hypothesis would require a coherent pattern: cooling/decelerating lakes should have disproportionately negative or weakened JJA trends relative to comparable non-cooling lakes, with an interpretable geographical concentration. A negative JJA slope alone is not sufficient.

> 支持性证据应是连贯组合：冷却/减速 cohort 的 JJA 趋势相对对照组更负或更弱，并有可解释的空间集中；单独的 JJA 负趋势不够。

### 3. Separate ice-state and liquid-water interpretations

Annual LSWT includes the 0 °C all-ice state. Compare annual ice-day trends and, where necessary, seasonal temperature trends within strata of baseline ice duration. The key question is whether annual cooling/deceleration is primarily associated with changing ice exposure or remains visible in the warm-season liquid-water signal.

> 年均 LSWT 混合冰态与液态水温。应按基线冰期分层，比较年冰日趋势和季节温度趋势，判断信号是否仍存在于暖季液态水温中。

Useful contrasts include:

- seasonally frozen versus low-ice lakes;
- decreasing versus stable/increasing annual ice duration;
- similar latitude/elevation bands, to avoid treating the global thermal gradient as a mechanism.

### 4. Require catchment evidence before invoking glacier meltwater

An eventual glacial-inflow claim requires at least one external glacier or catchment data source and a lake-to-upstream-catchment linkage. Geographic proximity to a glacier, latitude, elevation, or continent is not evidence of hydrological connection.

> 若要声称冰川融水机制，至少需要外部冰川/流域数据和湖泊—上游流域连通关系。仅凭距冰川近、纬度、海拔或大洲都不是水文连通证据。

The minimum evidence chain is:

``` text
glacier-connected catchment
  → warm-season melt/discharge or cold-inflow indicator
  → disproportionate JJA cooling or slowdown
  → robustness after ice-duration and atmospheric-forcing contrasts
```

## Alternative explanations to retain

The same seasonal pattern could arise from cloud/radiation changes, precipitation and non-glacial runoff, wind-driven mixing, evaporative cooling, local land-cover change, satellite retrieval issues, or sampling/ice-state artefacts. The diagnostic should report these as alternatives, not as residual footnotes.

> 相同季节信号也可能来自辐射、降水与非冰川径流、风混合、蒸发冷却、土地覆盖、遥感反演或冰态处理。它们应是并列替代解释，而非附注。

## Planned deliverables

1.  A cohort table with full-period and late-period definitions.
2.  A seasonal slope comparison for annual/DJF/MAM/JJA/SON, stratified by baseline ice duration.
3.  A map of the diagnostic cohorts, explicitly descriptive.
4.  A decision on whether the observed pattern justifies acquiring glacier-catchment data.

> 交付物依次为：cohort 表、季节趋势对比、描述性空间图，以及是否值得引入 glacier-catchment 数据的决策。

Back to top
