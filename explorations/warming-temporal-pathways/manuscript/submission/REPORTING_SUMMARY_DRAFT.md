# Reporting Summary draft — author verification required

This draft is based only on the current manuscript, analysis contract and
active render code. It is designed for completion in the journal's final
Reporting Summary template. Text marked `AUTHOR_INPUT_NEEDED` must be verified
before submission; it is intentionally not inserted into the manuscript.

## Study design

### Study description

This observational, global time-series analysis characterises reconstructed
1981--2020 annual lake surface water temperature (LSWT) for the complete GLAST
historical lake universe (92,245 records). It compares long-term raw annual
LSWT displacement with endpoint-aligned local-rate histories, then represents
low-frequency temporal covariance through PCA fitted to occupied equal-area
cells. A fixed climate-index analysis is reported as a descriptive spatial
association screen only.

### Research sample

The lake universe was determined by GLAST coverage rather than recruitment or
sampling. Lake-level distributional results use each finite GLAST lake record
as the descriptive unit. The PCA estimand uses one baseline-centred trajectory
per occupied equal-area cell (573 canonical cells); lake-level PCA scores are
projections on those fixed cell-derived axes. Trailing 10-year rates within a
lake share observations and are analysed as a dependent time history, not as
independent replicates.

### Replication and robustness

There are no biological or technical replicates in the experimental sense.
Robustness is evaluated through prespecified representation refits: continental
and ten-year omissions, alternate equal-area grids, raw and moving-average
inputs, within-cell median aggregation, and a minimum-five-lakes-per-cell
branch. The leading PC1 axis is evaluated as a one-dimensional loading; PC2--
PC3 is evaluated as a subspace where rank exchange is possible.

### Randomisation and blinding

Not applicable. The study analyses a complete defined reconstruction product;
there was no allocation, intervention, or blinded outcome assessment.

### Sample-size determination

No power calculation was used. The analysis uses all 92,245 records available
in the fixed GLAST historical product. Trend-significance rows require at
least ten finite annual values; the primary manuscript universe is otherwise
defined by the GLAST historical product rather than a power- or
completeness-selected subsample.

### Data exclusions and missing data

The primary annual trend and local-rate analyses use finite raw annual LSWT
values. For liquid-water annual/seasonal means, daily values at or below 0 °C
are not averaged; a period with no valid liquid-water days is retained as a
finite 0 °C frozen state. Candidate JJA association correlations exclude frozen
JJA states and require at least 30 valid season-years (28 in the specified
leave-one-decade-out sensitivity). PCA sensitivity explicitly removes cells
with fewer than five lakes only in that refit; the canonical analysis retains
all occupied cells. The canonical HydroLAKES join rejects duplicate filtered
`Hylak_id` values as an error rather than silently resolving them. The
geographic-context producer also rejects non-finite metadata coordinates;
mapped summaries restrict the stated geographic domain to 60°S--85°N.

## Statistical analysis

### Data transformation and summaries

Long-term warming is the Theil--Sen slope of raw annual LSWT over 1981--2020,
reported in °C decade−1. Local warming rate is an endpoint-aligned trailing
10-year Theil--Sen slope, reported in °C yr−1; warming-speed change is the Sen
slope across the valid local-rate sequence, in 10−3 °C yr−2. Lake-equal
distributions are reported with medians and interquartile ranges where stated.
Figure ribbons and density insets are explicitly identified as distributional
summaries, not uncertainty intervals.

### Trend tests and spatial diagnostics

Two-sided Mann--Kendall and trend-free prewhitened Mann--Kendall tests are used
only as lake-level descriptive detectability screens and map hatching inputs.
Raw-series Theil--Sen slopes remain the primary effect-size estimand. Nominal
lake/cell P values are not interpreted as field-wide discoveries; no
field-wide multiple-testing claim is made. Spatial continuity is quantified
with queen-neighbour Moran's I and 999 permutations.

### PCA and association analyses

PCA is fitted by singular-value decomposition to a column-centred matrix of
573 equal-area cell trajectories, using a fixed `nt = 99` STL representation
only for this low-frequency decomposition. PCA components are continuous
coordinates, not lake classes. Climate-index analyses use detrended seasonal
LSWT anomalies, Fisher-z transformed lake-level correlations and equal-area
aggregation. Geographic, continent and decade hold-outs test stability; these
associations do not identify causality or a circulation mechanism.

### Software and reproducibility

The inspected rendering environment is R 4.6.1 and Quarto 1.9.38; durable
data products are created by the Julia pipeline defined in
`data-process/pipeline/manifest.toml`, whose Manifest specifies Julia 1.12.1.
The inspected Git heads are `research-site` 53612ad and `data-process`
4085f13, but both working trees contain uncommitted manuscript or pipeline
changes and are not archival revisions. `AUTHOR_INPUT_NEEDED: freeze and tag
the final source trees, then record those revisions, `Project.toml`/
`Manifest.toml` hashes and the R package snapshot in the archived release.`

## Reporting risks to close before submission

- **P1 — source-product uncertainty:** the manuscript correctly scopes claims
  to reconstructed surface conditions, but no product-level uncertainty model
  is propagated through slopes/PCA. Confirm the GLAST validation citation and
  state the product's available uncertainty information accurately.
- **P1 — public reproducibility:** code/data DOI, panel source data, checksums
  and exact third-party versions remain external deposit actions.
- **P2 — figure production:** 600-dpi PNG staging is complete; final accepted
  format, font embedding and journal dimensions remain to be checked.
- **P2 — journal choice:** the English body is approximately 7,352 words. If
  Nature Communications is selected, reconcile this with its Article word
  budget before submission.

## 中文核对

- `n` 有三种层级：湖泊分布、573 个等面积 PCA cell、单湖的相关时间点。后两者不能混为独立重复。
- 研究没有随机分组或盲法；这源于完整重建数据的观察性设计，而非遗漏实验程序。
- 冻结状态、关联配对数和 `n≥5` 都有明确规则；仍需作者确认上游数据清洗与最终软件版本。
