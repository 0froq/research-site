# Main-figure source-data manifest — draft deposit map

This is a source-level map for preparing the public source-data deposit. It is
not itself source data and does not claim that a public deposit already exists.
All paths below are logical dataset identifiers resolved by
`site/R/core/catalog.R`; local `data-process/derived/` paths must not be cited
as public locations in a submitted paper.

The matching 600-dpi rendering workflow is
`site/scripts/export-manuscript-figures.sh`. Its numbering defines the
Figure-01 to Figure-10 source-data mapping below.

| Main figure | Render source | Curated datasets that must be deposited or reproducibly generated | Minimum source-data deliverable |
|---|---|---|---|
| Fig. 1 — long-term warming distribution | `results/01-global-kinematics.qmd`; `R/domains/kinematics.R`; `R/figures/results/01-global-kinematics.R` | `monthly-lswt`, `lake-metadata`, `warming-metrics`, `trajectory-diagnostics` | 1° map cells with lake count, lake-equal 40-year slope and hatching flag; lake-equal and area-weighted density inputs. |
| Fig. 2 — geographic long-term distributions | same as Fig. 1 | `lake-metadata`, `warming-metrics` | Lake-level 40-year slope, latitude band and continent; record the exact inclusion and grouping rules. |
| Fig. 3 — within-period dynamics | `results/02-within-period-pathways.qmd`; `R/domains/kinematics.R` | `annual-lswt`, `trajectory-diagnostics`, `lake-metadata`, `warming-metrics` | Endpoint-year lake-equal median/IQR of trailing 10-year slopes; 1° tendency cells and density values; hatching input. |
| Fig. 4 — representative pathways | `results/02-within-period-pathways.qmd` | `annual-lswt`, `trajectory-diagnostics`, `lake-metadata`, `warming-metrics` | Four selected lake identifiers, selection descriptors, raw annual anomalies, trailing slopes and location coordinates. |
| Fig. 5 — PCA trajectory space | `results/03-warming-patterns.qmd`; `R/domains/pathways.R` | `spatial-pca/sinlat_equalarea_72x21_mean` | `pca_variance.csv`, `pca_loadings.csv`, and phase-path coordinates; record baseline period and the display-sign convention. |
| Fig. 6 — spatial pathway fields | `results/04-spatial-organization.qmd`; `R/domains/pathways.R`; `R/figures/results/04-spatial-organization.R` | `spatial-pca/sinlat_equalarea_72x21_mean` | Equal-area cell identifier, geometry coordinates, PC1--PC3 scores, PC2--PC3 magnitude and relevant color-scale limits. |
| Fig. 7 — metric and coordinate overlap | `results/04-spatial-organization.qmd`; `R/figures/results/04-spatial-organization.R` | `spatial-pca/sinlat_equalarea_72x21_mean`, `warming-metrics`, `trajectory-diagnostics` | Cell-level 40-year slope, local-rate tendency, PC scores/magnitude and the reported correlation table. |
| Fig. 8 — robustness envelope | `results/05-trajectory-robustness.qmd`; `R/figures/results/05-trajectory-robustness.R` | canonical and named refit folders under `spatial-pca` | Continental/decadal omission alignment values, alternative representation/grid congruence and component-matching table. |
| Fig. 9 — climate-context fields | `results/06-climate-links.qmd`; `R/domains/climate-links-seasonal.R`; `R/domains/climate-links-selected.R` | `selected-teleconnection-association`, canonical `spatial-pca`, `lake-metadata` | Candidate definition, lake-level pair count and Fisher-z association, equal-area aggregation, geographic residual field and hold-out summaries. |

## Deposit assembly rules

1. Export CSV or parquet tables at the granularity actually plotted; retain
   stable `lake_id` and `cell_id` keys where disclosure and provider terms
   allow it.
2. Include a `README`, variable dictionary, unit/missing-value conventions,
   figure-panel column map and hash/record of the generating task profile.
3. Keep a separate `third_party_sources.md` for GLAST, HydroLAKES and climate
   indices. It must state version, permanent identifier, licence and access
   date, and must not redistribute restricted inputs by default.
4. Record selection code and pre-specified descriptors for Fig. 4; a display
   subset without its selection rule is not reproducible source data.
5. Deposit the source-data tables only after re-rendering the final numbered
   figure package, so the table-to-panel map cannot drift.

## Chinese handoff

- 每幅主图都应有一个与图层一一对应的源数据表；图 4 还需同时公开示例湖的选择规则。
- `dataset_id` 与本地 derived 路径只是可复现入口，不等同于公开 DOI。
- 数据存档需要在最终编号、配色和面板确定后再冻结，避免 source-data 与提交图不匹配。
