# Limitations of STARS regime-shift detection for lake warming analysis

## What STARS does

STARS (Sequential \\t\\-test Analysis of Regime Shifts; Rodionov 2004) detects persistent changes in the mean of a time series. Applied to annual warming speed (first difference of STL trend), a STARS shift marks a transition between mean warming-speed regimes. The canonical configuration uses cut-off length \\L = 7\\ and significance level \\p = 0.05\\.

> STARS 检测时间序列均值的持久变化。应用于年增温速度（STL 趋势的一阶差分）时，变点标记增温速度均值体制间的转换。

## Observed problems

### Over-detection with smooth trends

When applied to the first difference of STL trend with nt=199 (the original canonical parameter), STARS detected regime shifts in 99% of lakes (92,006 of 92,245). The total number of detected events was 251,922, averaging 2.7 shifts per lake over 39 years. This is implausibly high and suggests that the smooth trend’s residual autocorrelation produces false positives.

> nt=199 时 STARS 在 99% 的湖泊中检测到变点（251,922 个事件），显然过度检测。

### Under-detection with responsive trends

When applied to nt=99 trend differences, STARS detected shifts in only 54% of lakes (54 of 100 test subset), with 71 total events. Many visually apparent speed changes were not flagged. The method’s confirmation rule (requiring \\L\\ subsequent values to remain above the threshold) makes it insensitive to gradual transitions.

> nt=99 时仅 54% 湖泊检测到变点。确认规则（需 L 个后续值保持在阈值以上）使方法对渐变不敏感。

### Sensitivity to nt parameter

The number of detected shifts varied by a factor of 3.5 between nt=199 and nt=99:

| Parameter | Lakes with shifts | Total events | Shifts per lake |
|-----------|-------------------|--------------|-----------------|
| nt=199    | 99%               | 251,922      | 2.7             |
| nt=99     | 54%               | 71           | 0.7             |

This extreme sensitivity to a parameter choice that is itself difficult to justify on physical grounds makes STARS results unreliable for comparative analysis.

> 检测到的变点数量在 nt=199 和 nt=99 之间相差 3.5 倍，对参数选择极度敏感。

### Binary output

STARS classifies each year as either “in a regime” or “between regimes,” discarding the continuous information about warming speed magnitude. This is particularly problematic for attribution, where the relationship between predictors and speed changes is likely continuous rather than threshold-based.

> STARS 将每年二值化为”体制内”或”体制间”，丢失了增温速度的连续信息，不利于归因分析。

## Example: visual inspection vs. STARS detection

For representative lakes tested with nt=99:

| Lake | Visual pattern | STARS detection |
|----|----|----|
| Caspian Sea | Clear acceleration ~1996, deceleration ~2009 | No shifts detected |
| Winnipeg | Gradual speed increase | 1 shift (1994) |
| Huron | Strong 1996 peak, 2003 decline | 1 shift (2001) |
| Nicaragua | 2010 acceleration | 1 shift (2011) |

The Caspian Sea case is particularly telling: the warming speed increases from near-zero in 1988 to +0.07 °C/yr in 2000, then declines to near-zero by 2013. This is a clear regime change by visual inspection, but STARS does not detect it because the transition is gradual rather than abrupt.

> 里海案例：增温速度从 1988 年接近零增至 2000 年 +0.07 °C/yr，后降至 2013 年接近零。视觉上明显，但 STARS 未检出（渐变而非突变）。

## Why PCA is better for this analysis

PCA addresses the limitations of STARS in several ways:

1.  **Continuous output**: PCA scores are continuous variables, preserving the full spectrum of warming heterogeneity.
2.  **No parameter sensitivity**: PCA does not require choosing \\L\\ or \\p\\; the number of retained components is determined by variance explained.
3.  **Physically interpretable**: Component loadings reveal what temporal pattern each score represents.
4.  **Directly usable for regression**: PCA scores can be regressed against teleconnection indices, local climate variables, and lake characteristics.

> PCA 以连续输出、无参数敏感性、物理可解释性和直接可回归性替代 STARS。

## Recommendation

The main analysis (Chapter 2) uses PCA scores as the primary characterisation of warming patterns. STARS results are available as supplementary material but are not used for the core attribution analysis. If regime-shift detection is needed for specific applications, it should be used with caution and accompanied by sensitivity analysis across the nt parameter.

> 主分析使用 PCA 分数。STARS 结果可作为补充材料，但不用于核心归因分析。

Back to top
