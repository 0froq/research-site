# Association Scope and Missing Driver Data

## Status

The former lake-level model and its rendered cross-validation figure used an archived `nt=199` lake-equal PCA and cluster branch, so none of its numerical results transfer to the current spatially balanced PCA. Step 11 likewise joins that archived response branch and is not an admissible current analysis input. The active cell-level restricted diagnostic is documented separately below.

> 旧湖泊尺度模型及其图使用归档的 `nt=199` 湖泊等权 PCA 与 cluster 分支，数值不能迁移到现有空间平衡 PCA。Step 11 同样连接旧响应分支，不能作为当前输入；当前格网尺度受限诊断另行记录。

## Available and missing inputs

Step 09 provides 1981–2020 lake-nearest-grid summaries for ERA5-Land wind speed, surface pressure, and total precipitation. It also provides annual and seasonal means, interannual variability, and 40-year Sen trends. These inputs are sufficient only for an exploratory predictive association branch.

> Step 09 提供 1981–2020 ERA5-Land 最近格网的风速、地面气压、降水汇总，以及年/季节均值、年际变异和 40 年 Sen 趋势。它们只足以支持探索性预测关联分支。

The branch lacks 2 m air temperature, downward shortwave and longwave radiation, humidity or evaporation/latent-heat variables, and a lake-specific mixing proxy. These are central heat-budget terms. Surface pressure is primarily an elevation/background proxy and is not treated as an independent physical forcing predictor. Because ERA5-Land-driven FLAKE information participates in GLAST reconstruction, an ERA5 association cannot be read as independent forcing evidence.

> 分支缺少 2 m 气温、向下短/长波辐射、湿度或蒸发/潜热变量，以及湖泊特异的混合代理；它们才是热收支关键项。地面气压主要是海拔/背景代理，不作为独立物理强迫预测变量。ERA5-Land 驱动 FLAKE 信息参与 GLAST 重建，故 ERA5 关联不能被读作独立强迫证据。

## Predeclared future design

The analysis unit is the 573 occupied equal-area PCA cells, not individual lakes. PC1 is a scalar response. PC2–PC3 is a joint secondary subspace because LOCO shows rank exchange; it is not a pair of separate mechanism targets. PC4–PC5 remain descriptive only. Lake attributes and ERA5 summaries are aggregated inside the same cells before modelling.

> 分析单位为 573 个占据的等面积 PCA 格网，而非单个湖泊。PC1 为单响应；PC2–PC3 因 LOCO 会交换排序，作为联合次级子空间，不作两种独立机制目标。PC4–PC5 仅保留描述。湖泊属性与 ERA5 汇总均先在相同格网内聚合。

Model comparison is predeclared as:

| Model | Predictor block | Role |
|----|----|----|
| Background | Continuous spatial basis, elevation, log lake area, depth, and distance to coast. | Describe broad geographic and lake-setting association. |
| Background plus ERA5 | Background block plus wind-speed and precipitation summaries/trends selected before fitting. | Test incremental held-out predictive association, not a forcing effect. |
| Sensitivity | Alternative predeclared spatial basis and cell aggregation summaries. | Check whether conclusions depend on representational choices. |

> 预先定义模型比较：地理/湖泊背景；再加入预先选择的风速与降水 ERA5 指标；最后做空间基与格网汇总敏感性。目标是检验留出预测增量，不估计强迫效应。

Continent labels, the retired teleconnection branch, and post-hoc screening across many seasonal predictors are excluded. Spatially contiguous blocks must be defined before fitting; primary evidence is held-out \\R^2\\ and its geography-to-ERA5 increment, not in-sample fit or coefficient significance. Any result is reported as an association with a PCA timing pattern, never as causal attribution.

> 不使用大洲标签、归档遥相关分支或大量季节预测变量的事后筛选。空间连续 block 须在拟合前定义；主证据为留出 \\R^2\\ 及 geography 到 ERA5 的增量，不是样本内拟合或系数显著性。所有结果只称与 PCA 时间模式的关联，不称因果归因。

## Start gate

The restricted exploratory branch uses only the predeclared current predictor table and spatial-block sensitivity design. It does not pass the interpretation gate for PC2–PC3 or raw warming-speed change. Heat-budget attribution remains inactive until missing thermal inputs are acquired. The current result is reported in [External Interpretation of Spatially Balanced PCA](../../../explorations/warming-acceleration/prose/pca-external-interpretation.llms.md).

> 受限探索分支只使用预先定义的现有变量表与空间 block 敏感性设计。它未通过 PC2–PC3 或 raw 增温速度变化的解释门槛。热收支归因在补齐缺失热变量前保持未启动；当前结果见 External Interpretation of Spatially Balanced PCA。

Back to top
