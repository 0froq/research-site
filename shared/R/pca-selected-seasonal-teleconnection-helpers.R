# Rendering-time validation for fixed Step 19 seasonal teleconnection candidates.
# Depends on figure-style.R and pca-seasonal-teleconnection-helpers.R.

selected_tele_long_to_wide <- function(long_data) {
  base <- long_data |>
    select(lake_id, lat, lon) |>
    distinct()
  candidates <- long_data |>
    distinct(id) |>
    pull(id)
  for (candidate in candidates) {
    part <- long_data |>
      filter(id == .env$candidate) |>
      select(lake_id, n_pairs, r) |>
      rename(
        !!paste0("candidate_", candidate, "_n") := n_pairs,
        !!paste0("candidate_", candidate, "_r") := r
      )
    base <- left_join(base, part, by = "lake_id")
  }
  base
}

selected_tele_screen <- function(long_data) {
  long_data |>
    distinct(id, response, predictor, index, lag_quarters) |>
    rename(tele_index = index) |>
    transmute(
      response_season = id,
      index = "fixed_candidate",
      lag_years = 0L,
      response, predictor, tele_index, lag_quarters
    )
}

prepare_selected_seasonal_teleconnection_data <- function(
    data_dir = data, grid = "sinlat_equalarea_72x21_mean",
    n_lon = 72, n_lat = 21, block_lon_bins = 6, block_sinlat_bins = 3,
    omitted_continent = NULL, long_data = NULL, min_pairs = 30,
    metadata_data = NULL, coast_data = NULL) {
  if (is.null(long_data)) {
    long_data <- read_csv(file.path(data_dir,
      "19-selected-seasonal-teleconnection-association", "output",
      "lake_selected_seasonal_teleconnection_correlations.csv"), show_col_types = FALSE)
  }
  screen <- selected_tele_screen(long_data)
  wide_data <- selected_tele_long_to_wide(long_data)
  payload <- prepare_pca_seasonal_teleconnection_data(
    data_dir = data_dir, grid = grid, n_lon = n_lon, n_lat = n_lat,
    block_lon_bins = block_lon_bins, block_sinlat_bins = block_sinlat_bins,
    screen = screen |> select(response_season, index, lag_years),
    omitted_continent = omitted_continent,
    correlations_data = wide_data, min_pairs = min_pairs,
    metadata_data = metadata_data, coast_data = coast_data,
    prefix_fun = function(season, index, lag) paste0("candidate_", season)
  )
  metadata <- screen |> select(response_season, response, predictor, tele_index, lag_quarters)
  list(
    model_data = left_join(payload$model_data, metadata, by = "response_season"),
    cv_results = left_join(payload$cv_results, metadata, by = "response_season"),
    context_model_data = left_join(payload$context_model_data, metadata, by = "response_season"),
    context_cv_results = left_join(payload$context_cv_results, metadata, by = "response_season"),
    candidates = metadata
  )
}

selected_tele_increment <- function(cv_results) {
  grouping <- intersect(c(
    "response_season", "grid_label", "omitted_continent", "omitted_decade"
  ), names(cv_results))
  cv_results |>
    select(all_of(grouping), model, spatial_block_cv_r2) |>
    pivot_wider(id_cols = all_of(grouping), names_from = model, values_from = spatial_block_cv_r2) |>
    transmute(
      across(all_of(grouping)),
      pc1_increment = `+ PC1` - `Geography + morphology`,
      pc2_increment = `+ PC2` - `Geography + morphology`,
      pc3_increment = `+ PC3` - `Geography + morphology`,
      pc12_increment = `+ PC1 + PC2` - `Geography + morphology`,
      pc13_increment = `+ PC1 + PC3` - `Geography + morphology`,
      pc23_increment = `+ PC2--PC3 subspace` - `Geography + morphology`,
      pc123_increment = `+ PC1 + PC2--PC3 subspace` - `Geography + morphology`
    ) |>
    pivot_longer(
      c(pc1_increment, pc2_increment, pc3_increment, pc12_increment,
        pc13_increment, pc23_increment, pc123_increment),
      names_to = "addition", values_to = "heldout_r2_increment"
    )
}

