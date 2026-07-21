# Global Kinematics

## Sample coverage

    <environment: R_GlobalEnv>

GLAST reconstructed LSWT product: 92245 lakes, 1981–2020. It is not direct in-situ observation: station-temperature information and ERA5-Land-driven FLAKE simulations are corrected to produce the dataset ([Tong et al. 2023](#ref-tong2023)). “Raw” below means un-smoothed GLAST product values.

> GLAST 是重建 LSWT 产品，不是直接站点实测；它由站点温度信息和 ERA5-Land 驱动的 FLAKE 模拟校正得到。下文 raw 指未经平滑的 GLAST 产品值。

## Lake density map

![](01-global-kinematics_files/figure-html/fig-lake-density-map-1.png)

Figure 1: Lake density map with 1° × 1° grid cells.

## Long-term warming and local-speed heterogeneity

**Long-term warming** is the Theil–Sen slope of reconstructed annual mean lake surface water temperature (LSWT) over 1981–2020, presented as a 40-year-equivalent change in °C. The primary local **decadal warming rate** is the trailing 10-year Theil–Sen slope of raw annual LSWT, indexed to its endpoint year. Its long-term Sen trend is operationally termed **warming-speed change**: it indicates whether local decadal warming rates tend to become more or less positive, not a resolved instantaneous physical acceleration. This chapter remains in the reconstructed-temperature layer.

> 本章是重建温度层：年均 LSWT 的长期增温为主要指标；10 年滑动 Sen 为局部增温速度；其长期变化称增温速度变化，不等同于瞬时物理加速度。STL 对比保留在 prose/补充材料。

[Table 1 (a)](#tbl-warming-summary-raw) summarizes observed long-term warming and the change in trailing-10-year warming speed. 92.8% of lakes show positive long-term warming. 47.8% have a positive long-term change in local warming speed: over the 40-year record, their decadal warming rates tend to become more positive. This includes lakes whose warming accelerates and lakes that shift from decadal cooling toward warming; it is not a resolved instantaneous physical acceleration.

> [Table 1 (a)](#tbl-warming-summary-raw) 汇总 raw annual LSWT 的长期增温与局部增温速度变化。92.8% 湖泊长期增温为正；47.8% 在 40 年间的 10 年增温速度趋向更正，既可表示增温更快，也可表示从局部降温转向增温。

The long-term change in local 10-year warming speed is 0.242 ± 3.608 ×10⁻³ °C yr⁻². This operational statistic summarizes whether local background warming rates tend to become more or less positive; it is not a resolved instantaneous physical acceleration.

> 此量是 10 年局部 Sen 速度序列的长期趋势；它用于描述轨迹方向，不用于判定瞬时物理加速或减速。

|                    |                  |
|:-------------------|:-----------------|
| Warming count      | 85,569 (92.8%)   |
| Mean (°C/40yr)     | 0.881 ± 0.766    |
| Quartile (°C/40yr) | 0.37, 0.73, 1.23 |

\(a\) Raw annual long-term warming

|                             |                   |
|:----------------------------|:------------------|
| Positive speed-change count | 44,107 (47.8%)    |
| Mean (10⁻³ °C/yr²)          | 0.242 ± 3.608     |
| Quartile (10⁻³ °C/yr²)      | -1.89, 0.00, 1.86 |

\(b\) Warming-speed change

Table 1: Summary of long-term warming and local-speed change.

Values close to zero should not be interpreted as categorical “acceleration” or “deceleration”. The continuous relationships in [Figure 2](#fig-warming-speed-change-scatterplot-matrix) are therefore the primary summary.

In the upper triangle of [Figure 2](#fig-warming-speed-change-scatterplot-matrix), \\r\\ is Pearson correlation, \\\rho\\ is Spearman rank correlation, and \\R\[L\]\\ is the signed square root of the LOESS pseudo-\\R^2\\ on the displayed reproducible sample. The first two summarize linear and rank association; \\R\[L\]\\ is only a descriptive measure of visible nonlinear fit, not an independent inferential statistic.

> [Figure 2](#fig-warming-speed-change-scatterplot-matrix) 上三角中，\\r\\ 为 Pearson 相关，\\\rho\\ 为 Spearman 秩相关，\\R\[L\]\\ 为显示样本上 LOESS 伪 \\R^2\\ 的带符号平方根。前两者描述线性/秩关联；\\R\[L\]\\ 只描述可见的非线性拟合，不是独立推断统计量。

![](01-global-kinematics_files/figure-html/fig-warming-speed-change-scatterplot-matrix-1.png)

Figure 2: Pairwise relationships among mean temperature, long-term warming, and long-term change in local trailing-10-year warming speed.

Widespread long-term warming does not imply a common temporal pathway: lakes with similar 40-year-equivalent trend change can have increasing, decreasing, or near-stable local 10-year warming speeds.

![](01-global-kinematics_files/figure-html/fig-global-local-speed-1.png)

Figure 3: Lake-equal and equal-area global reconstructed annual LSWT (top), and corresponding 10-year Sen-rate summaries (bottom). Lake-equal ribbons show interquartile ranges.

The lake-equal median and the equal-area mean are intentionally not expected to have the same temperature level: lake sampling is concentrated in cold, lake-dense high-latitude regions, whereas the equal-area summary gives each occupied spatial cell one vote. They are shown together as complementary aggregations, not as interchangeable global temperatures.

> 湖泊等权中位数与等面积均值的温度水平本就不应相同：样本密集在高纬寒冷湖区，而等面积均值让每个被占据格网各占一票。两者互补，不是可互换的单一“全球温度”。

The changing median and persistent interquartile spread in [Figure 3](#fig-global-local-speed) show temporal and spatial heterogeneity simultaneously: local warming speeds evolve through time, while lakes at the same endpoint year occupy substantially different warming and cooling regimes.

> [Figure 3](#fig-global-local-speed) 的中位数变化与持续的四分位距同时显示时间与空间异质性：局部增温速度会随时间演化，同一阶段不同湖泊可处在增温或降温状态。

## Spatial heterogeneity of local warming speed

The 1° cells in [Figure 4](#fig-spatial-warming-speed-change-hex) summarize lake-level estimates before the endpoint maps examine selected decades. The lower panel maps the long-term change in local trailing-10-year warming rate, not instantaneous acceleration.

> [Figure 4](#fig-spatial-warming-speed-change-hex) 先以 1°格网汇总全球湖泊指标；随后端点图再深入展示特定时期。下图为局部 10 年增温速度的长期变化，不是瞬时物理加速度。

![](01-global-kinematics_files/figure-html/fig-spatial-warming-speed-change-hex-1.png)

Figure 4: Spatial pattern of lake warming and long-term local warming-speed change. Each 1° × 1° cell averages lake-level metrics.

[Figure 5](#fig-local-speed-endpoint-maps) makes this second pattern explicit. Each panel uses the same local 10-year speed definition, so contrast across panels is temporal change and contrast within a panel is spatial heterogeneity.

> [Figure 5](#fig-local-speed-endpoint-maps) 用相同 10 年 Sen 速度定义比较四个端点年：面板间是时间变化，面板内是同阶段的空间异质性。

![](01-global-kinematics_files/figure-html/fig-local-speed-endpoint-maps-1.png)

Figure 5: Spatial distribution of trailing-10-year local warming rate at 1990, 2000, 2010, and 2020 endpoints. Each 1° × 1° cell averages at least three lakes.

These global metrics reduce each lake’s annual warming-speed series to a long-term slope. They show whether warming speed tends to become more or less positive, but not how the temporal pattern of warming differs among lakes or what factors drive those differences. [Warming pattern decomposition](../../../explorations/warming-acceleration/draft/03-warming-pattern-decomposition.llms.md) therefore applies PCA to the full annual temperature trajectory to identify dominant modes of variation and their spatial organisation.

> 全局指标将年增温速率压缩为长期斜率，但不能揭示增温时间模式的差异。[增温模式分解](../../../explorations/warming-acceleration/draft/03-warming-pattern-decomposition.llms.md)用 PCA 识别主要变异模态及其空间组织。

Back to top

## References

Tong, Yan, Lian Feng, Xinchi Wang, Xuehui Pi, Wang Xu, and R. Iestyn Woolway. 2023. “Global Lakes Are Warming Slower Than Surface Air Temperature Due to Accelerated Evaporation.” *Nature Water* 1 (11): 929–40. <https://doi.org/10.1038/s44221-023-00148-8>.
