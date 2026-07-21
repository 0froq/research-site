# Methods

## Data and scope

We analyse the 1981–2020 historical GLAST reconstruction for 92,245 lakes. The product combines satellite information with ERA5-Land-forced FLAKE model output and calibration; all temperature inferences concern reconstructed lake surface conditions ([Tong et al. 2023](#ref-tong2023)). Frozen `0 °C` states are retained as physical ice states rather than treated as ordinary liquid-water temperatures.

> 分析 92,245 个湖泊 1981–2020 年 GLAST 历史重建。产品整合卫星信息、ERA5-Land 强迫的 FLAKE 输出和校正；所有温度推断都针对重建湖表状态。冻结 `0 °C` 作为物理冰状态保留，不视作普通液态水温。

## Primary trajectory metrics

Long-term warming is the Theil–Sen slope of raw annual-mean LSWT over the full record, expressed as a 40-year-equivalent temperature change. Local warming rate is the trailing, endpoint-aligned 10-year Theil–Sen slope of raw annual LSWT. The Sen trend of the valid local-rate sequence is termed warming-speed change. It is an operational description of trajectory evolution, not resolved instantaneous physical acceleration.

> 长期增温为 raw 年均 LSWT 全期 Theil–Sen slope，并折算为 40 年温度变化。局地增温速度为端点对齐的 10 年滑动 Theil–Sen slope。有效局地速度序列的 Sen trend 称为增温速度变化；它描述轨迹演变，不是瞬时物理加速度。

## Seasonal and ice-state diagnostics

Endpoint-aligned 10-year Sen rates are also calculated for seasonal, extreme-temperature, and ice-day series. These diagnostics compare directional co-variation with annual local rates. They are not additive decompositions of annual warming and do not test glacier-meltwater mechanisms.

> 对季节、极端温度和冰日序列也计算端点对齐的 10 年 Sen rate。它们比较与年局地速度的方向共变，不可相加为年增温贡献，也不检验冰川融水机制。

## Spatially balanced trajectory decomposition

Monthly STL with `nt=99` is used only to produce the low-frequency representation for PCA. Annual STL trajectories are centred on their 1981–1990 mean, averaged in occupied equal-area cells, and decomposed by PCA. Each lake then receives projected scores on the fixed cell-PCA axes. PCA is not refitted at lake level.

> `nt=99` 月尺度 STL 只用于得到 PCA 的低频表征。年 STL 轨迹按 1981–1990 均值中心化，在被占据等面积格网中汇总后 PCA；每湖再投影至固定格网 PCA 轴，不在湖泊层级重拟 PCA。

## Stability and external association

We assess PCA structure across grid resolutions and leave-one-continent-out (LOCO) refits. Spatial association fields are evaluated with spatial hold-outs, LOCO, and leave-one-decade-out checks. For the retained circulation result, raw JJA LSWT is linearly detrended for each lake after frozen states are excluded, then correlated with the predeclared prior-summer index. These checks assess reproducibility of association, not causal attribution.

> PCA 在不同格网和 LOCO 重拟合下检验。空间关联场以空间留出、LOCO 与 leave-one-decade-out 检查。保留的环流结果中，每湖 raw JJA LSWT 在排除冻结状态后线性去趋势，再与预先定义的上一年夏季指数相关。检验关联可重复性，不做因果归因。

Back to top

## References

Tong, Yan, Lian Feng, Xinchi Wang, Xuehui Pi, Wang Xu, and R. Iestyn Woolway. 2023. “Global Lakes Are Warming Slower Than Surface Air Temperature Due to Accelerated Evaporation.” *Nature Water* 1 (11): 929–40. <https://doi.org/10.1038/s44221-023-00148-8>.
