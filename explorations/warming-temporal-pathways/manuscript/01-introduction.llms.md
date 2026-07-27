# Introduction

Lake surface water temperature (LSWT) sits at the interface of atmospheric forcing, lake heat storage and freshwater ecosystems. Changes at the surface alter ice phenology, stratification, oxygen conditions and thermal habitat, and can therefore change the seasonal setting in which lake organisms and biogeochemical processes operate ([Woolway et al. 2020](#ref-woolway2020); [Kraemer et al. 2021](#ref-kraemer2021)). LSWT is also a state variable with its own dynamics. Air temperature, radiation, wind, cloud, ice state, depth and morphology can produce similar annual mean temperatures through different within-record histories. A global account of freshwater warming therefore needs to ask both how far lake temperatures have changed and how that change accumulated through time.

> 湖表温连接气候、冰况、分层、氧和栖息地。论文关注两件事：四十年净变化，以及净变化形成的时间过程。

Global evidence already establishes widespread lake warming and substantial heterogeneity. A synthesis of in-situ and satellite records estimated mean summer surface warming of 0.34 °C decade\\^{-1}\\ during 1985–2009, with lake trends ranging from cooling to rapid warming and little simple geographic zoning of like rates ([O’Reilly et al. 2015](#ref-oreilly2015)). The GLAST reconstruction then extended annual coverage to 92,245 lakes for 1981–2020, including many Arctic lakes, and estimated a global mean LSWT trend of 0.24 °C decade\\^{-1}\\ ([Tong et al. 2023](#ref-tong2023)). These results establish the scale of the issue and provide a valuable global baseline. Their principal summary, however, remains a long-period trend for each lake.

> 现有全球研究已回答“是否广泛增温”和“幅度差异多大”。本文承接同一数据基础，将关注点推进到年际至年代际的变化路径。

A forty-year slope is an informative estimate of net displacement. It cannot distinguish a lake that warmed steadily from one in which warming strengthened late in the record, weakened after an early rise, or changed direction across several decades. These alternatives matter for interpretation because they place the same net trend in different climatic and ecological contexts. In particular, a trend that is concentrated late in a record has a different relationship to contemporaneous ice, stratification and habitat conditions than an equal trend accumulated early. The present study treats this temporal history as a descriptive property of the reconstructed LSWT series; it does not infer an instantaneous physical acceleration from rolling estimates.

> 长期 slope 给出净位移。局地十年速率的历史补充“何时变得更快或更慢”；本文将其作为描述性时间坐标，不赋予瞬时物理加速度含义。

Prior work shows why this distinction deserves global treatment. Central European lakes exhibited a late-1980s shift in annual LSWT superimposed on long-term warming ([Woolway et al. 2017](#ref-woolway2017)), and a global analysis of 155 lakes compared warming rates before and during the late-1990s to early-2010s slowdown ([Winslow et al. 2018](#ref-winslow2018)). Those studies demonstrate period dependence in lake warming. They do not resolve the distribution of endpoint-aligned decadal-rate histories throughout a common four-decade record for a global lake population. A related literature classifies recurring *seasonal* temperature curves into thermal regions and evaluates their future displacement ([Maberly et al. 2020](#ref-maberly2020)). Seasonal thermal regions answer a different question from the present analysis: they describe within-year thermal form, whereas we examine between-cell variation in the timing of low-frequency annual trajectories.

> 比较对象界定了本文的新意边界：区域跃迁、时期比较、季节热型都证明时间结构重要；本文检验全球年均低频路径能否形成连续的空间组织。

The global setting introduces a second problem. Lake observations and reconstructions are spatially uneven, and a covariance analysis fitted directly to all lake records would give densely sampled regions greater influence. We therefore formulate the PCA estimand at the level of occupied equal-area cells. Each cell contributes one baseline-centred trajectory, while lake-level projections retain the relation of individual records to the common axes. This design does not create a global spatial-process model. It makes the population represented by the PCA explicit and permits a direct test of whether its trajectory coordinates form broad spatial fields.

> PCA 以等面积 cell 为空间单位，使高采样区不会仅凭样本数量主导全球轴。该选择服务全球空间表述；完整空间过程模型属于另一类分析。

The same discipline is needed when placing trajectory patterns alongside climate indices. Lake thermal histories can co-vary with interannual and decadal circulation variability ([Woolway et al. 2017](#ref-woolway2017), [2020](#ref-woolway2020)). A lagged spatial association nevertheless leaves the direction of influence, intermediate heat fluxes, lake morphology and ice conditions unresolved. We therefore use teleconnection fields as a deliberately limited context screen. The screen asks whether an association pattern recurs across spatial and temporal perturbations; it does not estimate a circulation-to-lake pathway.

> 气候指数部分承担“空间共定位是否可重复”的任务。热收支链条、方向和混杂因素留给后续独立归因设计。

Here we use the 1981–2020 GLAST reconstruction, a satellite-informed, ERA5-Land-forced FLAKE product calibrated against observations ([Tong et al. 2023](#ref-tong2023)). We first quantify long-term warming and endpoint-aligned decadal warming rates from raw annual reconstructed LSWT. We then ask whether lakes with comparable net warming can still occupy different local-rate histories. Next, we use spatially balanced PCA of low-frequency annual trajectories to identify a leading background and a secondary timing plane, map their continuous spatial organisation, and assess their sensitivity to continental omission, temporal omission, representation, cell aggregation and cell sample density. Finally, we examine the co-location of the retained secondary geometry with predeclared lagged summer NAO/AO sensitivity fields. The study consequently provides a descriptive framework for global lake-warming pathways, with explicit limits on classification and causal interpretation.

> 论文问题链为：净增温 → 局地速率历史 → 低频路径几何 → 空间结构 → 受限的外部共定位。每一步都有对应数据、图件和措辞上限。

Back to top

## References

Kraemer, Benjamin M., Rachel M. Pilla, R. Iestyn Woolway, et al. 2021. “Climate Change Drives Widespread Shifts in Lake Thermal Habitat.” *Nature Climate Change* 11 (6): 521–29. <https://doi.org/10.1038/s41558-021-01060-3>.

Maberly, Stephen C., Ruth A. O’Donnell, R. Iestyn Woolway, et al. 2020. “Global Lake Thermal Regions Shift Under Climate Change.” *Nature Communications* 11 (1): 1232. <https://doi.org/10.1038/s41467-020-15108-z>.

O’Reilly, Catherine M., Sapna Sharma, Derek K. Gray, et al. 2015. “Rapid and Highly Variable Warming of Lake Surface Waters Around the Globe.” *Geophysical Research Letters* 42 (24): 1–9. <https://doi.org/10.1002/2015GL066235>.

Tong, Yan, Lian Feng, Xinchi Wang, Xuehui Pi, Wang Xu, and R. Iestyn Woolway. 2023. “Global Lakes Are Warming Slower Than Surface Air Temperature Due to Accelerated Evaporation.” *Nature Water* 1 (11): 929–40. <https://doi.org/10.1038/s44221-023-00148-8>.

Winslow, Luke A, Taylor H Leach, and Kevin C Rose. 2018. “Global Lake Response to the Recent Warming Hiatus.” *Environmental Research Letters* 13 (5): 54005. <https://doi.org/10.1088/1748-9326/aab9d7>.

Woolway, R. Iestyn, Martin T. Dokulil, Wlodzimierz Marszelewski, Martin Schmid, Damien Bouffard, and Christopher J. Merchant. 2017. “Warming of Central European Lakes and Their Response to the 1980s Climate Regime Shift.” *Climatic Change* 142 (3): 505–20. <https://doi.org/10.1007/s10584-017-1966-4>.

Woolway, R. Iestyn, Benjamin M. Kraemer, John D. Lenters, Christopher J. Merchant, Catherine M. O’Reilly, and Sapna Sharma. 2020. “Global Lake Responses to Climate Change.” *Nature Reviews Earth & Environment* 1 (8): 388–403. <https://doi.org/10.1038/s43017-020-0067-5>.