prepare_selected_tele_grid_sensitivity <- function(data_dir = data, long_data = NULL, shared_inputs = list()) {
  grids <- tibble(
    grid = c("sinlat_equalarea_36x11_mean", "sinlat_equalarea_72x21_mean", "sinlat_equalarea_144x42_mean"),
    n_lon = c(36, 72, 144), n_lat = c(11, 21, 42),
    block_lon_bins = c(3, 6, 12), block_sinlat_bins = c(2, 3, 6),
    grid_label = c("36 × 11", "72 × 21", "144 × 42")
  )
  bind_rows(lapply(seq_len(nrow(grids)), function(i) {
    payload <- do.call(prepare_selected_seasonal_teleconnection_data, c(list(
      data_dir = data_dir, long_data = long_data,
      grid = grids$grid[[i]], n_lon = grids$n_lon[[i]], n_lat = grids$n_lat[[i]],
      block_lon_bins = grids$block_lon_bins[[i]], block_sinlat_bins = grids$block_sinlat_bins[[i]]
    ), shared_inputs))
    payload$cv_results |> mutate(grid_label = grids$grid_label[[i]])
  }))
}

prepare_selected_tele_loco <- function(data_dir = data, long_data = NULL, shared_inputs = list()) {
  pca_dir <- file.path(data_dir, "16-spatial-balanced-pca", "output", "sinlat_equalarea_72x21_mean")
  continents <- read_csv(file.path(pca_dir, "loco_refit_cell_scores.csv"), show_col_types = FALSE) |>
    distinct(omitted_continent) |> pull(omitted_continent)
  bind_rows(lapply(continents, function(continent) {
    payload <- do.call(prepare_selected_seasonal_teleconnection_data, c(list(
      data_dir = data_dir, long_data = long_data, omitted_continent = continent
    ), shared_inputs))
    payload$cv_results |> mutate(omitted_continent = continent)
  }))
}

prepare_selected_tele_lodo <- function(data_dir = data, long_data = NULL, shared_inputs = list()) {
  if (is.null(long_data)) {
    long_data <- read_csv(file.path(data_dir,
      "19-selected-seasonal-teleconnection-association", "output",
      "lake_selected_seasonal_teleconnection_leave_decade_out.csv"), show_col_types = FALSE)
  }
  decades <- long_data |> distinct(omitted_first_year, omitted_last_year)
  bind_rows(lapply(seq_len(nrow(decades)), function(i) {
    first_year <- decades$omitted_first_year[[i]]; last_year <- decades$omitted_last_year[[i]]
    payload <- do.call(prepare_selected_seasonal_teleconnection_data, c(list(
      data_dir = data_dir,
      long_data = filter(long_data, omitted_first_year == .env$first_year, omitted_last_year == .env$last_year),
      min_pairs = 28
    ), shared_inputs))
    payload$cv_results |> mutate(omitted_decade = paste(first_year, last_year, sep = "–"))
  }))
}

prepare_selected_tele_display <- function(data_dir = data) {
  correlations <- read_csv(file.path(data_dir,
    "19-selected-seasonal-teleconnection-association", "output",
    "lake_selected_seasonal_teleconnection_correlations.csv"), show_col_types = FALSE)
  lodo_correlations <- read_csv(file.path(data_dir,
    "19-selected-seasonal-teleconnection-association", "output",
    "lake_selected_seasonal_teleconnection_leave_decade_out.csv"), show_col_types = FALSE)
  base <- prepare_selected_seasonal_teleconnection_data(
    data_dir = data_dir, long_data = correlations
  )
  label_candidates <- function(frame) {
    frame |>
      left_join(base$candidates, by = "response_season") |>
      mutate(candidate_label = paste0(
        response, " LSWT | ", predictor, " ", tele_index,
        " | lag ", lag_quarters, if_else(lag_quarters == 1, " quarter", " quarters")
      ))
  }
  list(
    base_increment = label_candidates(selected_tele_increment(base$cv_results)),
    grid_increment = label_candidates(selected_tele_increment(
      prepare_selected_tele_grid_sensitivity(data_dir = data_dir, long_data = correlations)
    )),
    loco_increment = label_candidates(selected_tele_increment(
      prepare_selected_tele_loco(data_dir = data_dir, long_data = correlations)
    )),
    lodo_increment = label_candidates(selected_tele_increment(
      prepare_selected_tele_lodo(data_dir = data_dir, long_data = lodo_correlations)
    ))
  )
}

