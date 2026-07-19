# Rendering-time preparation for bounded PCA--teleconnection sensitivity screens.
# Depends on figure-style.R having been sourced.

tele_spatial_block_cv_r2 <- function(data, response, terms) {
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

prepare_pca_teleconnection_data <- function(
    data_dir = data, grid = "sinlat_equalarea_72x21_mean",
    n_lon = 72, n_lat = 21, block_lon_bins = 6, block_sinlat_bins = 3,
    index_lags = NULL, omitted_continent = NULL) {
  pca_dir <- file.path(data_dir, "16-spatial-balanced-pca", "output", grid)
  tele_dir <- file.path(data_dir, "10-teleconnection-association", "output")
  screen <- if (is.null(index_lags)) {
    tidyr::crossing(index = c("Nino34", "PDO", "NAO", "AO"), lag_years = 0:1)
  } else {
    index_lags
  }

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
  metadata <- read_csv(
    file.path(data_dir, "00-lake-metadata", "output", "lake_metadata.csv"),
    show_col_types = FALSE,
    col_select = c(lake_id, lat, lon, Continent, Lake_area, Depth_avg, Elevation)
  )
  coast <- read_csv(
    file.path(data_dir, "13-geographic-context", "output", "lake_geographic_context.csv"),
    show_col_types = FALSE,
    col_select = c(lake_id, distance_to_coast_km)
  )
  tele <- read_csv(
    file.path(tele_dir, "lake_teleconnection_correlations.csv"),
    show_col_types = FALSE
  )

  included_metadata <- if (is.null(omitted_continent)) metadata else filter(metadata, Continent != .env$omitted_continent)
  cell_background <- included_metadata |>
    left_join(coast, by = "lake_id") |>
    mutate(
      log_lake_area = log1p(Lake_area),
      log_depth = log1p(pmax(Depth_avg, 0)),
      log_distance_to_coast = log1p(distance_to_coast_km)
    ) |>
    assign_cell() |>
    group_by(lon_bin, sinlat_bin) |>
    summarise(
      n_lakes_background = n(),
      across(c(log_lake_area, log_depth, Elevation, log_distance_to_coast),
        \(x) mean(x, na.rm = TRUE)),
      .groups = "drop"
    )

  tele_long <- bind_rows(lapply(seq_len(nrow(screen)), \(i) {
    index <- screen$index[[i]]
    lag <- screen$lag_years[[i]]
    prefix <- paste0("tele_", index, "_lag", lag)
    tele |>
      transmute(
        lake_id, lat, lon,
        index = index,
        lag_years = lag,
        n_pairs = .data[[paste0(prefix, "_n")]],
        r = .data[[paste0(prefix, "_r")]]
      )
  })) |>
    left_join(metadata |> select(lake_id, Continent), by = "lake_id")
  if (!is.null(omitted_continent)) {
    tele_long <- tele_long |> filter(Continent != .env$omitted_continent)
  }
  tele_long <- tele_long |>
    filter(is.finite(r), n_pairs >= 30, abs(r) < 1) |>
    mutate(
      fisher_z = atanh(pmax(pmin(r, 0.999999), -0.999999)),
      fisher_weight = pmax(n_pairs - 3, 1)
    ) |>
    assign_cell()

  cell_sensitivity <- tele_long |>
    group_by(index, lag_years, lon_bin, sinlat_bin) |>
    summarise(
      tele_fisher_z = weighted.mean(fisher_z, fisher_weight, na.rm = TRUE),
      n_lakes_tele = n(),
      .groups = "drop"
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
    "+ PC2--PC3 subspace" = c(background_terms, "pc2", "pc3")
  )
  cv_results <- model_data |>
    group_by(index, lag_years) |>
    group_modify(\(frame, key) bind_rows(lapply(names(models), \(model) tibble(
      model = model,
      spatial_block_cv_r2 = tele_spatial_block_cv_r2(frame, "tele_fisher_z", models[[model]]),
      n_cells = nrow(frame),
      n_lakes_median = median(frame$n_lakes_tele)
    )))) |>
    ungroup() |>
    mutate(model = factor(model, levels = names(models)))

  list(
    model_data = model_data,
    cv_results = cv_results,
    screen = screen,
    background_terms = background_terms,
    qc = list(
      n_cells = n_distinct(interaction(model_data$lon_bin, model_data$sinlat_bin)),
      n_blocks = n_distinct(model_data$spatial_block),
      grid = grid, n_lon = n_lon, n_lat = n_lat,
      block_lon_bins = block_lon_bins, block_sinlat_bins = block_sinlat_bins
    )
  )
}

prepare_pca_teleconnection_sensitivity <- function(data_dir = data, index_lags = NULL) {
  settings <- tibble(
    block_lon_bins = c(4, 6, 8),
    block_sinlat_bins = c(3, 3, 3),
    block_label = c("4 × 3 bins", "6 × 3 bins", "8 × 3 bins")
  )
  cv_results <- bind_rows(lapply(seq_len(nrow(settings)), \(i) {
    payload <- prepare_pca_teleconnection_data(
      data_dir = data_dir,
      block_lon_bins = settings$block_lon_bins[[i]],
      block_sinlat_bins = settings$block_sinlat_bins[[i]],
      index_lags = index_lags
    )
    payload$cv_results |>
      mutate(block_label = settings$block_label[[i]], n_blocks = payload$qc$n_blocks)
  })) |>
    mutate(block_label = factor(block_label, levels = settings$block_label))
  list(cv_results = cv_results, settings = settings)
}

prepare_pca_teleconnection_grid_sensitivity <- function(data_dir = data, index_lags = NULL) {
  grids <- tibble(
    grid = c("sinlat_equalarea_36x11_mean", "sinlat_equalarea_72x21_mean", "sinlat_equalarea_144x42_mean"),
    n_lon = c(36, 72, 144), n_lat = c(11, 21, 42),
    block_lon_bins = c(3, 6, 12), block_sinlat_bins = c(2, 3, 6),
    grid_label = c("36 × 11", "72 × 21", "144 × 42")
  )
  cv_results <- bind_rows(lapply(seq_len(nrow(grids)), \(i) {
    payload <- prepare_pca_teleconnection_data(
      data_dir = data_dir, grid = grids$grid[[i]],
      n_lon = grids$n_lon[[i]], n_lat = grids$n_lat[[i]],
      block_lon_bins = grids$block_lon_bins[[i]], block_sinlat_bins = grids$block_sinlat_bins[[i]],
      index_lags = index_lags
    )
    payload$cv_results |> mutate(grid_label = grids$grid_label[[i]])
  })) |>
    mutate(grid_label = factor(grid_label, levels = grids$grid_label))
  list(cv_results = cv_results, grids = grids)
}

prepare_pca_teleconnection_loco_sensitivity <- function(
    data_dir = data, index_lags = tibble(index = c("NAO", "Nino34", "PDO"), lag_years = 0L)) {
  pca_dir <- file.path(data_dir, "16-spatial-balanced-pca", "output", "sinlat_equalarea_72x21_mean")
  continents <- read_csv(file.path(pca_dir, "loco_refit_cell_scores.csv"), show_col_types = FALSE) |>
    distinct(omitted_continent) |>
    pull(omitted_continent)
  cv_results <- bind_rows(lapply(continents, \(continent) {
    payload <- prepare_pca_teleconnection_data(
      data_dir = data_dir, omitted_continent = continent,
      index_lags = index_lags
    )
    payload$cv_results |> mutate(omitted_continent = continent)
  }))
  list(cv_results = cv_results, index_lags = index_lags)
}

prepare_pca_teleconnection_display <- function(data_dir = data) {
  screen_pairs <- tibble(
    index = c("NAO", "AO", "PDO"),
    lag_years = 0L
  )
  promoted <- tibble(index = c("NAO", "PDO"), lag_years = 0L)
  screen <- prepare_pca_teleconnection_sensitivity(
    data_dir = data_dir, index_lags = screen_pairs
  )$cv_results
  grid <- prepare_pca_teleconnection_grid_sensitivity(
    data_dir = data_dir, index_lags = promoted
  )$cv_results
  loco <- prepare_pca_teleconnection_loco_sensitivity(
    data_dir = data_dir, index_lags = promoted
  )$cv_results
  map_data <- prepare_pca_teleconnection_data(
    data_dir = data_dir, index_lags = promoted
  )$model_data |>
    mutate(
      index = factor(index, levels = promoted$index),
      lon_min = -180 + (lon_bin - 1) * 360 / 72,
      lon_max = -180 + lon_bin * 360 / 72,
      sinlat_min = sin(-60 * pi / 180),
      sinlat_max = sin(85 * pi / 180),
      lat_min = asin(sinlat_min + (sinlat_bin - 1) / 21 * (sinlat_max - sinlat_min)) * 180 / pi,
      lat_max = asin(sinlat_min + sinlat_bin / 21 * (sinlat_max - sinlat_min)) * 180 / pi
    )

  make_increment <- function(frame, grouping) {
    frame |>
      select(all_of(grouping), model, spatial_block_cv_r2) |>
      tidyr::pivot_wider(names_from = model, values_from = spatial_block_cv_r2) |>
      transmute(
        across(all_of(grouping)),
        pc1_increment = `+ PC1` - `Geography + morphology`,
        pc23_increment = `+ PC2--PC3 subspace` - `Geography + morphology`
      ) |>
      tidyr::pivot_longer(
        c(pc1_increment, pc23_increment),
        names_to = "addition", values_to = "heldout_r2_increment"
      ) |>
      mutate(addition = recode(addition,
        pc1_increment = "+ PC1",
        pc23_increment = "+ PC2--PC3 subspace"
      ))
  }

  list(
    screen = screen,
    screen_increment = make_increment(screen, c("index", "lag_years", "block_label")),
    grid_increment = make_increment(grid, c("index", "lag_years", "grid_label")),
    loco_increment = make_increment(loco, c("index", "lag_years", "omitted_continent")),
    map_data = map_data,
    promoted = promoted
  )
}
