# Rendering-time preparation for Step 18 descriptive lag-surface figures.
# Depends on figure-style.R having been sourced.

prepare_pca_seasonal_lag_surface <- function(data_dir = data) {
  surface <- read_csv(file.path(data_dir, "18-seasonal-teleconnection-lag-surface",
    "output", "cell_seasonal_teleconnection_lag_surface.csv"), show_col_types = FALSE) |>
    filter(is.finite(r), n_pairs >= 30)
  seasonal <- surface |>
    filter(lag_unit == "quarters") |>
    group_by(response_series, index, lag) |>
    summarise(
      n_cells = n(), median_r = median(r), median_abs_r = median(abs(r)),
      association_sd = sd(r), .groups = "drop"
    ) |>
    mutate(
      response_series = factor(response_series, levels = c("DJF", "MAM", "JJA", "SON")),
      index = factor(index, levels = c("NAO", "AO", "PDO", "Nino34")),
      lag_label = factor(lag, levels = 0:12)
    )
  annual <- surface |>
    filter(lag_unit == "years") |>
    group_by(predictor_season, index, lag) |>
    summarise(
      n_cells = n(), median_r = median(r), median_abs_r = median(abs(r)),
      association_sd = sd(r), .groups = "drop"
    ) |>
    mutate(
      predictor_season = factor(predictor_season, levels = c("DJF", "MAM", "JJA", "SON")),
      index = factor(index, levels = c("NAO", "AO", "PDO", "Nino34")),
      lag_label = factor(lag, levels = 0:3)
    )
  best_lag <- surface |>
    filter(lag_unit == "quarters") |>
    group_by(index, response_series, lon_bin, sinlat_bin) |>
    slice_max(abs(r), n = 1, with_ties = FALSE) |>
    ungroup() |>
    mutate(
      lon_min = -180 + (lon_bin - 1) * 360 / 72,
      lon_max = -180 + lon_bin * 360 / 72,
      sinlat_min = sin(-60 * pi / 180) + (sinlat_bin - 1) *
        (sin(85 * pi / 180) - sin(-60 * pi / 180)) / 21,
      sinlat_max = sin(-60 * pi / 180) + sinlat_bin *
        (sin(85 * pi / 180) - sin(-60 * pi / 180)) / 21,
      lat_min = asin(sinlat_min) * 180 / pi,
      lat_max = asin(sinlat_max) * 180 / pi,
      response_series = factor(response_series, levels = c("DJF", "MAM", "JJA", "SON")),
      index = factor(index, levels = c("NAO", "AO", "PDO", "Nino34")),
      best_lag = factor(lag, levels = 0:12),
      max_abs_r = abs(r)
    )
  list(seasonal_heatmap = seasonal, annual_heatmap = annual, best_lag = best_lag)
}
