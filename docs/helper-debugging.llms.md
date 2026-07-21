# Debugging Figure Helpers

A focused workflow for validating rendering-time data preparation before rendering a chapter.

Figure helpers are a rendering-time data compilation layer. Debug them directly in R before using Quarto: source the helper, load only the relevant inputs, run one `prepare_*()` function, inspect its output, and make a minimal diagnostic plot.

> Helper 是渲染期的数据编译层。先在 R 中独立调试，再进入 Quarto：加载 helper 与输入，只运行一个 `prepare_*()`，检查输出，最后用极简图验证。

## The focused loop

``` text
source helper → load inputs → run one prepare function → inspect QC/structure
→ draw a minimal diagnostic plot → implement or adjust the Quarto figure
```

Do not begin by rendering the whole chapter. A chapter render is the final integration check; it is a slow and noisy way to discover that a join, filter, unit, or geometry is wrong.

> 不要先渲染整章。整章渲染是最后的集成检查；用它排查 join、筛选、单位或几何错误，慢且噪声很大。

## Start an isolated R session

Start R with `site/` as the working directory so `figure-style.R` can find `_quarto.yml` and set the data-process root correctly.

``` r
source("shared/R/figure-style.R")
source("shared/R/descriptive-helpers.R")
source("shared/R/01-global-kinematics-helpers.R")

payload <- prepare_kinematics_data()
payload$spatial_hex_summary
```

For PCA work, source only the PCA helper and call its focused loader/preparation functions:

``` r
source("shared/R/figure-style.R")
source("shared/R/03-warming-pattern-decomposition-helpers.R")

payload <- prepare_pca_data()
payload$loading_plot_data
```

For modular prose figures, use the matching helper in exactly the same way:

``` r
source("shared/R/figure-style.R")
source("shared/R/seasonal-ice-diagnostics-helpers.R")
ice <- prepare_seasonal_ice_data()

source("shared/R/pca-kinematics-bridge-helpers.R")
bridge <- prepare_pca_kinematics_bridge_data()
```

> 在原子化重构完成前，可先调用当前的章节级 `prepare_*()`，但调试方式不变：检查它返回的对象，而不是先渲染 qmd。

## Check the contract at each boundary

Check inputs before checking aesthetics. For every loader or preparation function, inspect:

- provenance: expected producer branch, years, units, and parameter signature;
- identity: row count and uniqueness of `lake_id`;
- completeness: finite-value count and the effect of each filter;
- plot readiness: all coordinates, grouping identifiers, labels, and mapped values required by the figure.

``` r
str(payload)
dplyr::glimpse(payload$spatial_hex_summary)

stopifnot(
  all(c("lake_id", "lon", "lat") %in% names(payload$lake_warming_metrics)),
  !anyDuplicated(payload$lake_warming_metrics$lake_id)
)
```

Prefer an explicit failure to a plausible-looking wrong figure:

``` r
if (nrow(payload$spatial_hex_summary) == 0) {
  stop("No hex cells remain; check min_lakes or coordinate filters.", call. = FALSE)
}
```

> 先检查数据合同，再检查美学。优先让错误显式失败，不要接受一张“看似合理”的错误图。

## Return QC with each prepared payload

Each focused `prepare_*()` function should return the plot-ready data and a small `qc` record. QC is not a durable producer output; it is a fast rendering-time audit surface.

``` r
list(
  polygons = polygon_data,
  summary = summary_data,
  qc = list(
    n_input = nrow(inputs$metrics),
    n_finite = nrow(finite_data),
    n_plot = nrow(summary_data),
    years = c(min(years), max(years))
  )
)
```

Then inspect only the quantities that can invalidate the figure:

``` r
range(payload$spatial_hex_summary$warming_speed, na.rm = TRUE)
```

## Use a minimal diagnostic plot

Before working on guides, patchwork, typography, or captions, draw only the geometry and the mapped variable.

``` r
ggplot(payload$spatial_hex_poly) +
  geom_polygon(aes(lon, lat, group = id, fill = warming_speed)) +
  coord_equal()
```

If this plot is wrong, stay in the helper. If it is correct, move to the qmd and work only on figure composition and appearance.

> 极简图正确后再进入 qmd；极简图错误时，只改 helper，不要在图层参数中补丁式修复数据问题。

## Debug one function, not a chapter

Use ordinary R debugging tools on a single preparation function:

``` r
debugonce(prepare_kinematics_data)
payload <- prepare_kinematics_data()

trace(prepare_kinematics_data, tracer = quote(browser()), at = 3)
```

For repeatable checks, keep small assertions close to the transformation that establishes the relevant invariant. For example, assert coordinate finiteness after the coordinate join, and assert non-empty hex cells after aggregation.

## Only then render

Once the focused data object and minimal diagnostic plot are correct, render the edited qmd individually:

``` bash
quarto render explorations/warming-acceleration/draft/01-global-kinematics.qmd --to html
```

Use Quarto to validate inline values, cross-references, figure composition, legends, and page layout—not to discover basic data preparation errors.

> 数据层正确后再单独渲染 qmd。Quarto 负责验证内联值、交叉引用、图例和版式，不负责替代 helper 调试。

Back to top
