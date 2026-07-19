# Rendering-time preparation for fixed-PCA external association diagnostics.
# Depends on figure-style.R having been sourced.

sen_slope_external <- function(year, value) {
  keep <- is.finite(year) & is.finite(value)
  year <- year[keep]
  value <- value[keep]
  if (length(value) < 3) return(NA_real_)
  pairs <- utils::combn(seq_along(value), 2)
  stats::median((value[pairs[2, ]] - value[pairs[1, ]]) /
    (year[pairs[2, ]] - year[pairs[1, ]]))
}

scalar_block_cv_r2 <- function(data, response, terms) {
  formula <- reformulate(terms, response = response)
  predicted <- rep(NA_real_, nrow(data))
  for (block in unique(data$spatial_block)) {
    train <- data$spatial_block != block
    test <- !train
    if (sum(test) < 2 || sum(train) <= length(terms) + 2) next
    fit <- lm(formula, data = data[train, , drop = FALSE])
    predicted[test] <- predict(fit, newdata = data[test, , drop = FALSE])
  }
  keep <- is.finite(predicted) & is.finite(data[[response]])
  if (sum(keep) < 3) return(NA_real_)
  1 - sum((data[[response]][keep] - predicted[keep])^2) /
    sum((data[[response]][keep] - mean(data[[response]][keep]))^2)
}

subspace_block_cv_r2 <- function(data, responses, terms) {
  formulas <- lapply(responses, \(response) reformulate(terms, response = response))
  names(formulas) <- responses
  predicted <- matrix(NA_real_, nrow(data), length(responses),
    dimnames = list(NULL, responses))
  for (block in unique(data$spatial_block)) {
    train <- data$spatial_block != block
    test <- !train
    if (sum(test) < 2 || sum(train) <= length(terms) + 2) next
    for (response in responses) {
      fit <- lm(formulas[[response]], data = data[train, , drop = FALSE])
      predicted[test, response] <- predict(fit, newdata = data[test, , drop = FALSE])
    }
  }
  observed <- as.matrix(data[, responses])
  keep <- apply(is.finite(predicted) & is.finite(observed), 1, all)
  if (sum(keep) < 3) return(NA_real_)
  observed <- observed[keep, , drop = FALSE]
  predicted <- predicted[keep, , drop = FALSE]
  total_error <- sum((observed - predicted)^2)
  total_variation <- sum(sweep(observed, 2, colMeans(observed), "-")^2)
  1 - total_error / total_variation
}

standardise_predictors <- function(data, variables) {
  data |>
    mutate(across(all_of(variables), \(x) as.numeric(scale(x))))
}

