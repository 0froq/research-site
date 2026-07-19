# Rendering-time preparation for the seasonal PCA--teleconnection sensitivity screen.
# Depends on figure-style.R having been sourced.

seasonal_tele_spatial_block_cv_r2 <- function(data, response, terms) {
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

prepare_pca_seasonal_teleconnection_data <- function(
    data_dir = data, grid = "sinlat_equalarea_72x21_mean",
    n_lon = 72, n_lat = 21, block_lon_bins = 6, block_sinlat_bins = 3,
    screen = tidyr::crossing(
      response_season = c("DJF", "MAM", "JJA", "SON"),
      index = c("NAO", "AO", "Nino34", "PDO"), lag_years = 0:1
    ), omitted_continent = NULL,
    correlation_path = file.path(data_dir, "17-seasonal-teleconnection-association", "output", "lake_seasonal_teleconnection_correlations.csv"),
    prefix_fun = function(season, index, lag) paste0("tele_", season, "_", index, "_lag", lag),
    min_pairs = 30, metadata_data = NULL, coast_data = NULL,
    correlations_data = NULL) {
  pca_dir <- file.path(data_dir, "16-spatial-balanced-pca", "output", grid)
  assign_cell <- function(frame) {
    sinlat_min <- sin(-60 * pi / 180)
    sinlat_max <- sin(85 * pi / 180)
    frame |>
      filter(is.finite(lat), is.finite(lon), between(lat, -60, 85)) |>
      mutate(
        lon_bin = pmin(floor((lon + 180) / 360 * n_lon) + 1, n_lon),
        sinlat_bin = pmin(floor((sin(lat * pi / 180) - sinlat_min) /
          (sinlat_max - sinlat_min) * n_lat) + 1, n_lat)
      )
  }
  cell_scores <- if (is.null(omitted_continent)) {
    read_csv(file.path(pca_dir, "spatial_cell_scores.csv"), show_col_types = FALSE) |>
      select(cell_id, lon_bin, sinlat_bin, lon, lat, pc1, pc2, pc3)
  } else {
    read_csv(file.path(pca_dir, "loco_refit_cell_scores.csv"), show_col_types = FALSE) |>
      filter(.data$omitted_continent == .env$omitted_continent) |>
      select(cell_id, lon_bin, sinlat_bin, lon, lat, pc1, pc2, pc3)
  }
  metadata <- if (is.null(metadata_data)) read_csv(
    file.path(data_dir, "00-lake-metadata", "output", "lake_metadata.csv"),
    show_col_types = FALSE,
    col_select = c(lake_id, lat, lon, Continent, Lake_area, Depth_avg, Elevation,
      Res_time, Dis_avg, Wshd_area, Vol_total, Shore_dev, Slope_100, is_reservoir)
  ) else metadata_data
  coast <- if (is.null(coast_data)) read_csv(
    file.path(data_dir, "13-geographic-context", "output", "lake_geographic_context.csv"),
    show_col_types = FALSE, col_select = c(lake_id, distance_to_coast_km)
  ) else coast_data
  correlations <- if (is.null(correlations_data)) {
    read_csv(correlation_path, show_col_types = FALSE)
  } else correlations_data
  included_metadata <- if (is.null(omitted_continent)) metadata else filter(metadata, Continent != .env$omitted_continent)
  cell_background <- included_metadata |>
    left_join(coast, by = "lake_id") |>
    mutate(
      log_lake_area = log1p(Lake_area),
      log_depth = log1p(pmax(Depth_avg, 0)),
      log_distance_to_coast = log1p(distance_to_coast_km),
      log_residence_time = if_else(Res_time > 0, log1p(Res_time), NA_real_),
      log_discharge = if_else(Dis_avg >= 0, log1p(Dis_avg), NA_real_),
      log_watershed_area = if_else(Wshd_area > 0, log1p(Wshd_area), NA_real_),
      log_volume = if_else(Vol_total > 0, log1p(Vol_total), NA_real_),
      shoreline_development = if_else(Shore_dev > 0, Shore_dev, NA_real_),
      local_slope = if_else(Slope_100 >= 0, Slope_100, NA_real_),
      reservoir_fraction = as.numeric(is_reservoir)
    ) |>
    assign_cell() |>
    group_by(lon_bin, sinlat_bin) |>
    summarise(
      n_lakes_background = n(),
      across(c(log_lake_area, log_depth, Elevation, log_distance_to_coast,
        log_residence_time, log_discharge, log_watershed_area, log_volume,
        shoreline_development, local_slope, reservoir_fraction),
        \(x) mean(x, na.rm = TRUE)),
      .groups = "drop"
    )
  tele_long <- bind_rows(lapply(seq_len(nrow(screen)), \(i) {
    season <- screen$response_season[[i]]
    index <- screen$index[[i]]
    lag <- screen$lag_years[[i]]
    prefix <- prefix_fun(season, index, lag)
    correlations |>
      transmute(
        lake_id, lat, lon, response_season = season, index = index, lag_years = lag,
        n_pairs = .data[[paste0(prefix, "_n")]],
        r = .data[[paste0(prefix, "_r")]]
      )
  })) |>
    left_join(metadata |> select(lake_id, Continent), by = "lake_id")
  if (!is.null(omitted_continent)) {
    tele_long <- tele_long |> filter(Continent != .env$omitted_continent)
  }
  cell_sensitivity <- tele_long |>
    filter(is.finite(r), n_pairs >= min_pairs, abs(r) < 1) |>
    mutate(
      fisher_z = atanh(pmax(pmin(r, 0.999999), -0.999999)),
      fisher_weight = pmax(n_pairs - 3, 1)
    ) |>
    assign_cell() |>
    group_by(response_season, index, lag_years, lon_bin, sinlat_bin) |>
    summarise(
      tele_fisher_z = weighted.mean(fisher_z, fisher_weight, na.rm = TRUE),
      n_lakes_tele = n(), .groups = "drop"
    )
  model_data <- cell_sensitivity |>
    inner_join(cell_scores, by = c("lon_bin", "sinlat_bin")) |>
    inner_join(cell_background, by = c("lon_bin", "sinlat_bin")) |>
    mutate(
      sin_lat = sin(lat * pi / 180),
      sin_lon = sin(lon * pi / 180),
      cos_lon = cos(lon * pi / 180),
      spatial_block = interaction(
        floor((lon_bin - 1) / block_lon_bins),
        floor((sinlat_bin - 1) / block_sinlat_bins), drop = TRUE
      )
    ) |>
    filter(if_all(c(tele_fisher_z, pc1, pc2, pc3, sin_lat, sin_lon, cos_lon,
      log_lake_area, log_depth, Elevation, log_distance_to_coast), is.finite)) |>
    mutate(across(c(log_lake_area, log_depth, Elevation, log_distance_to_coast),
      \(x) as.numeric(scale(x))))
  background_terms <- c(
    "sin_lat", "I(sin_lat^2)", "sin_lon", "cos_lon", "Elevation",
    "log_lake_area", "log_depth", "log_distance_to_coast"
  )
  models <- list(
    "Geography + morphology" = background_terms,
    "+ PC1" = c(background_terms, "pc1"),
    "+ PC2" = c(background_terms, "pc2"),
    "+ PC3" = c(background_terms, "pc3"),
    "+ PC1 + PC2" = c(background_terms, "pc1", "pc2"),
    "+ PC1 + PC3" = c(background_terms, "pc1", "pc3"),
    "+ PC2--PC3 subspace" = c(background_terms, "pc2", "pc3"),
    "+ PC1 + PC2--PC3 subspace" = c(background_terms, "pc1", "pc2", "pc3")
  )
  cv_results <- model_data |>
    group_by(response_season, index, lag_years) |>
    group_modify(\(frame, key) bind_rows(lapply(names(models), \(model) tibble(
      model = model,
      spatial_block_cv_r2 = seasonal_tele_spatial_block_cv_r2(frame, "tele_fisher_z", models[[model]]),
      n_cells = nrow(frame),
      n_lakes_median = median(frame$n_lakes_tele),
      sensitivity_sd = sd(frame$tele_fisher_z)
    )))) |>
    ungroup() |>
    mutate(model = factor(model, levels = names(models)))
  lake_context_terms <- c(
    "log_residence_time", "log_discharge", "log_watershed_area", "log_volume",
    "shoreline_development", "local_slope", "reservoir_fraction"
  )
  context_models <- list(
    "Geography + core lake" = background_terms,
    "+ PC1" = c(background_terms, "pc1"),
    "+ PC2--PC3 subspace" = c(background_terms, "pc2", "pc3"),
    "Geography + expanded lake context" = c(background_terms, lake_context_terms),
    "+ PC1 after context" = c(background_terms, lake_context_terms, "pc1"),
    "+ PC2--PC3 after context" = c(background_terms, lake_context_terms, "pc2", "pc3"),
    "+ all PCs after context" = c(background_terms, lake_context_terms, "pc1", "pc2", "pc3")
  )
  context_model_data <- model_data |>
    filter(if_all(all_of(lake_context_terms), is.finite))
  context_cv_results <- context_model_data |>
    group_by(response_season, index, lag_years) |>
    group_modify(\(frame, key) bind_rows(lapply(names(context_models), \(model) tibble(
      model = model,
      spatial_block_cv_r2 = seasonal_tele_spatial_block_cv_r2(
        frame, "tele_fisher_z", context_models[[model]]),
      n_cells = nrow(frame),
      n_lakes_median = median(frame$n_lakes_tele),
      sensitivity_sd = sd(frame$tele_fisher_z)
    )))) |>
    ungroup() |>
    mutate(model = factor(model, levels = names(context_models)))
  list(
    model_data = model_data, cv_results = cv_results,
    context_model_data = context_model_data,
    context_cv_results = context_cv_results,
    screen = screen
  )
}

prepare_pca_seasonal_teleconnection_screen <- function(data_dir = data) {
  prepare_pca_seasonal_teleconnection_data(data_dir = data)$cv_results
}

prepare_pca_seasonal_teleconnection_decade_loco <- function(data_dir = data, shared_inputs = list()) {
  path <- file.path(data_dir, "17-seasonal-teleconnection-association", "output",
    "lake_JJA_NAO_AO_lag1_leave_decade_out.csv")
  decades <- tibble(
    omitted_decade = c("1981–1990", "1991–2000", "2001–2010", "2011–2020"),
    first_year = c(1981L, 1991L, 2001L, 2011L),
    last_year = c(1990L, 2000L, 2010L, 2020L)
  )
  screen <- tibble(response_season = "JJA", index = c("NAO", "AO"), lag_years = 1L)
  payloads <- lapply(seq_len(nrow(decades)), \(i) {
    first_year <- decades$first_year[[i]]
    last_year <- decades$last_year[[i]]
    payload <- do.call(prepare_pca_seasonal_teleconnection_data, c(list(
      data_dir = data_dir, screen = screen,
      correlation_path = path,
      prefix_fun = function(season, index, lag) {
        paste0("tele_", season, "_", index, "_lag", lag,
          "_omit", first_year, "_", last_year)
      },
      min_pairs = 28
    ), shared_inputs))
    list(
      cv_results = payload$cv_results |> mutate(omitted_decade = decades$omitted_decade[[i]]),
      context_cv_results = payload$context_cv_results |>
        mutate(omitted_decade = decades$omitted_decade[[i]]),
      field_data = payload$model_data |>
        select(response_season, index, lag_years, lon_bin, sinlat_bin, tele_fisher_z) |>
        mutate(omitted_decade = decades$omitted_decade[[i]])
    )
  })
  cv_results <- bind_rows(lapply(payloads, `[[`, "cv_results")) |>
    mutate(omitted_decade = factor(omitted_decade, levels = decades$omitted_decade))
  context_cv_results <- bind_rows(lapply(payloads, `[[`, "context_cv_results")) |>
    mutate(omitted_decade = factor(omitted_decade, levels = decades$omitted_decade))
  field_data <- bind_rows(lapply(payloads, `[[`, "field_data")) |>
    mutate(omitted_decade = factor(omitted_decade, levels = decades$omitted_decade))
  list(
    cv_results = cv_results, context_cv_results = context_cv_results,
    field_data = field_data, screen = screen, decades = decades
  )
}

prepare_pca_seasonal_teleconnection_grid_sensitivity <- function(data_dir = data, screen, shared_inputs = list()) {
  grids <- tibble(
    grid = c("sinlat_equalarea_36x11_mean", "sinlat_equalarea_72x21_mean", "sinlat_equalarea_144x42_mean"),
    n_lon = c(36, 72, 144), n_lat = c(11, 21, 42),
    block_lon_bins = c(3, 6, 12), block_sinlat_bins = c(2, 3, 6),
    grid_label = c("36 × 11", "72 × 21", "144 × 42")
  )
  payloads <- lapply(seq_len(nrow(grids)), \(i) {
    payload <- do.call(prepare_pca_seasonal_teleconnection_data, c(list(
      data_dir = data_dir, grid = grids$grid[[i]],
      n_lon = grids$n_lon[[i]], n_lat = grids$n_lat[[i]],
      block_lon_bins = grids$block_lon_bins[[i]],
      block_sinlat_bins = grids$block_sinlat_bins[[i]], screen = screen
    ), shared_inputs))
    list(
      cv_results = payload$cv_results |> mutate(grid_label = grids$grid_label[[i]]),
      context_cv_results = payload$context_cv_results |>
        mutate(grid_label = grids$grid_label[[i]])
    )
  })
  cv_results <- bind_rows(lapply(payloads, `[[`, "cv_results")) |>
    mutate(grid_label = factor(grid_label, levels = grids$grid_label))
  context_cv_results <- bind_rows(lapply(payloads, `[[`, "context_cv_results")) |>
    mutate(grid_label = factor(grid_label, levels = grids$grid_label))
  list(cv_results = cv_results, context_cv_results = context_cv_results, screen = screen)
}

prepare_pca_seasonal_teleconnection_loco_sensitivity <- function(data_dir = data, screen, shared_inputs = list()) {
  pca_dir <- file.path(data_dir, "16-spatial-balanced-pca", "output", "sinlat_equalarea_72x21_mean")
  continents <- read_csv(file.path(pca_dir, "loco_refit_cell_scores.csv"), show_col_types = FALSE) |>
    distinct(omitted_continent) |>
    pull(omitted_continent)
  payloads <- lapply(continents, \(continent) {
    payload <- do.call(prepare_pca_seasonal_teleconnection_data, c(list(
      data_dir = data_dir, screen = screen, omitted_continent = continent
    ), shared_inputs))
    list(
      cv_results = payload$cv_results |> mutate(omitted_continent = continent),
      context_cv_results = payload$context_cv_results |>
        mutate(omitted_continent = continent)
    )
  })
  list(
    cv_results = bind_rows(lapply(payloads, `[[`, "cv_results")),
    context_cv_results = bind_rows(lapply(payloads, `[[`, "context_cv_results")),
    screen = screen
  )
}

prepare_seasonal_sensitivity_trajectory_composites <- function(
    data_dir = data, response_season = "JJA", index = "NAO", lag_years = 1L,
    shared_inputs = list()) {
  screen <- tibble(response_season = response_season, index = index, lag_years = lag_years)
  payload <- do.call(prepare_pca_seasonal_teleconnection_data,
    c(list(data_dir = data_dir, screen = screen), shared_inputs))
  memberships <- payload$model_data |>
    filter(response_season == .env$response_season, index == .env$index, lag_years == .env$lag_years)
  sensitivity_breaks <- quantile(memberships$tele_fisher_z, c(.2, .8), na.rm = TRUE)
  memberships <- memberships |>
    mutate(sensitivity_pole = case_when(
      tele_fisher_z <= sensitivity_breaks[[1]] ~ "Lower-sensitivity pole",
      tele_fisher_z >= sensitivity_breaks[[2]] ~ "Higher-sensitivity pole",
      .default = NA_character_
    )) |>
    filter(!is.na(sensitivity_pole)) |>
    select(lon_bin, sinlat_bin, sensitivity_pole, tele_fisher_z, pc1, pc2, pc3)

  assign_cell <- function(frame) {
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
  aggregate_cell_anomalies <- function(path, representation) {
    wide <- read_csv(path, show_col_types = FALSE)
    year_cols <- names(wide)[4:ncol(wide)]
    baseline_cols <- intersect(year_cols, as.character(1981:1990))
    length(baseline_cols) == 10 || stop("Expected 1981–1990 baseline columns: ", path)
    baseline <- rowMeans(as.matrix(wide[, baseline_cols]), na.rm = TRUE)
    wide |>
      mutate(.baseline = baseline) |>
      mutate(across(all_of(year_cols), ~ .x - .baseline)) |>
      select(-.baseline) |>
      assign_cell() |>
      group_by(lon_bin, sinlat_bin) |>
      summarise(across(all_of(year_cols), \(x) mean(x, na.rm = TRUE)), .groups = "drop") |>
      pivot_longer(all_of(year_cols), names_to = "year", values_to = "anomaly") |>
      mutate(year = as.integer(year), representation = representation)
  }
  trajectories <- bind_rows(
    aggregate_cell_anomalies(
      file.path(data_dir, "02-annual-temperature", "output", "annual_mean_temperature.csv"),
      "Raw annual LSWT"
    ),
    aggregate_cell_anomalies(
      file.path(data_dir, "02-annual-temperature", "output", paste0(response_season, "_temperature.csv")),
      paste0("Raw ", response_season, " LSWT")
    )
  ) |>
    inner_join(memberships, by = c("lon_bin", "sinlat_bin")) |>
    group_by(representation, sensitivity_pole, year) |>
    summarise(
      anomaly_mean = mean(anomaly, na.rm = TRUE),
      anomaly_q25 = quantile(anomaly, .25, na.rm = TRUE),
      anomaly_q75 = quantile(anomaly, .75, na.rm = TRUE),
      n_cells = n(), .groups = "drop"
    ) |>
    mutate(
      sensitivity_pole = factor(sensitivity_pole,
        levels = c("Lower-sensitivity pole", "Higher-sensitivity pole"))
    )
  score_summary <- memberships |>
    group_by(sensitivity_pole) |>
    summarise(
      n_cells = n(),
      median_fisher_z = median(tele_fisher_z),
      across(c(pc1, pc2, pc3), median),
      .groups = "drop"
    )
  list(
    trajectories = trajectories,
    score_summary = score_summary,
    memberships = memberships,
    sensitivity_map = payload$model_data |>
      filter(response_season == .env$response_season, index == .env$index, lag_years == .env$lag_years)
  )
}

prepare_pca_seasonal_teleconnection_display <- function(data_dir = data) {
  candidates <- tibble(
    response_season = c("JJA", "JJA", "JJA"),
    index = c("NAO", "AO", "PDO"), lag_years = c(1L, 1L, 0L)
  )
  screen_results <- prepare_pca_seasonal_teleconnection_screen(data_dir = data_dir)
  grid_results <- prepare_pca_seasonal_teleconnection_grid_sensitivity(
    data_dir = data_dir, screen = candidates
  )$cv_results
  loco_results <- prepare_pca_seasonal_teleconnection_loco_sensitivity(
    data_dir = data_dir, screen = candidates
  )$cv_results
  map_data <- prepare_pca_seasonal_teleconnection_data(
    data_dir = data_dir,
    screen = filter(candidates, index %in% c("NAO", "AO"))
  )$model_data |>
    mutate(index = factor(index, levels = c("NAO", "AO")))
  make_increment <- function(frame, grouping) {
    frame |>
      select(all_of(grouping), model, spatial_block_cv_r2) |>
      tidyr::pivot_wider(names_from = model, values_from = spatial_block_cv_r2) |>
      transmute(
        across(all_of(grouping)),
        pc1_increment = `+ PC1` - `Geography + morphology`,
        pc23_increment = `+ PC2--PC3 subspace` - `Geography + morphology`
      ) |>
      tidyr::pivot_longer(c(pc1_increment, pc23_increment),
        names_to = "addition", values_to = "heldout_r2_increment") |>
      mutate(addition = recode(addition,
        pc1_increment = "+ PC1", pc23_increment = "+ PC2--PC3 subspace"
      ))
  }
  list(
    screen_increment = make_increment(screen_results,
      c("response_season", "index", "lag_years")),
    grid_increment = make_increment(grid_results,
      c("response_season", "index", "lag_years", "grid_label")),
    loco_increment = make_increment(loco_results,
      c("response_season", "index", "lag_years", "omitted_continent")),
    map_data = map_data,
    nao_composite = prepare_seasonal_sensitivity_trajectory_composites(
      data_dir = data_dir, index = "NAO"
    ),
    ao_composite = prepare_seasonal_sensitivity_trajectory_composites(
      data_dir = data_dir, index = "AO"
    )
  )
}

# Prepared objects for the retained JJA NAO/AO lag-1 discovery result.
# All transformations that define a figure live here; the qmd only composes plots.
prepare_pca_jja_teleconnection_display <- function(data_dir = data) {
  screen <- tibble(
    response_season = "JJA",
    index = c("NAO", "AO"),
    lag_years = 1L
  )
  block_layouts <- tibble(
    block_lon_bins = c(4, 6, 8),
    block_sinlat_bins = c(3, 3, 3),
    block_label = c("4 × 3 bins", "6 × 3 bins", "8 × 3 bins")
  )
  metadata_data <- read_csv(
    file.path(data_dir, "00-lake-metadata", "output", "lake_metadata.csv"),
    show_col_types = FALSE,
    col_select = c(lake_id, lat, lon, Continent, Lake_area, Depth_avg, Elevation,
      Res_time, Dis_avg, Wshd_area, Vol_total, Shore_dev, Slope_100, is_reservoir)
  )
  coast_data <- read_csv(
    file.path(data_dir, "13-geographic-context", "output", "lake_geographic_context.csv"),
    show_col_types = FALSE, col_select = c(lake_id, distance_to_coast_km)
  )
  main_shared_inputs <- list(
    metadata_data = metadata_data, coast_data = coast_data,
    correlations_data = read_csv(file.path(data_dir,
      "17-seasonal-teleconnection-association", "output",
      "lake_seasonal_teleconnection_correlations.csv"), show_col_types = FALSE)
  )
  target <- do.call(prepare_pca_seasonal_teleconnection_data,
    c(list(data_dir = data_dir, screen = screen), main_shared_inputs))
  model_payloads <- lapply(seq_len(nrow(block_layouts)), \(i) {
    payload <- do.call(prepare_pca_seasonal_teleconnection_data, c(list(
      data_dir = data_dir, screen = screen,
      block_lon_bins = block_layouts$block_lon_bins[[i]],
      block_sinlat_bins = block_layouts$block_sinlat_bins[[i]]
    ), main_shared_inputs))
    list(
      model_comparison = payload$cv_results |> mutate(block_label = block_layouts$block_label[[i]]),
      context_model_comparison = payload$context_cv_results |>
        mutate(block_label = block_layouts$block_label[[i]])
    )
  })
  model_comparison <- bind_rows(lapply(model_payloads, `[[`, "model_comparison")) |>
    mutate(
      model = factor(model, levels = levels(model)),
      block_label = factor(block_label, levels = block_layouts$block_label),
      index = factor(index, levels = c("NAO", "AO"))
    )
  context_model_comparison <- bind_rows(lapply(model_payloads, `[[`, "context_model_comparison")) |>
    mutate(
      model = factor(model, levels = levels(model)),
      block_label = factor(block_label, levels = block_layouts$block_label),
      index = factor(index, levels = c("NAO", "AO"))
    )

  increment_for_subspace <- function(frame, grouping) {
    frame |>
      filter(model %in% c("Geography + morphology", "+ PC2--PC3 subspace")) |>
      select(all_of(grouping), model, spatial_block_cv_r2) |>
      pivot_wider(names_from = model, values_from = spatial_block_cv_r2) |>
      transmute(
        across(all_of(grouping)),
        pc23_increment = `+ PC2--PC3 subspace` - `Geography + morphology`
      )
  }
  grid_payload <- prepare_pca_seasonal_teleconnection_grid_sensitivity(
    data_dir = data_dir, screen = screen, shared_inputs = main_shared_inputs
  )
  grid_increment <- grid_payload$cv_results |>
    increment_for_subspace(c("index", "grid_label")) |>
    transmute(index, validation = "Equal-area grid", label = grid_label,
      pc23_increment)
  loco_payload <- prepare_pca_seasonal_teleconnection_loco_sensitivity(
    data_dir = data_dir, screen = screen, shared_inputs = main_shared_inputs
  )
  loco_increment <- loco_payload$cv_results |>
    increment_for_subspace(c("index", "omitted_continent")) |>
    transmute(index, validation = "LOCO refit", label = omitted_continent,
      pc23_increment)

  context_increment_for_subspace <- function(frame, grouping) {
    frame |>
      filter(model %in% c("Geography + expanded lake context", "+ PC2--PC3 after context")) |>
      select(all_of(grouping), model, spatial_block_cv_r2) |>
      pivot_wider(names_from = model, values_from = spatial_block_cv_r2) |>
      transmute(
        across(all_of(grouping)),
        pc23_increment = `+ PC2--PC3 after context` - `Geography + expanded lake context`
      )
  }
  context_grid_increment <- grid_payload$context_cv_results |>
    context_increment_for_subspace(c("index", "grid_label")) |>
    transmute(index, validation = "Equal-area grid", label = grid_label, pc23_increment)
  context_loco_increment <- loco_payload$context_cv_results |>
    context_increment_for_subspace(c("index", "omitted_continent")) |>
    transmute(index, validation = "LOCO refit", label = omitted_continent, pc23_increment)
  nao_composite <- prepare_seasonal_sensitivity_trajectory_composites(
    data_dir = data_dir, index = "NAO", shared_inputs = main_shared_inputs
  )
  rm(model_payloads, grid_payload, loco_payload, main_shared_inputs)
  gc()
  decade_shared_inputs <- list(
    metadata_data = metadata_data, coast_data = coast_data,
    correlations_data = read_csv(file.path(data_dir,
      "17-seasonal-teleconnection-association", "output",
      "lake_JJA_NAO_AO_lag1_leave_decade_out.csv"), show_col_types = FALSE)
  )
  decade_payload <- prepare_pca_seasonal_teleconnection_decade_loco(
    data_dir = data_dir, shared_inputs = decade_shared_inputs)
  decade_increment <- decade_payload$cv_results |>
    filter(index %in% c("NAO", "AO")) |>
    increment_for_subspace(c("index", "omitted_decade")) |>
    transmute(index, validation = "Leave-one-decade-out", label = omitted_decade,
      pc23_increment)
  field_stability <- decade_payload$field_data |>
    filter(index %in% c("NAO", "AO")) |>
    inner_join(
      target$model_data |>
        select(index, lon_bin, sinlat_bin, full_fisher_z = tele_fisher_z),
      by = c("index", "lon_bin", "sinlat_bin")
    ) |>
    group_by(index, omitted_decade) |>
    summarise(
      full_vs_omitted_spearman = cor(full_fisher_z, tele_fisher_z,
        method = "spearman", use = "complete.obs"),
      .groups = "drop"
    )
  validation_increment <- bind_rows(grid_increment, loco_increment, decade_increment) |>
    mutate(validation = factor(validation,
      levels = c("Equal-area grid", "LOCO refit", "Leave-one-decade-out")))
  context_decade_increment <- decade_payload$context_cv_results |>
    filter(index %in% c("NAO", "AO")) |>
    context_increment_for_subspace(c("index", "omitted_decade")) |>
    transmute(index, validation = "Leave-one-decade-out", label = omitted_decade, pc23_increment)
  context_validation_increment <- bind_rows(
    context_grid_increment, context_loco_increment, context_decade_increment
  ) |>
    mutate(validation = factor(validation,
      levels = c("Equal-area grid", "LOCO refit", "Leave-one-decade-out")))

  map_data <- target$model_data |>
    mutate(
      lon_min = -180 + (lon_bin - 1) * 360 / 72,
      lon_max = -180 + lon_bin * 360 / 72,
      sinlat_min = sin(-60 * pi / 180) + (sinlat_bin - 1) *
        (sin(85 * pi / 180) - sin(-60 * pi / 180)) / 21,
      sinlat_max = sin(-60 * pi / 180) + sinlat_bin *
        (sin(85 * pi / 180) - sin(-60 * pi / 180)) / 21,
      lat_min = asin(sinlat_min) * 180 / pi,
      lat_max = asin(sinlat_max) * 180 / pi,
      index = factor(index, levels = c("NAO", "AO"))
    )
  list(
    model_comparison = model_comparison,
    context_model_comparison = context_model_comparison,
    validation_increment = validation_increment,
    context_validation_increment = context_validation_increment,
    field_stability = field_stability,
    map_data = map_data,
    nao_composite = nao_composite
  )
}

# A narrow, independently runnable lake-context exclusion check. Kept separate
# from the main discovery display so rendering does not retain both large
# correlation inputs and every figure object at once.
prepare_pca_jja_lake_context_display <- function(data_dir = data) {
  screen <- tibble(response_season = "JJA", index = c("NAO", "AO"), lag_years = 1L)
  metadata_data <- read_csv(
    file.path(data_dir, "00-lake-metadata", "output", "lake_metadata.csv"),
    show_col_types = FALSE,
    col_select = c(lake_id, lat, lon, Continent, Lake_area, Depth_avg, Elevation,
      Res_time, Dis_avg, Wshd_area, Vol_total, Shore_dev, Slope_100, is_reservoir)
  )
  coast_data <- read_csv(
    file.path(data_dir, "13-geographic-context", "output", "lake_geographic_context.csv"),
    show_col_types = FALSE, col_select = c(lake_id, distance_to_coast_km)
  )
  shared_inputs <- list(
    metadata_data = metadata_data, coast_data = coast_data,
    correlations_data = read_csv(file.path(data_dir,
      "17-seasonal-teleconnection-association", "output",
      "lake_seasonal_teleconnection_correlations.csv"), show_col_types = FALSE)
  )
  block_layouts <- tibble(
    block_lon_bins = c(4, 6, 8), block_sinlat_bins = c(3, 3, 3),
    block_label = c("4 × 3 bins", "6 × 3 bins", "8 × 3 bins")
  )
  model_comparison <- bind_rows(lapply(seq_len(nrow(block_layouts)), \(i) {
    payload <- do.call(prepare_pca_seasonal_teleconnection_data, c(list(
      data_dir = data_dir, screen = screen,
      block_lon_bins = block_layouts$block_lon_bins[[i]],
      block_sinlat_bins = block_layouts$block_sinlat_bins[[i]]
    ), shared_inputs))
    payload$context_cv_results |> mutate(block_label = block_layouts$block_label[[i]])
  })) |>
    mutate(
      model = factor(model, levels = levels(model)),
      block_label = factor(block_label, levels = block_layouts$block_label),
      index = factor(index, levels = c("NAO", "AO"))
    )
  context_increment <- function(frame, grouping) {
    frame |>
      filter(model %in% c("Geography + expanded lake context", "+ PC2--PC3 after context")) |>
      select(all_of(grouping), model, spatial_block_cv_r2) |>
      pivot_wider(names_from = model, values_from = spatial_block_cv_r2) |>
      transmute(
        across(all_of(grouping)),
        pc23_increment = `+ PC2--PC3 after context` - `Geography + expanded lake context`
      )
  }
  grid_payload <- prepare_pca_seasonal_teleconnection_grid_sensitivity(
    data_dir = data_dir, screen = screen, shared_inputs = shared_inputs)
  loco_payload <- prepare_pca_seasonal_teleconnection_loco_sensitivity(
    data_dir = data_dir, screen = screen, shared_inputs = shared_inputs)
  grid_increment <- grid_payload$context_cv_results |>
    context_increment(c("index", "grid_label")) |>
    transmute(index, validation = "Equal-area grid", label = grid_label, pc23_increment)
  loco_increment <- loco_payload$context_cv_results |>
    context_increment(c("index", "omitted_continent")) |>
    transmute(index, validation = "LOCO refit", label = omitted_continent, pc23_increment)
  rm(shared_inputs, grid_payload, loco_payload)
  gc()
  decade_inputs <- list(
    metadata_data = metadata_data, coast_data = coast_data,
    correlations_data = read_csv(file.path(data_dir,
      "17-seasonal-teleconnection-association", "output",
      "lake_JJA_NAO_AO_lag1_leave_decade_out.csv"), show_col_types = FALSE)
  )
  decade_payload <- prepare_pca_seasonal_teleconnection_decade_loco(
    data_dir = data_dir, shared_inputs = decade_inputs)
  decade_increment <- decade_payload$context_cv_results |>
    filter(index %in% c("NAO", "AO")) |>
    context_increment(c("index", "omitted_decade")) |>
    transmute(index, validation = "Leave-one-decade-out", label = omitted_decade, pc23_increment)
  list(
    model_comparison = model_comparison,
    validation_increment = bind_rows(grid_increment, loco_increment, decade_increment) |>
      mutate(validation = factor(validation,
        levels = c("Equal-area grid", "LOCO refit", "Leave-one-decade-out")))
  )
}
