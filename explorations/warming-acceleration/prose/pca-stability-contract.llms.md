# PCA Stability and Association Contract

## Purpose

PCA identifies empirical modes of covariance; it does not establish a physical process or assign causation. Before interpreting PC1–PC5 spatially, the retained modes must be checked for stability under resampling and geographic omission.

> PCA 给出协方差模态，不等于物理机制或因果归因。解释 PC1–PC5 空间格局前，须检验重采样与地理遗漏下的稳定性。

## Required checks

| Check | Design | Report |
|----|----|----|
| Random split stability | Refit PCA on repeated independent half-samples; align component signs to the reference loading. | Variance explained and loading cosine congruence for PC1–PC5. |
| Leave-continent-out stability | Refit after omitting each represented continent. | Whether a retained component is dominated by one continental sample. |
| Input representation sensitivity | Compare current `nt=99` STL-trend anomaly PCA with the archived raw-annual anomaly branch. | Loading correlation and ordering of major temporal features. |
| Score association robustness | Fit geography-only and geography-plus-ERA5 associations with deterministic spatial blocks. | Held-out performance increment, not only in-sample \\R^2\\. |

> 必做：随机半样本、留一大洲、输入表征敏感性，以及空间分块关联模型验证。报告留出性能，不只报告样本内 \\R^2\\。

## Alignment rule

PCA signs are arbitrary. Each replicate component is sign-aligned to the reference PC with the largest absolute loading dot product. Labels are not transferred when matching is weak or ambiguous; this is reported as instability.

> PCA 正负号任意。重采样先按最大绝对载荷内积匹配并对齐符号；若匹配弱或含糊，不强行沿用 PC 标签，应报告不稳定。

## Interpretation boundary

Even a stable PC is a reproducible covariance pattern, not a driver. ERA5 associations can prioritize candidate mechanisms and identify omitted-variable risk; they cannot separate direct forcing from shared geography, radiation/evaporation mediation, or retrieval artefacts.

> 即使稳定的 PC 也只是可复现协方差模式。ERA5 关联只能筛选候选机制、揭示遗漏变量风险，不能区分直接强迫、共同地理背景、辐射/蒸发中介或反演伪影。

Back to top