prepare_pca_external_interpretation_data <- function(
    data_dir = data, block_lon_bins = 6, block_sinlat_bins = 3) {
  pca_dir <- file.path(data_dir, "16-spatial-balanced-pca", "output", "sinlat_equalarea_72x21_mean")
  metrics_path <- file.path(
    data_dir, "06-lake-warming-metrics", "output",
    "period12_robustfalse_ni5_no0_nt99", "lake_warming_metrics.csv"
  )
  trajectory_dir <- file.path(data_dir, "14-trajectory-diagnostics", "output")

  assign_pca_cell <- function(frame) {
    sinlat_min <- sin(-60 * pi / 180)
    sinlat_max <- sin(85 * pi / 180)
    frame |>
      filter(is.finite(lat), is.finite(lon), between(lat, -60, 85)) |>
      mutate(
        lon_bin = pmin(floor((lon + 180) / 360 * 72) + 1, 72),
        sinlat_bin = pmin(floor((sin(lat * pi / 180) - sinlat_min) /
          (sinlat_max - sinlat_min) * 21) + 1, 21)
      )
  }

  cell_scores <- read_csv(file.path(pca_dir, "spatial_cell_scores.csv"), show_col_types = FALSE) |>
    select(cell_id, lon_bin, sinlat_bin, lon, lat, pc1, pc2, pc3)
  metadata <- read_csv(
    file.path(data_dir, "00-lake-metadata", "output", "lake_metadata.csv"),
    show_col_types = FALSE,
    col_select = c(lake_id, lat, lon, Lake_area, Depth_avg, Elevation)
  )
  coast <- read_csv(
    file.path(data_dir, "13-geographic-context", "output", "lake_geographic_context.csv"),
    show_col_types = FALSE,
    col_select = c(lake_id, distance_to_coast_km)
  )
  forcing <- read_csv(
    file.path(data_dir, "09-era5-forcing-summary", "output", "era5_lake_forcing_summary.csv"),
    show_col_types = FALSE,
    col_select = c(
      lake_id,
      era5_wind_speed_annual_mean, era5_wind_speed_annual_sen_slope_40yr,
      era5_wind_speed_DJF_mean, era5_wind_speed_JJA_mean,
      era5_wind_speed_DJF_sen_slope_40yr, era5_wind_speed_JJA_sen_slope_40yr,
      era5_total_precipitation_annual_mean, era5_total_precipitation_annual_sen_slope_40yr,
      era5_total_precipitation_DJF_mean, era5_total_precipitation_JJA_mean,
      era5_total_precipitation_DJF_sen_slope_40yr,
      era5_total_precipitation_JJA_sen_slope_40yr
    )
  ) |>
    mutate(
      wind_jja_minus_djf_mean = era5_wind_speed_JJA_mean - era5_wind_speed_DJF_mean,
      wind_jja_minus_djf_trend = era5_wind_speed_JJA_sen_slope_40yr -
        era5_wind_speed_DJF_sen_slope_40yr,
      precipitation_jja_minus_djf_mean = era5_total_precipitation_JJA_mean -
        era5_total_precipitation_DJF_mean,
      precipitation_jja_minus_djf_trend = era5_total_precipitation_JJA_sen_slope_40yr -
        era5_total_precipitation_DJF_sen_slope_40yr
    )
  warming <- read_csv(metrics_path, show_col_types = FALSE,
    col_select = c(lake_id, raw_annual_mean_temp_sen_slope_40yr))
  rolling_speed <- read_csv(
    file.path(trajectory_dir, "rolling_sen_speed_10yr.csv"),
    show_col_types = FALSE
  ) |>
    select(lake_id, lat, lon, matches("^X?\\d{4}$")) |>
    pivot_longer(matches("^X?\\d{4}$"), names_to = "year", values_to = "speed") |>
    mutate(year = as.integer(sub("^X", "", year)))

  cell_speed_change <- rolling_speed |>
    assign_pca_cell() |>
    group_by(lon_bin, sinlat_bin, year) |>
    summarise(speed = mean(speed, na.rm = TRUE), .groups = "drop") |>
    group_by(lon_bin, sinlat_bin) |>
    group_modify(\(frame, key) tibble(
      raw_speed_change_1e3 = sen_slope_external(frame$year, frame$speed) * 1e3
    )) |>
    ungroup()

  lake_predictors <- metadata |>
    left_join(coast, by = "lake_id") |>
    left_join(forcing, by = "lake_id") |>
    left_join(warming, by = "lake_id") |>
    mutate(
      log_lake_area = log1p(Lake_area),
      log_depth = log1p(pmax(Depth_avg, 0)),
      log_distance_to_coast = log1p(distance_to_coast_km)
    ) |>
    assign_pca_cell()

  aggregate_variables <- c(
    "log_lake_area", "log_depth", "Elevation", "log_distance_to_coast",
    "era5_wind_speed_annual_mean", "era5_wind_speed_annual_sen_slope_40yr",
    "era5_total_precipitation_annual_mean", "era5_total_precipitation_annual_sen_slope_40yr",
    "wind_jja_minus_djf_mean", "wind_jja_minus_djf_trend",
    "precipitation_jja_minus_djf_mean", "precipitation_jja_minus_djf_trend",
    "raw_annual_mean_temp_sen_slope_40yr"
  )
  cell_predictors <- lake_predictors |>
    group_by(lon_bin, sinlat_bin) |>
    summarise(
      n_lakes = n(),
      across(all_of(aggregate_variables), \(x) mean(x, na.rm = TRUE)),
      .groups = "drop"
    )

  model_data <- cell_scores |>
    inner_join(cell_predictors, by = c("lon_bin", "sinlat_bin")) |>
    inner_join(cell_speed_change, by = c("lon_bin", "sinlat_bin")) |>
    mutate(
      sin_lat = sin(lat * pi / 180),
      sin_lon = sin(lon * pi / 180),
      cos_lon = cos(lon * pi / 180),
      spatial_block = interaction(
        floor((lon_bin - 1) / block_lon_bins),
        floor((sinlat_bin - 1) / block_sinlat_bins), drop = TRUE
      )
    ) |>
    filter(if_all(c(pc1, pc2, pc3, raw_annual_mean_temp_sen_slope_40yr,
      raw_speed_change_1e3, all_of(aggregate_variables)), is.finite))

  background_terms <- c(
    "sin_lat", "I(sin_lat^2)", "sin_lon", "cos_lon", "Elevation",
    "log_lake_area", "log_depth", "log_distance_to_coast"
  )
  annual_forcing_terms <- c(
    "era5_wind_speed_annual_mean", "era5_wind_speed_annual_sen_slope_40yr",
    "era5_total_precipitation_annual_mean", "era5_total_precipitation_annual_sen_slope_40yr"
  )
  seasonal_forcing_terms <- c(
    "wind_jja_minus_djf_mean", "wind_jja_minus_djf_trend",
    "precipitation_jja_minus_djf_mean", "precipitation_jja_minus_djf_trend"
  )
  predictor_columns <- unique(c(
    setdiff(background_terms, "I(sin_lat^2)"), annual_forcing_terms, seasonal_forcing_terms
  ))
  model_data <- standardise_predictors(model_data, predictor_columns)
  model_specs <- list(
    "Geography + morphology" = background_terms,
    "+ annual wind / precipitation" = c(background_terms, annual_forcing_terms),
    "+ seasonal wind / precipitation contrast" = c(background_terms, annual_forcing_terms, seasonal_forcing_terms)
  )
  scalar_responses <- c(
    "PC1" = "pc1",
    "Raw long-term warming" = "raw_annual_mean_temp_sen_slope_40yr",
    "Raw warming-speed change" = "raw_speed_change_1e3"
  )
  scalar_results <- bind_rows(lapply(names(scalar_responses), \(label) {
    response_column <- scalar_responses[[label]]
    bind_rows(lapply(names(model_specs), \(model) tibble(
      outcome = label,
      model = model,
      spatial_block_cv_r2 = scalar_block_cv_r2(model_data, response_column, model_specs[[model]])
    )))
  }))
  subspace_results <- bind_rows(lapply(names(model_specs), \(model) tibble(
    outcome = "PC2--PC3 joint subspace",
    model = model,
    spatial_block_cv_r2 = subspace_block_cv_r2(model_data, c("pc2", "pc3"), model_specs[[model]])
  )))

  list(
    model_data = model_data,
    cv_results = bind_rows(scalar_results, subspace_results) |>
      mutate(model = factor(model, levels = names(model_specs))),
    model_specs = model_specs,
    contract = tibble(
      family = c("Geography / morphology", "Annual forcing", "Seasonal forcing contrast"),
      variables = c(
        paste(background_terms, collapse = ", "),
        paste(annual_forcing_terms, collapse = ", "),
        paste(seasonal_forcing_terms, collapse = ", ")
      )
    ),
    qc = list(
      n_cells = nrow(model_data), n_blocks = n_distinct(model_data$spatial_block),
      block_lon_bins = block_lon_bins, block_sinlat_bins = block_sinlat_bins
    )
  )
}

prepare_pca_external_interpretation_sensitivity <- function(data_dir = data) {
  settings <- tibble(
    block_lon_bins = c(4, 6, 8),
    block_sinlat_bins = c(3, 3, 3),
    block_label = c("4 × 3 bins", "6 × 3 bins", "8 × 3 bins")
  )
  results <- bind_rows(lapply(seq_len(nrow(settings)), \(i) {
    payload <- prepare_pca_external_interpretation_data(
      data_dir = data_dir,
      block_lon_bins = settings$block_lon_bins[[i]],
      block_sinlat_bins = settings$block_sinlat_bins[[i]]
    )
    payload$cv_results |>
      mutate(block_label = settings$block_label[[i]], n_blocks = payload$qc$n_blocks)
  })) |>
    mutate(block_label = factor(block_label, levels = settings$block_label))
  list(cv_results = results, settings = settings)
}
