# Rendering-time preparation for PC2--PC3 trajectory-morphology diagnostics.
# Depends on figure-style.R having been sourced.

sen_slope <- function(year, value) {
  keep <- is.finite(year) & is.finite(value)
  year <- year[keep]
  value <- value[keep]
  if (length(value) < 3) return(NA_real_)
  pair <- utils::combn(seq_along(value), 2)
  stats::median((value[pair[2, ]] - value[pair[1, ]]) / (year[pair[2, ]] - year[pair[1, ]]))
}

score_axis <- function(scores, loadings, descriptors, metric) {
  model_data <- scores |>
    inner_join(descriptors, by = c("lon_bin", "sinlat_bin")) |>
    filter(if_all(c(pc2, pc3, all_of(metric)), is.finite))
  fit <- lm(reformulate(c("pc2", "pc3"), response = metric), data = model_data)
  coefficients <- coef(fit)[c("pc2", "pc3")]
  direction <- coefficients / sqrt(sum(coefficients^2))
  model_data <- model_data |>
    mutate(
      timing_score = pc2 * direction[["pc2"]] + pc3 * direction[["pc3"]],
      timing_quintile = factor(ntile(timing_score, 5), levels = 1:5)
    )
  axis_loading <- as.numeric(as.matrix(loadings[, c("pc2", "pc3")]) %*% direction)
  list(
    data = model_data,
    direction = direction,
    axis_loading = axis_loading,
    r_squared = summary(fit)$r.squared,
    n_cells = nrow(model_data)
  )
}

loading_cosine <- function(a, b) {
  sum(a * b) / sqrt(sum(a^2) * sum(b^2))
}

