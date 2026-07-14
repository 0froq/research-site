# Acceleration Sensitivity of Raw LSWT Trajectories

The current adjacent-difference Sen metric has mean ± SD \\2.03 \pm 9.94\times10^{-3}\\ °C yr\\^{-2}\\ across 92,245 lakes. We compared it with a full-period quadratic acceleration and the difference between late (2001–2020) and early (1981–2000) annual Theil–Sen slopes.

> 当前年际差分 Sen 指标为 \\2.03 \pm 9.94\times10^{-3}\\ °C yr\\^{-2}\\。与全期二次项、早晚期 Sen 斜率差并列比较。

The rank correlation of the adjacent-difference metric with quadratic acceleration is 0.47 and with the early–late contrast is 0.43. In contrast, the quadratic and early–late indicators correlate at 0.90. Thus, the current difference-based measure is sensitive to short-timescale variation and should not be used alone to classify individual lakes as accelerating or decelerating.

> 年际差分与二次项/早晚期差的秩相关仅 0.47/0.43；后二者为 0.90。差分指标对短时变率敏感，不能单独给单湖贴“加速/减速”标签。

No current indicator is designated as the primary acceleration metric. The adjacent-difference map is historical/provisional only. The next decision is to select an estimand by explicit criteria: interpretable units, robustness to interannual noise, adequate endpoint support, agreement with visually inspectable trajectories, and stability under missingness and window sensitivity. The early–late trend contrast remains useful for cooling cohorts, but it is not a physical acceleration.

> 目前不指定主要加速度指标。差分图仅是历史/暂定结果。后续按可解释单位、抗年际噪声、端点支持、轨迹可视核验、缺失与窗口敏感性来选择 estimand。早晚期趋势差可用于降温 cohort，但不是物理加速度。

## Representation decision

Raw annual LSWT remains the observed-temperature layer: its full-period Theil–Sen slope is the primary long-term warming result, and its seasonal trends define cooling cohorts. Monthly STL trend (`nt=99`) is introduced as a separate background-trajectory layer, not as a replacement for raw observations.

> raw annual LSWT 仍是观测层：全期 Theil–Sen 是主要长期增温结果，季节趋势用于定义降温 cohort。`nt=99` monthly STL trend 新增为背景轨迹层，不替代 raw 观测。

Background warming speed will be estimated with a moving-window Sen slope of annualised STL trend and compared with the corresponding raw-annual moving-window speed. The long-term trend of that speed is called *change in background warming speed*. It is not presented as a resolved instantaneous physical acceleration.

> 背景增温速度由 annualised STL trend 的滑动 Sen 斜率估计，并与 raw annual 的对应速度比较。其长期趋势称“背景增温速度变化”，不称可精确测得的瞬时物理加速度。

The STL seasonal component may support a separate seasonal-amplitude analysis only after ice-state, missingness, endpoint, and parameter-sensitivity checks. STL remainder is not a pre-defined extreme or teleconnection response series.

> STL seasonal component 可在通过冰态、缺失、端点和参数敏感性 QC 后用于季节振幅分析。STL remainder 不是预定义的极端或遥相关响应序列。

## Raw–STL comparison retained outside the main narrative

For the 10-year rolling-Sen speed-change statistic, the raw annual representation has SD 3.61 and the `nt=99` STL-background representation has SD 1.30 (both \\10^{-3}\\ °C yr\\^{-2}\\). Their lake-level Spearman correlation is 0.558. STL therefore changes the inferred pattern rather than merely denoising raw annual temperature. This comparison is retained here for sensitivity documentation and future supplementary material; the main chapter uses raw annual 10-year speeds to describe observed heterogeneity.

> 10 年滑动速度变化中，raw annual 的 SD 为 3.61，`nt=99` STL 背景层为 1.30，逐湖秩相关仅 0.558。STL 改变的不只是噪声，也会改变识别出的模式。此对比保留在 prose/未来补充材料；正文用 raw annual 10 年速度描述观测异质性。

Back to top
