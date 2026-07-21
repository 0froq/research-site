# Introduction

Lake surface water temperature (LSWT) integrates atmospheric forcing, surface energy exchange, ice conditions and lake-specific thermal properties. Changes in LSWT can alter ice cover, stratification, oxygen conditions and the thermal habitats available to lake organisms ([Woolway et al. 2020](#ref-woolway2020); [Kraemer et al. 2021](#ref-kraemer2021)). Lake temperature is therefore both a climate-response variable and a physically meaningful part of freshwater change, rather than a simple local analogue of air temperature.

> 湖表温度综合了大气强迫、表面能量交换、冰状态与湖泊自身热特性。其变化会影响冰期、分层、氧条件和生物热栖息地；它是淡水系统的重要气候响应变量，不能简单等同于局地气温。

Global studies have established widespread LSWT warming, while also showing that lakes do not warm uniformly. A synthesis of in-situ and satellite records reported a mean summer LSWT increase of 0.34 °C decade\\^{-1}\\ during 1985–2009 and found that similar warming rates were rarely organised into simple geographic regions ([O’Reilly et al. 2015](#ref-oreilly2015)). The later GLAST reconstruction extended annual coverage to 92,245 lakes for 1981–2020, including many Arctic lakes, and estimated a global mean LSWT trend of 0.24 °C decade\\^{-1}\\ ([Tong et al. 2023](#ref-tong2023)). These studies establish the magnitude and broad spatial heterogeneity of lake warming, but their principal summary remains one long-term trend per lake.

> 全球研究已确认 LSWT 广泛增温，同时湖泊并不以统一方式增温。O’Reilly 等以夏季资料给出 1985–2009 年全球平均升温，且相近趋势很少形成简单区域；GLAST 则将年尺度覆盖扩展至 92,245 个湖泊与 1981–2020 年。它们确立了增温幅度和空间差异，但主要仍以每湖一个长期趋势来概括变化。

Reducing a four-decade record to one slope leaves its temporal pathway unresolved. A positive long-term trend can result from nearly steady warming, warming concentrated late in the record, early warming followed by weaker change, or reversals over individual decades. Existing work shows that such structure can matter: Central European lakes underwent an abrupt late-1980s shift in annual LSWT, superimposed on their long-term warming ([Woolway et al. 2017](#ref-woolway2017)). Global functional analyses have also classified recurring *seasonal* surface temperature curves and their projected future shifts ([Maberly et al. 2020](#ref-maberly2020)). Those studies demonstrate the value of temporal structure, but do not ask whether four decades of observed annual warming form spatially organised, continuous multidecadal pathways across a global lake population.

> 一个四十年趋势无法说明它经历了怎样的时间过程：持续增温、后期增强、早期增温后减弱，或局地反转，都可能得到相近斜率。区域研究已观察到阶段性变暖；全球功能分析也刻画过季节温度曲线。但前者是区域案例，后者关注季节热型与未来投影，尚未系统比较全球湖泊的多年年均增温路径及其空间组织。

This question also requires care about spatial representation. Lakes are unevenly distributed, and a lake-level covariance analysis would give a dense lake region more influence simply because it contains more records. At the same time, long-term warming can coexist with interannual and decadal climate variability: regional lake records have linked abrupt thermal shifts to wider climate conditions ([Woolway et al. 2017](#ref-woolway2017)), while reviews identify large-scale modes as relevant but context-dependent sources of lake thermal variability ([Woolway et al. 2020](#ref-woolway2020)). These observations motivate a spatially balanced description of trajectories and a deliberately limited test of their external climate context, rather than a claim of physical attribution.

> 全球湖泊分布很不均匀；若直接用每湖记录做协方差分析，湖泊密集区会仅因样本更多而获得更大权重。长期增温也会叠加年际与年代际气候变率。已有区域研究与综述提示大尺度气候条件有关，但依赖区域和情境。因此需要空间平衡地描述轨迹，并谨慎检验其外部气候关联，而非直接作物理归因。

Here we use the 1981–2020 GLAST reconstruction, which combines satellite information with ERA5-Land-forced FLAKE output and calibration, rather than direct in-situ observations ([Tong et al. 2023](#ref-tong2023)). We ask three descriptive questions: first, how do long-term warming magnitude and endpoint-aligned decadal warming rates vary among lakes and through time? Second, after equal-area spatial balancing, which low-frequency annual trajectories recur and how are their scores organised geographically? Third, do these trajectories co-locate with the spatially heterogeneous sensitivity of detrended summer LSWT to predeclared NAO/AO variability? We use raw annual reconstructed LSWT for the primary warming metrics, and use STL only to obtain the low-frequency input to PCA. The resulting framework characterises reproducible temporal and spatial organisation; it does not identify discrete lake types or establish causal mechanisms.

> 本文使用 1981–2020 年 GLAST 重建产品，它由卫星信息、ERA5-Land 强迫的 FLAKE 输出和校正组成，并非直接原位观测。本文依次描述：长期增温幅度与十年速度如何变化；空间平衡后哪些低频年均轨迹重复出现、如何地理组织；这些轨迹是否与去趋势夏季 LSWT 对预定义 NAO/AO 变率的空间敏感性共定位。主指标来自 raw 年均重建 LSWT；STL 仅为 PCA 提供低频输入。该框架描述可重复的时空组织，不划分自然湖泊类型，也不建立因果机制。

Back to top

## References

Kraemer, Benjamin M., Rachel M. Pilla, R. Iestyn Woolway, et al. 2021. “Climate Change Drives Widespread Shifts in Lake Thermal Habitat.” *Nature Climate Change* 11 (6): 521–29. <https://doi.org/10.1038/s41558-021-01060-3>.

Maberly, Stephen C., Ruth A. O’Donnell, R. Iestyn Woolway, et al. 2020. “Global Lake Thermal Regions Shift Under Climate Change.” *Nature Communications* 11 (1): 1232. <https://doi.org/10.1038/s41467-020-15108-z>.

O’Reilly, Catherine M., Sapna Sharma, Derek K. Gray, et al. 2015. “Rapid and Highly Variable Warming of Lake Surface Waters Around the Globe.” *Geophysical Research Letters* 42 (24): 1–9. <https://doi.org/10.1002/2015GL066235>.

Tong, Yan, Lian Feng, Xinchi Wang, Xuehui Pi, Wang Xu, and R. Iestyn Woolway. 2023. “Global Lakes Are Warming Slower Than Surface Air Temperature Due to Accelerated Evaporation.” *Nature Water* 1 (11): 929–40. <https://doi.org/10.1038/s44221-023-00148-8>.

Woolway, R. Iestyn, Martin T. Dokulil, Wlodzimierz Marszelewski, Martin Schmid, Damien Bouffard, and Christopher J. Merchant. 2017. “Warming of Central European Lakes and Their Response to the 1980s Climate Regime Shift.” *Climatic Change* 142 (3): 505–20. <https://doi.org/10.1007/s10584-017-1966-4>.

Woolway, R. Iestyn, Benjamin M. Kraemer, John D. Lenters, Christopher J. Merchant, Catherine M. O’Reilly, and Sapna Sharma. 2020. “Global Lake Responses to Climate Change.” *Nature Reviews Earth & Environment* 1 (8): 388–403. <https://doi.org/10.1038/s43017-020-0067-5>.
