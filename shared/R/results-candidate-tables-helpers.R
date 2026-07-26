# Rendering-time summaries for candidate Results tables.

prepare_results_candidate_tables <- function(data_dir = data) {
  metadata <- read_csv(file.path(data_dir, "00-lake-metadata", "output", "lake_metadata.csv"), show_col_types = FALSE)
  metrics <- read_csv(file.path(data_dir, "06-lake-warming-metrics", "output", "period12_robustfalse_ni5_no0_nt99", "lake_warming_metrics.csv"), show_col_types = FALSE) |>
    select(lake_id, raw_annual_mean_temp_sen_slope_40yr) |>
    left_join(metadata |> select(lake_id, Continent), by = "lake_id") |>
    mutate(warming_decade = raw_annual_mean_temp_sen_slope_40yr / 4)
  continent_summary <- metrics |>
    filter(!is.na(Continent), is.finite(warming_decade)) |>
    group_by(Continent) |>
    summarise(n = n(), median = median(warming_decade), mean = mean(warming_decade), q25 = quantile(warming_decade, .25), q75 = quantile(warming_decade, .75), positive_pct = mean(warming_decade > 0) * 100, .groups = "drop")
  pca_dir <- file.path(data_dir, "16-spatial-balanced-pca", "output", "sinlat_equalarea_72x21_mean")
  pca_variance <- read_csv(file.path(pca_dir, "pca_variance.csv"), show_col_types = FALSE) |>
    filter(pc <= 10) |>
    mutate(explained_pct = explained_variance * 100, cumulative_pct = cumulative_explained_variance * 100)
  loco <- read_csv(file.path(pca_dir, "loco_subspace_stability.csv"), show_col_types = FALSE)
  list(continent_summary = continent_summary, pca_variance = pca_variance, loco = loco)
}
