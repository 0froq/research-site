# Analysis Contract

Canonical definitions and parameter choices for the lake-warming exploration.

This page is the canonical, human-readable contract for the active warming-acceleration analysis. It defines the quantities used in the draft chapters; producer-specific implementation and output provenance remain in `data-process/steps/*/README.md` and generated `METADATA.md` files.

> 本页是当前增暖探索的分析合同：统一指标定义、参数和适用边界。数据生产细节仍以各 Step 的 README、METADATA 和 SUMMARY 为准。

## Active analysis definitions

| Concept | Canonical definition | Role |
|----|----|----|
| Annual temperature | Calendar-year mean LSWT calculated directly from valid non-freezing daily GLAST observations. | Input for all primary warming, warming-speed, and acceleration metrics. |
| Long-term warming | Theil–Sen slope of the raw annual mean LSWT series, reported as °C per 40 years. | Primary descriptive warming metric. |
| Annual warming speed | Adjacent-year first difference of raw annual mean LSWT, in °C yr⁻¹. | Input to the acceleration metric. |
| Acceleration | Provisional Sen slope of adjacent-year differences in raw annual-mean LSWT over 1982–2020, in 10⁻³ °C yr⁻². | Descriptive diagnostic only: high dispersion requires robustness review before inferential use. |
| PCA input | Annual mean of the STL trend with `period=12`, `robust=false`, `ni=5`, `no=0`, and `nt=99`; each lake is expressed as an anomaly from its 1981–1990 mean. | Low-frequency trajectory representation only; not a substitute for the primary warming metrics. |
| PCA interpretation set | PC1–PC5. | The substantive modes shown, mapped, and interpreted in the chapter. The 95% variance threshold is a diagnostic, not a retention rule. |

> 原始年均温度负责描述增暖、年增暖速度与加速度；STL `nt=99` 只在 PCA 前提取低频轨迹。正文解释前 5 个主成分，不以累计 95% 方差作为保留阈值。

## Explicit exclusions

STARS / ST_AIS persistent-regime detection is not part of the active analysis workflow. Historical Step 12 outputs and any helper code written for them are not inputs to the current chapters. Do not revive the method by accident through a default helper or an undocumented parameter branch.

> STARS / ST_AIS 当前不属于分析流程。历史 Step 12 输出与对应 helper 不得作为正文输入，也不应因默认路径而被意外重新启用。

## Provenance and change rule

Every chapter must name the producer branch it reads. A change to any definition above requires the same change in: this contract, the relevant `data-process` producer documentation, `AGENTS.md`, and the affected chapter prose/captions. If only a sensitivity analysis uses a different branch, label it as such rather than changing the canonical wording.

> 每章应明确读取的 producer branch。改动本页定义时，要同步更新 Step 文档、AGENTS 和相关正文/图注；敏感性分支必须明确标记，不能替换 canonical 叙述。

## Related workflow

For the focused R workflow used to validate one figure’s rendering-time data preparation before a chapter render, see [Debugging Figure Helpers](../docs/helper-debugging.llms.md).

Back to top
