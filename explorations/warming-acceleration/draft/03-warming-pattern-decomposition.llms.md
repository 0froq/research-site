# Low-Frequency Warming Pattern Decomposition

This chapter decomposes baseline-centred annual STL trajectories after equal-area spatial aggregation. STL with `nt=99` is PCA-only low-frequency preprocessing; raw annual LSWT remains the primary warming and local-speed representation.

> 本章在等面积空间汇总后分解基线中心化年 STL 轨迹。`nt=99` STL 只用于 PCA 前低频处理；raw 年均 LSWT 仍是主要增温与局部速度表征。

## Spatially balanced trajectory space

PCA is fitted to 573 occupied equal-area cells representing 92,245 lakes. A lake-dense region may contain many nearly redundant trajectories; giving every lake one row would let sampling density, rather than spatial extent, dominate covariance. Cell aggregation gives each represented area one trajectory. It therefore estimates covariance for a represented spatial cell rather than for a typical sampled lake; lake scores are projections onto the resulting fixed cell axes.

> PCA 拟合于 573 个被占据的等面积格网，代表 92,245 湖。它描述代表性空间格网协变，不描述典型抽样湖泊；湖泊分数仅投影到固定格网轴。

![](03-warming-pattern-decomposition_files/figure-html/fig-pattern-scree-1.png)

Figure 1: Explained and cumulative variance for the first ten spatially balanced principal components.

PC1 is the dominant common low-frequency background. PC2–PC5 are successively smaller temporal contrasts. Whether any of these ranked axes recur after geographic omission is tested below; the initial PCA ordering alone does not establish a stable subspace.

> PC1 是主要共同低频背景。PC2–PC5 是依次较小的时间对比；是否能在地理删除后重复，要在后文 LOCO 检验中判断，不能仅由初始排序宣布为稳定子空间。

## Temporal and spatial modes

Loadings identify the temporal contrast expressed by a score. PCA signs are arbitrary; interpretation always concerns the score-loading combination. PC1 captures the dominant common late-period contrast. PC2 and PC3 describe secondary changes in the timing and persistence of low-frequency warming, rather than two fixed physical mechanisms.

> loading 给出分数所表达的时间对比。PCA 符号可整体翻转，必须解释“分数—loading”组合。PC1 捕捉主要共同后期对比；PC2、PC3 描述低频增温时间和持续性的次级差异，不是两个固定物理机制。

![](03-warming-pattern-decomposition_files/figure-html/fig-pattern-loadings-1.png)

Figure 2: Equal-area PCA loadings for PC1–PC5. PC1 is shown alone; PC2–PC3 and PC4–PC5 use matched vertical scales within each pair.

![](03-warming-pattern-decomposition_files/figure-html/fig-pattern-score-maps-1.png)

Figure 3: Spatial organisation of projected PC scores, averaged in 1° cells. PC2–PC3 and PC4–PC5 use matched score limits within each pair.

The score maps show continuous spatial organisation. They do not define continental types: adjacent regions can differ, and distant regions can express similar score combinations. Neighbour correlations range from 0.70 to 0.81 across PC1–PC5, confirming local continuity. Yet among 147,741 cell pairs at least 3,000 km apart, the closest five-score pair is 15938 km apart with a standardised five-score distance of 0.20. Distant similarity is therefore a descriptive recurrence of trajectory geometry, not evidence that two regions share one mechanism.

> 分数地图显示连续空间组织，不定义大洲类型：PC1–PC5 的邻接相关为 0.70–0.81。但相距至少 3,000 km 的格网对中，也存在五维分数接近的组合。它只说明轨迹几何可在远距地区重复，不说明共享同一机制。

## Reproducibility and result hierarchy

At the reference grid PC1–PC5 explain 84.6% of cell-trajectory variance. LOCO is the evidence that changes the interpretation of the ranked axes: PC2–PC3 retain a recurring joint temporal plane despite occasional rank exchange, whereas PC4–PC5 recur more weakly and partly mix. Score-pole composites show how the ends of each continuous score axis differ in trajectory; the targeted leave-one-decade test of the external JJA NAO/AO association remains positive for PC2–PC3. We therefore retain PC1 as the common background, PC2–PC3 as the main secondary descriptive subspace, and PC4–PC5 as lower-prominence detail.

> 参考格网中 PC1–PC5 共解释 84.6% 格网轨迹方差。LOCO 证明 PC2、PC3 可重复但可交换排序；PC4、PC5 重复更弱且部分混合。score-pole 复合展示每个连续分数轴两端的轨迹差异；外部 JJA NAO/AO 关联的定向 LODO 检验也保留 PC2–PC3 增益。因此 PC1 为共同背景，PC2–PC3 为主要次级描述子空间，PC4–PC5 为较低优先级细节。

Detailed loading interpretation, score-pole composites, and LOCO matching are retained in [PCA Stability Contract](../../../explorations/warming-acceleration/prose/pca-stability-contract.llms.md). PCA identifies reproducible covariance structure; it does not identify a forcing mechanism by itself.

> loading 解读、score-pole 复合和 LOCO 匹配详见 PCA Stability Contract。PCA 识别可重复协变结构，本身不识别驱动机制。

Construction, loading interpretation, maps, poles, and LOCO diagnostics remain in [PCA Stability Contract](../../../explorations/warming-acceleration/prose/pca-stability-contract.llms.md) and the earlier detailed [PCA exploration](../../../explorations/warming-acceleration/draft/02-warming-patterns.llms.md).

> 构建、loading 解读、地图、极端轨迹与 LOCO 诊断见 PCA Stability Contract 和既有 PCA 详细探索页。

Back to top