prepare_selected_tele_spatial_fields <- function(data_dir = data) {
  payload <- prepare_selected_seasonal_teleconnection_data(data_dir = data_dir)
  background_terms <- c(
    "sin_lat", "I(sin_lat^2)", "sin_lon", "cos_lon", "Elevation",
    "log_lake_area", "log_depth", "log_distance_to_coast"
  )
  sinlat_min <- sin(-60 * pi / 180)
  sinlat_max <- sin(85 * pi / 180)
  fields <- payload$model_data |>
    group_by(response_season) |>
    group_modify(function(frame, key) {
      fit <- lm(reformulate(background_terms, response = "tele_fisher_z"), data = frame)
      mutate(frame, geography_residual = residuals(fit))
    }) |>
    ungroup() |>
    mutate(
      candidate_label = paste0(
        response, " LSWT | ", predictor, " ", tele_index,
        " | lag ", lag_quarters, if_else(lag_quarters == 1, " quarter", " quarters")
      ),
      lon_min = -180 + (lon_bin - 1) * 5,
      lon_max = -180 + lon_bin * 5,
      sinlat_min_cell = sinlat_min + (sinlat_bin - 1) / 21 * (sinlat_max - sinlat_min),
      sinlat_max_cell = sinlat_min + sinlat_bin / 21 * (sinlat_max - sinlat_min),
      lat_min = asin(sinlat_min_cell) * 180 / pi,
      lat_max = asin(sinlat_max_cell) * 180 / pi
    )
  primary <- fields |>
    filter(response_season %in% c(
      "JJA_NAO_from_JJA_lag4q", "JJA_AO_from_JJA_lag4q"
    ))
  pc2 <- primary |>
    distinct(lon_bin, sinlat_bin, lon_min, lon_max, lat_min, lat_max, pc2) |>
    mutate(component = "PC2 score")
  list(payload = payload, fields = fields, primary = primary, pc2 = pc2)
}

prepare_selected_tele_neighbor_diagnostics <- function(primary_fields) {
  pair_one_index <- function(frame) {
    select_cols <- c(
      "lon_bin", "sinlat_bin", "tele_fisher_z", "geography_residual",
      "pc1", "pc2", "pc3", "Elevation", "log_lake_area", "log_depth",
      "log_distance_to_coast"
    )
    cells <- frame |> select(all_of(select_cols))
    east_pairs <- inner_join(
      mutate(cells, lon_bin = lon_bin + 1L), cells,
      by = c("lon_bin", "sinlat_bin"), suffix = c("_a", "_b")
    )
    north_pairs <- inner_join(
      mutate(cells, sinlat_bin = sinlat_bin + 1L), cells,
      by = c("lon_bin", "sinlat_bin"), suffix = c("_a", "_b")
    )
    bind_rows(east_pairs, north_pairs)
  }
  pairs <- primary_fields |>
    group_by(tele_index) |>
    group_modify(function(frame, key) pair_one_index(frame)) |>
    ungroup() |>
    mutate(
      opposite_sign = sign(tele_fisher_z_a) != sign(tele_fisher_z_b),
      min_abs_z = pmin(abs(tele_fisher_z_a), abs(tele_fisher_z_b)),
      abs_field_difference = abs(tele_fisher_z_a - tele_fisher_z_b)
    )
  thresholds <- tibble(threshold = c(.10, .15, .20))
  summary <- tidyr::crossing(
    tele_index = unique(pairs$tele_index), thresholds
  ) |>
    rowwise() |>
    mutate(
      n_pairs = sum(pairs$tele_index == tele_index & pairs$min_abs_z >= threshold),
      n_opposite = sum(pairs$tele_index == tele_index & pairs$min_abs_z >= threshold & pairs$opposite_sign),
      fraction_opposite = if_else(n_pairs > 0, n_opposite / n_pairs, NA_real_)
    ) |>
    ungroup()
  autocorrelation <- pairs |>
    group_by(tele_index) |>
    summarise(
      n_pairs = n(),
      neighbor_correlation = cor(tele_fisher_z_a, tele_fisher_z_b),
      residual_neighbor_correlation = cor(geography_residual_a, geography_residual_b),
      .groups = "drop"
    )
  list(pairs = pairs, summary = summary, autocorrelation = autocorrelation)
}

