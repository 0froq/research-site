# Global Kinematics

## Sample coverage

    <environment: R_GlobalEnv>

    <environment: R_GlobalEnv>

GLAST: 92245 lakes, 1981–2020.

## Lake density map

![](01-global-kinematics_files/figure-html/fig-lake-density-map-1.png)

Figure 1: Lake density map with 1° × 1° grid cells.

## Long-term warming and local-speed heterogeneity

**Long-term warming** is the Theil–Sen slope of observed annual mean lake surface water temperature (LSWT) over 1982–2020, presented as a 40-year-equivalent change in °C. The primary local **warming speed** is the trailing 10-year Theil–Sen slope of raw annual LSWT, indexed to its endpoint year. Its long-term Sen trend is operationally termed **warming-speed change**: it indicates whether local 10-year warming rates tend to become more or less positive, not a resolved instantaneous physical acceleration. This chapter remains in the observed-temperature layer.

> 本章是观测温度层：年均 LSWT 的长期增温为主要指标；10 年滑动 Sen 为局部增温速度；其长期变化称增温速度变化，不等同于瞬时物理加速度。STL 对比保留在 prose/补充材料。

[Table 1 (a)](#tbl-warming-summary-raw) summarizes observed long-term warming and the change in trailing-10-year warming speed. 92.8% of lakes show positive long-term warming. 47.8% have a positive long-term change in local warming speed; this is an operational trajectory descriptor, not a physical instantaneous acceleration.

> [Table 1 (a)](#tbl-warming-summary-raw) summarizes the warming metrics computed from raw annual mean LSWT% 湖泊呈正增温速率，但仅47.8% 呈正加速度，增温方向与速度变化基本解耦。

The long-term change in local 10-year warming speed is 0.242 ± 3.608 ×10⁻³ °C yr⁻². This operational statistic summarizes whether local background warming rates tend to become more or less positive; it is not a resolved instantaneous physical acceleration.

> 当前加速度离散度极大；年际差分保留大量短时变率。因此现阶段仅作描述性诊断，不能据此判定单湖加速或减速；定义与稳健性待后续重审。

|                    |                  |
|:-------------------|:-----------------|
| Warming count      | 85,569 (92.8%)   |
| Mean (°C/40yr)     | 0.881 ± 0.766    |
| Quartile (°C/40yr) | 0.37, 0.73, 1.23 |

\(a\) Raw annual warming speed

|                        |                   |
|:-----------------------|:------------------|
| Accelerating count     | 44,107 (47.8%)    |
| Mean (10⁻³ °C/yr²)     | 0.242 ± 3.608     |
| Quartile (10⁻³ °C/yr²) | -1.89, 0.00, 1.86 |

\(b\) Warming-speed change

Table 1: Summary of warming status.

A sign-only classification is only descriptive: values close to zero can switch category without a meaningful change in magnitude. The continuous relationships in [Figure 2](#fig-warming-acceleration-scatterplot-matrix) are therefore the primary summary.

![](01-global-kinematics_files/figure-html/fig-warming-acceleration-scatterplot-matrix-1.png)

Figure 2: Pairwise relationships among mean temperature, long-term warming, and long-term change in local trailing-10-year warming speed.

Widespread long-term warming does not imply a common temporal pathway: lakes with similar 40-year-equivalent trend change can have increasing, decreasing, or near-stable local 10-year warming speeds.

![](01-global-kinematics_files/figure-html/fig-global-local-speed-1.png)

Figure 3: Global distribution of local warming speeds. Each annual value is the median trailing-10-year Theil–Sen slope across lakes; ribbon shows the interquartile range.

The changing median and persistent interquartile spread in [Figure 3](#fig-global-local-speed) show temporal and spatial heterogeneity simultaneously: local warming speeds evolve through time, while lakes at the same endpoint year occupy substantially different warming and cooling regimes.

> [Figure 3](#fig-global-local-speed) 的中位数变化与持续的四分位距同时显示时间与空间异质性：局部增温速度会随时间演化，同一阶段不同湖泊可处在增温或降温状态。

## Spatial heterogeneity of local warming speed

The hexagons in [Figure 4](#fig-spatial-warming-acceleration-hex) summarize lake-level estimates within 5° cells containing at least five lakes. The lower panel maps the long-term change in local trailing-10-year warming speed, not instantaneous acceleration.

> [Figure 4](#fig-spatial-warming-acceleration-hex) 用六边形汇总 5° 网格内的湖泊指标（≥5 个湖）。上下面板分别展示长期增温与局部增温速度变化的空间格局，两者不必一致。

![](01-global-kinematics_files/figure-html/fig-spatial-warming-acceleration-hex-1.png)

Figure 4: Spatial pattern of lake warming and long-term local warming-speed change. Hexagons aggregate lake-level metrics in 5° geographic bins containing at least five lakes.

| Continent | Warming | Accelerating | Warming + accelerating | Mean warming | Mean acceleration |
|----|----|----|----|----|----|
| **NA** | 94.9% | **39.5%** | **37.6%** | 0.77 °C / 40 yr | **-0.57 ×10⁻³ °C / yr²** |
| EU | 90.1% | 55.3% | 47.0% | 1.13 °C / 40 yr | 1.34 ×10⁻³ °C / yr² |
| AS | 90.2% | 50.8% | 44.8% | 0.49 °C / 40 yr | 0.02 ×10⁻³ °C / yr² |
| SA | 89.2% | 90.9% | 82.3% | 0.38 °C / 40 yr | 1.04 ×10⁻³ °C / yr² |
| AF | 99.9% | 80.2% | 80.1% | 0.50 °C / 40 yr | 0.64 ×10⁻³ °C / yr² |
| OC | 94.0% | 82.8% | 77.0% | 0.57 °C / 40 yr | 1.36 ×10⁻³ °C / yr² |

Table 2: Continent-level spatial summary

[Table 2](#tbl-spatial-continent-summary) is a descriptive aggregation of local-speed change. Continental values are not area-weighted climate means and do not identify physical acceleration or deceleration.

> [Table 2](#tbl-spatial-continent-summary) 强化了大洲差异。欧洲高增温速率+正加速度，北美高增温比例但负均值加速度。大洲统计值为描述性汇总，非面积加权气候均值。

These global metrics reduce each lake’s annual warming-speed series to a long-term slope. They show whether warming speed tends to become more or less positive, but not how the temporal pattern of warming differs among lakes or what factors drive those differences. [Warming pattern decomposition](../../../explorations/warming-acceleration/draft/02-warming-patterns.llms.md) therefore applies PCA to the full annual temperature trajectory to identify dominant modes of variation and their spatial organisation.

> 全局指标将年增温速率压缩为长期斜率，但不能揭示增温时间模式的差异。[增温模式分解](../../../explorations/warming-acceleration/draft/02-warming-patterns.llms.md)用 PCA 识别主要变异模态及其空间组织。

## Optional ice module

Cooling trajectories are part of the observed heterogeneity. Their seasonal and ice-duration context is maintained as a separate, optional [seasonal and ice diagnostics module](../../../explorations/warming-acceleration/prose/seasonal-ice-diagnostics.llms.md), so it can be included or omitted from a future manuscript without changing this chapter’s kinematic core.

> 降温轨迹属于观测异质性。其季节与冰期背景独立维护为可选模块；未来论文可独立决定纳入与否，不改变本章运动学核心。

Back to top
