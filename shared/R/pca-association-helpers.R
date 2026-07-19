# Rendering-time preparation for exploratory cell-level PCA associations.
# Depends on figure-style.R having been sourced.

spatial_block_cv_r2 <- function(data, response, terms) {
  formula <- reformulate(terms, response = response)
  predictions <- rep(NA_real_, nrow(data))
  for (block in unique(data$spatial_block)) {
    train <- data$spatial_block != block
    test <- !train
    if (sum(test) < 2 || sum(train) <= length(terms) + 2) next
    fit <- lm(formula, data = data[train, , drop = FALSE])
    predictions[test] <- predict(fit, newdata = data[test, , drop = FALSE])
  }
  valid <- is.finite(predictions) & is.finite(data[[response]])
  if (sum(valid) < 3) return(NA_real_)
  1 - sum((data[[response]][valid] - predictions[valid])^2) /
    sum((data[[response]][valid] - mean(data[[response]][valid]))^2)
}

prepare_pca_association_data <- function(data_dir = data, block_lon_bins = 6, block_sinlat_bins = 3) {
  pca_dir <- file.path(data_dir, "16-spatial-balanced-pca", "output", "sinlat_equalarea_72x21_mean")
  cell_scores <- read_csv(file.path(pca_dir, "spatial_cell_scores.csv"), show_col_types = FALSE) |>
    select(cell_id, lon_bin, sinlat_bin, lon, lat, all_of(paste0("pc", 1:5)))
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
      era5_total_precipitation_annual_mean, era5_total_precipitation_annual_sen_slope_40yr
    )
  )

  assign_pca_cell <- function(data) {
    sinlat_min <- sin(-60 * pi / 180)
    sinlat_max <- sin(85 * pi / 180)
    data |>
      filter(is.finite(lat), is.finite(lon), between(lat, -60, 85)) |>
      mutate(
        lon_bin = pmin(floor((lon + 180) / 360 * 72) + 1, 72),
        sinlat_bin = pmin(floor((sin(lat * pi / 180) - sinlat_min) / (sinlat_max - sinlat_min) * 21) + 1, 21)
      )
  }

  cell_predictors <- metadata |>
    left_join(coast, by = "lake_id") |>
    left_join(forcing, by = "lake_id") |>
    mutate(
      log_lake_area = log1p(Lake_area),
      log_depth = log1p(pmax(Depth_avg, 0)),
      log_distance_to_coast = log1p(distance_to_coast_km)
    ) |>
    assign_pca_cell() |>
    group_by(lon_bin, sinlat_bin) |>
    summarise(
      n_lakes_predictors = n(),
      across(
        c(log_lake_area, log_depth, Elevation, log_distance_to_coast,
          era5_wind_speed_annual_mean, era5_wind_speed_annual_sen_slope_40yr,
          era5_total_precipitation_annual_mean, era5_total_precipitation_annual_sen_slope_40yr),
        ~ mean(.x, na.rm = TRUE)
      ),
      .groups = "drop"
    )

  model_data <- cell_scores |>
    inner_join(cell_predictors, by = c("lon_bin", "sinlat_bin")) |>
    mutate(
      sin_lat = sin(lat * pi / 180),
      sin_lon = sin(lon * pi / 180),
      cos_lon = cos(lon * pi / 180),
      spatial_block = interaction(
        floor((lon_bin - 1) / block_lon_bins),
        floor((sinlat_bin - 1) / block_sinlat_bins), drop = TRUE
      )
    ) |>
    filter(if_all(
      c(pc1, pc2, pc3, sin_lat, sin_lon, cos_lon, log_lake_area, log_depth,
        Elevation, log_distance_to_coast, era5_wind_speed_annual_mean,
        era5_wind_speed_annual_sen_slope_40yr, era5_total_precipitation_annual_mean,
        era5_total_precipitation_annual_sen_slope_40yr),
      is.finite
    ))

  background_terms <- c(
    "sin_lat", "I(sin_lat^2)", "sin_lon", "cos_lon", "Elevation",
    "log_lake_area", "log_depth", "log_distance_to_coast"
  )
  era5_terms <- c(
    "era5_wind_speed_annual_mean", "era5_wind_speed_annual_sen_slope_40yr",
    "era5_total_precipitation_annual_mean", "era5_total_precipitation_annual_sen_slope_40yr"
  )
  cv_results <- bind_rows(lapply(paste0("pc", 1:3), \(response) {
    tibble(
      component = toupper(response),
      model = c("Background", "Background + ERA5"),
      spatial_block_cv_r2 = c(
        spatial_block_cv_r2(model_data, response, background_terms),
        spatial_block_cv_r2(model_data, response, c(background_terms, era5_terms))
      )
    )
  }))

  list(
    model_data = model_data,
    cv_results = cv_results,
    background_terms = background_terms,
    era5_terms = era5_terms,
    qc = list(
      n_cells = nrow(model_data), n_blocks = n_distinct(model_data$spatial_block),
      block_lon_bins = block_lon_bins, block_sinlat_bins = block_sinlat_bins
    )
  )
}

prepare_pca_association_sensitivity_data <- function(data_dir = data) {
  settings <- tibble(
    block_lon_bins = c(4, 6, 8),
    block_sinlat_bins = c(3, 3, 3),
    block_label = c("4 × 3 bins", "6 × 3 bins", "8 × 3 bins")
  )
  cv_block_sensitivity <- bind_rows(lapply(seq_len(nrow(settings)), \(i) {
    payload <- prepare_pca_association_data(
      data_dir = data_dir,
      block_lon_bins = settings$block_lon_bins[[i]],
      block_sinlat_bins = settings$block_sinlat_bins[[i]]
    )
    payload$cv_results |>
      mutate(
        block_label = settings$block_label[[i]],
        n_blocks = payload$qc$n_blocks
      )
  })) |>
    mutate(block_label = factor(block_label, levels = settings$block_label))
  list(cv_block_sensitivity = cv_block_sensitivity, settings = settings)
}