prepare_pca_morphology_data <- function(data_dir = data) {
  pca_root <- file.path(data_dir, "16-spatial-balanced-pca", "output")
  trajectory_dir <- file.path(data_dir, "14-trajectory-diagnostics", "output")
  grids <- tibble(
    grid = c("sinlat_equalarea_36x11_mean", "sinlat_equalarea_72x21_mean", "sinlat_equalarea_144x42_mean"),
    n_lon = c(36, 72, 144), n_lat = c(11, 21, 42),
    label = c("36 × 11", "72 × 21", "144 × 42")
  )
  lake_continent <- read_csv(
    file.path(data_dir, "00-lake-metadata", "output", "lake_metadata.csv"),
    show_col_types = FALSE,
    col_select = c(lake_id, Continent)
  )
  rolling_speed <- read_csv(
    file.path(trajectory_dir, "rolling_sen_speed_10yr.csv"),
    show_col_types = FALSE
  ) |>
    select(lake_id, lat, lon, matches("^X?\\d{4}$")) |>
    pivot_longer(matches("^X?\\d{4}$"), names_to = "year", values_to = "speed") |>
    mutate(year = as.integer(sub("^X", "", year))) |>
    left_join(lake_continent, by = "lake_id")

  assign_cell <- function(data, n_lon, n_lat) {
    sinlat_min <- sin(-60 * pi / 180)
    sinlat_max <- sin(85 * pi / 180)
    data |>
      filter(is.finite(lat), is.finite(lon), between(lat, -60, 85)) |>
      mutate(
        lon_bin = pmin(floor((lon + 180) / 360 * n_lon) + 1, n_lon),
        sinlat_bin = pmin(floor((sin(lat * pi / 180) - sinlat_min) / (sinlat_max - sinlat_min) * n_lat) + 1, n_lat)
      )
  }

  cell_speed_descriptors <- function(n_lon, n_lat, omitted_continent = NULL) {
    included_speed <- if (is.null(omitted_continent)) rolling_speed else filter(rolling_speed, Continent != omitted_continent)
    speed <- included_speed |>
      assign_cell(n_lon, n_lat) |>
      group_by(lon_bin, sinlat_bin, year) |>
      summarise(speed = mean(speed, na.rm = TRUE), .groups = "drop") |>
      filter(is.finite(speed))
    descriptors <- speed |>
      group_by(lon_bin, sinlat_bin) |>
      group_modify(\(data, key) tibble(
        speed_change = sen_slope(data$year, data$speed) * 1e3,
        late_minus_early_speed = median(data$speed[between(data$year, 2011, 2020)], na.rm = TRUE) -
          median(data$speed[between(data$year, 1990, 1999)], na.rm = TRUE),
        speed_variability = sd(data$speed, na.rm = TRUE)
      )) |>
      ungroup() |>
      mutate(across(-c(lon_bin, sinlat_bin), ~ ifelse(is.finite(.x), .x, NA_real_)))
    list(speed = speed, descriptors = descriptors)
  }

  read_grid <- function(grid) {
    path <- file.path(pca_root, grid$grid)
    list(
      scores = read_csv(file.path(path, "spatial_cell_scores.csv"), show_col_types = FALSE) |>
        select(cell_id, lon_bin, sinlat_bin, lon, lat, pc2, pc3),
      loadings = read_csv(file.path(path, "pca_loadings.csv"), show_col_types = FALSE) |>
        select(year, pc2, pc3),
      loco_loadings = read_csv(file.path(path, "loco_refit_loadings.csv"), show_col_types = FALSE),
      loco_scores = read_csv(file.path(path, "loco_refit_cell_scores.csv"), show_col_types = FALSE),
      subspace = read_csv(file.path(path, "loco_subspace_stability.csv"), show_col_types = FALSE) |>
        filter(subspace == "PC2-PC3")
    )
  }

  grid_payloads <- lapply(seq_len(nrow(grids)), \(i) {
    grid <- grids[i, ]
    pca <- read_grid(grid)
    speed <- cell_speed_descriptors(grid$n_lon, grid$n_lat)
    speed_axis <- score_axis(pca$scores, pca$loadings, speed$descriptors, "speed_change")
    late_axis <- score_axis(pca$scores, pca$loadings, speed$descriptors, "late_minus_early_speed")
    list(grid = grid, pca = pca, speed = speed, speed_axis = speed_axis, late_axis = late_axis)
  })
  names(grid_payloads) <- grids$grid
  reference <- grid_payloads[["sinlat_equalarea_72x21_mean"]]

  grid_axis_stability <- bind_rows(lapply(grid_payloads, \(payload) {
    tibble(
      grid = payload$grid$label,
      axis = c("Speed-change axis", "Late-minus-early axis"),
      loading_cosine = c(
        loading_cosine(reference$speed_axis$axis_loading, payload$speed_axis$axis_loading),
        loading_cosine(reference$late_axis$axis_loading, payload$late_axis$axis_loading)
      ),
      r_squared = c(payload$speed_axis$r_squared, payload$late_axis$r_squared),
      n_cells = c(payload$speed_axis$n_cells, payload$late_axis$n_cells)
    )
  })) |>
    mutate(grid = factor(grid, levels = grids$label))

  refit_axis_rows <- lapply(unique(reference$pca$loco_scores$omitted_continent), \(omitted) {
    scores <- reference$pca$loco_scores |>
      filter(omitted_continent == omitted) |>
      select(cell_id, lon_bin, sinlat_bin, lon, lat, pc2, pc3)
    loadings <- reference$pca$loco_loadings |>
      filter(omitted_continent == omitted) |>
      select(year, pc2, pc3)
    speed <- cell_speed_descriptors(72, 21, omitted)$descriptors
    axis <- score_axis(scores, loadings, speed, "speed_change")
    tibble(
      omitted_continent = omitted,
      loading_cosine = loading_cosine(reference$speed_axis$axis_loading, axis$axis_loading),
      r_squared = axis$r_squared,
      n_cells = axis$n_cells
    )
  }) |>
    bind_rows() |>
    left_join(reference$pca$subspace |> select(omitted_continent, min_cosine, max_angle_deg), by = "omitted_continent")

  timing_composites <- reference$speed_axis$data |>
    select(lon_bin, sinlat_bin, timing_quintile) |>
    inner_join(reference$speed$speed, by = c("lon_bin", "sinlat_bin")) |>
    group_by(timing_quintile, year) |>
    summarise(
      speed_mean = mean(speed, na.rm = TRUE),
      speed_q25 = quantile(speed, .25, na.rm = TRUE),
      speed_q75 = quantile(speed, .75, na.rm = TRUE),
      n_cells = n(),
      .groups = "drop"
    )
  timing_quintile_metrics <- reference$speed_axis$data |>
    group_by(timing_quintile) |>
    summarise(
      speed_change = mean(speed_change, na.rm = TRUE),
      late_minus_early_speed = mean(late_minus_early_speed, na.rm = TRUE),
      speed_variability = mean(speed_variability, na.rm = TRUE),
      n_cells = n(),
      .groups = "drop"
    )
  spatial_block_cv <- reference$speed_axis$data |>
    mutate(spatial_block = interaction(floor((lon_bin - 1) / 6), floor((sinlat_bin - 1) / 3), drop = TRUE)) |>
    group_by(spatial_block) |>
    group_modify(\(test_data, key) {
      train_data <- anti_join(
        reference$speed_axis$data,
        distinct(test_data, lon_bin, sinlat_bin),
        by = c("lon_bin", "sinlat_bin")
      )
      fit <- lm(speed_change ~ pc2 + pc3, data = train_data)
      direction <- coef(fit)[c("pc2", "pc3")]
      direction <- direction / sqrt(sum(direction^2))
      test_score <- test_data$pc2 * direction[["pc2"]] + test_data$pc3 * direction[["pc3"]]
      tibble(
        n_test_cells = nrow(test_data),
        direction_cosine = sum(direction * reference$speed_axis$direction),
        test_spearman = cor(test_score, test_data$speed_change, method = "spearman", use = "complete.obs")
      )
    }) |>
    ungroup()
  spatial_block_summary <- spatial_block_cv |>
    filter(n_test_cells >= 5) |>
    summarise(
      n_blocks = n(),
      min_direction_cosine = min(direction_cosine),
      median_test_spearman = median(test_spearman),
      mean_test_spearman = mean(test_spearman)
    )

  list(
    reference_data = reference$speed_axis$data,
    timing_composites = timing_composites,
    timing_quintile_metrics = timing_quintile_metrics,
    grid_axis_stability = grid_axis_stability,
    loco_axis_stability = refit_axis_rows,
    spatial_block_cv = spatial_block_cv,
    spatial_block_summary = spatial_block_summary,
    reference_axis = tibble(
      metric = c("Speed-change", "Late-minus-early"),
      pc2_weight = c(reference$speed_axis$direction[["pc2"]], reference$late_axis$direction[["pc2"]]),
      pc3_weight = c(reference$speed_axis$direction[["pc3"]], reference$late_axis$direction[["pc3"]]),
      r_squared = c(reference$speed_axis$r_squared, reference$late_axis$r_squared),
      n_cells = c(reference$speed_axis$n_cells, reference$late_axis$n_cells)
    ),
    axis_agreement = loading_cosine(reference$speed_axis$axis_loading, reference$late_axis$axis_loading)
  )
}