prepare_selected_tele_trajectory_composites <- function(data_dir = data, spatial = NULL) {
  if (is.null(spatial)) spatial <- prepare_selected_tele_spatial_fields(data_dir = data_dir)
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
  memberships <- spatial$primary |>
    group_by(tele_index) |>
    mutate(
      q20 = quantile(tele_fisher_z, .20, na.rm = TRUE),
      q80 = quantile(tele_fisher_z, .80, na.rm = TRUE),
      sensitivity_pole = case_when(
        tele_fisher_z <= q20 ~ "Negative-association pole",
        tele_fisher_z >= q80 ~ "Positive-association pole",
        .default = NA_character_
      )
    ) |>
    filter(!is.na(sensitivity_pole)) |>
    select(lon_bin, sinlat_bin, tele_index, sensitivity_pole, tele_fisher_z, pc1, pc2, pc3)
  aggregate_anomalies <- function(file_name, representation) {
    wide <- read_csv(file.path(data_dir, "02-annual-temperature", "output", file_name), show_col_types = FALSE)
    year_cols <- intersect(names(wide), as.character(1981:2020))
    baseline_cols <- intersect(year_cols, as.character(1981:1990))
    length(baseline_cols) == 10 || stop("Missing baseline years in ", file_name)
    baseline <- rowMeans(as.matrix(wide[, baseline_cols]), na.rm = TRUE)
    wide |>
      mutate(.baseline = baseline) |>
      mutate(across(all_of(year_cols), ~ .x - .baseline)) |>
      select(-.baseline) |>
      assign_cell() |>
      group_by(lon_bin, sinlat_bin) |>
      summarise(across(all_of(year_cols), ~ mean(.x, na.rm = TRUE)), .groups = "drop") |>
      pivot_longer(all_of(year_cols), names_to = "year", values_to = "anomaly") |>
      mutate(year = as.integer(year), representation = representation)
  }
  trajectories <- bind_rows(
    aggregate_anomalies("annual_mean_temperature.csv", "Raw annual LSWT"),
    aggregate_anomalies("JJA_temperature.csv", "Raw JJA LSWT")
  ) |>
    inner_join(memberships, by = c("lon_bin", "sinlat_bin"), relationship = "many-to-many") |>
    group_by(representation, tele_index, sensitivity_pole, year) |>
    summarise(
      anomaly_mean = mean(anomaly, na.rm = TRUE),
      anomaly_q25 = quantile(anomaly, .25, na.rm = TRUE),
      anomaly_q75 = quantile(anomaly, .75, na.rm = TRUE),
      n_cells = n(), .groups = "drop"
    )
  aggregate_speed <- function(file_name, representation) {
    wide <- read_csv(file.path(data_dir, "14-trajectory-diagnostics", "output", file_name), show_col_types = FALSE)
    year_cols <- names(wide)[grepl("^X?\\d{4}$", names(wide))]
    wide |>
      assign_cell() |>
      group_by(lon_bin, sinlat_bin) |>
      summarise(across(all_of(year_cols), ~ mean(.x, na.rm = TRUE)), .groups = "drop") |>
      pivot_longer(all_of(year_cols), names_to = "year", values_to = "speed") |>
      mutate(year = as.integer(sub("^X", "", year)), representation = representation)
  }
  speeds <- bind_rows(
    aggregate_speed("rolling_sen_speed_10yr.csv", "Raw annual LSWT"),
    aggregate_speed("rolling_sen_speed_10yr_JJA.csv", "Raw JJA LSWT")
  ) |>
    inner_join(memberships, by = c("lon_bin", "sinlat_bin"), relationship = "many-to-many") |>
    group_by(representation, tele_index, sensitivity_pole, year) |>
    summarise(
      speed_mean = mean(speed, na.rm = TRUE),
      speed_q25 = quantile(speed, .25, na.rm = TRUE),
      speed_q75 = quantile(speed, .75, na.rm = TRUE),
      n_cells = n(), .groups = "drop"
    )
  score_summary <- memberships |>
    group_by(tele_index, sensitivity_pole) |>
    summarise(
      n_cells = n(),
      mean_fisher_z = mean(tele_fisher_z),
      across(c(pc1, pc2, pc3), mean),
      .groups = "drop"
    ) |>
    pivot_longer(c(pc1, pc2, pc3), names_to = "component", values_to = "mean_score")
  list(trajectories = trajectories, speeds = speeds, score_summary = score_summary, memberships = memberships)
}
