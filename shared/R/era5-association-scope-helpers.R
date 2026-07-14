# Rendering-time preparation for constrained ERA5 association diagnostics.

spatial_block_cv_r2 <- function(data, response, terms) {
  formula <- reformulate(terms, response = response)
  folds <- unique(data$spatial_block)
  predictions <- rep(NA_real_, nrow(data))
  for (fold in folds) {
    train <- data$spatial_block != fold
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

prepare_era5_association_data <- function(data_dir = data) {
  pca_dir <- file.path(data_dir, "07-warming-response-clustering", "output",
    "stl_trend_period12_robustfalse_ni5_no0_nt99_baseline1981_1990_pc5_k4-8")
  scores <- read_csv(file.path(pca_dir, "pca_scores.csv"), show_col_types = FALSE)
  metadata <- read_csv(file.path(data_dir, "00-lake-metadata", "output", "lake_metadata.csv"), show_col_types = FALSE)
  forcing <- read_csv(file.path(data_dir, "09-era5-forcing-summary", "output", "era5_lake_forcing_summary.csv"), show_col_types = FALSE)
  era_terms <- c(
    "era5_wind_speed_annual_mean", "era5_wind_speed_annual_sen_slope_40yr",
    "era5_surface_pressure_annual_mean", "era5_surface_pressure_annual_sen_slope_40yr",
    "era5_total_precipitation_annual_mean", "era5_total_precipitation_annual_sen_slope_40yr"
  )
  model_data <- scores |>
    left_join(metadata |> select(lake_id, Elevation), by = "lake_id") |>
    left_join(forcing |> select(lake_id, all_of(era_terms)), by = "lake_id") |>
    transmute(
      lake_id, lon, lat, pc1, pc2, pc3,
      abs_lat = abs(lat), elevation = Elevation,
      across(all_of(era_terms)),
      spatial_block = interaction(floor((lon + 180) / 20), floor((lat + 60) / 20), drop = TRUE)
    ) |>
    filter(if_all(c(pc1, pc2, pc3, abs_lat, elevation, all_of(era_terms)), is.finite))
  geography_terms <- c("abs_lat", "I(abs_lat^2)", "elevation", "lon", "I(lon^2)")
  cv_results <- bind_rows(lapply(c("pc1", "pc2", "pc3"), function(response) {
    tibble(
      pc = toupper(response),
      model = c("Geography only", "Geography + available ERA5"),
      spatial_block_cv_r2 = c(
        spatial_block_cv_r2(model_data, response, geography_terms),
        spatial_block_cv_r2(model_data, response, c(geography_terms, era_terms))
      )
    )
  }))
  rank_associations <- bind_rows(lapply(c("pc1", "pc2", "pc3"), function(response) {
    tibble(
      pc = toupper(response),
      predictor = era_terms,
      spearman_rho = vapply(era_terms, \(term) cor(model_data[[response]], model_data[[term]], method = "spearman"), numeric(1))
    )
  }))
  list(model_data = model_data, cv_results = cv_results, rank_associations = rank_associations)
}
