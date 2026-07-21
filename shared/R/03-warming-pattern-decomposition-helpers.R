# Rendering-time preparation for spatially balanced PCA chapter.

prepare_pca_data <- function(data_dir = data) {
  pca_dir <- file.path(data_dir, "16-spatial-balanced-pca", "output", "sinlat_equalarea_72x21_mean")
  lake_meta_data <- read_csv(file.path(data_dir, "00-lake-metadata", "output", "lake_metadata.csv"), show_col_types = FALSE)
  pca_variance <- read_csv(file.path(pca_dir, "pca_variance.csv"), show_col_types = FALSE)
  pca_loadings <- read_csv(file.path(pca_dir, "pca_loadings.csv"), show_col_types = FALSE)
  pca_scores <- read_csv(file.path(pca_dir, "lake_projected_scores.csv"), show_col_types = FALSE)
  pca_cell_scores <- read_csv(file.path(pca_dir, "spatial_cell_scores.csv"), show_col_types = FALSE)
  loading_plot_data <- pca_loadings |>
    pivot_longer(cols = starts_with("pc"), names_to = "component", values_to = "loading") |>
    filter(component %in% paste0("pc", 1:5)) |>
    mutate(
      component_group = case_when(
        component == "pc1" ~ "PC1",
        component %in% c("pc2", "pc3") ~ "PC2–PC3",
        .default = "PC4–PC5"
      ),
      component = factor(component, levels = paste0("pc", 1:5),
        labels = paste0("PC", 1:5, " (", round(pca_variance$explained_variance[1:5] * 100, 1), "%)")),
      is_positive = loading > 0,
    )

  prepare_pca_score_map_data <- function(pc_col) {
    grid_data <- pca_scores |>
      mutate(lon_cell = floor(lon), lat_cell = floor(lat)) |>
      group_by(lon_cell, lat_cell) |>
      summarise(score = mean(.data[[pc_col]], na.rm = TRUE), n_lakes = n(), .groups = "drop") |>
      filter(n_lakes >= 3)
    lower <- quantile(grid_data$score, .02, na.rm = TRUE)
    upper <- quantile(grid_data$score, .98, na.rm = TRUE)
    list(data = grid_data |> mutate(score_clamped = pmax(pmin(score, upper), lower)),
      limit = max(abs(lower), abs(upper)))
  }

  # Match the canonical 72 × 21 sin(latitude) equal-area PCA grid.
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

  pc_mode_composition <- pca_cell_scores |>
    select(cell_id, lon_bin, sinlat_bin, lon, lat, n_lakes, all_of(paste0("pc", 1:5))) |>
    mutate(total_energy = rowSums(across(all_of(paste0("pc", 1:5)))^2)) |>
    pivot_longer(starts_with("pc"), names_to = "component", values_to = "score") |>
    mutate(
      relative_energy = score^2 / total_energy,
      component = factor(component, levels = paste0("pc", 1:5), labels = paste0("PC", 1:5))
    )

  pc_mode_dominance <- pc_mode_composition |>
    group_by(cell_id, lon_bin, sinlat_bin, lon, lat, n_lakes) |>
    summarise(
      pc1_energy_fraction = relative_energy[component == "PC1"],
      secondary_energy_fraction = 1 - pc1_energy_fraction,
      effective_mode_count = exp(-sum(relative_energy * log(pmax(relative_energy, .Machine$double.eps)))),
      .groups = "drop"
    )

  # Spatial continuity is not the same as a unique regional type. These
  # diagnostics look for score-vector similarity among cells that are far
  # apart, using all five retained PC scores after standardisation.
  pc_cols <- paste0("pc", 1:5)
  score_matrix <- as.matrix(pca_cell_scores[, pc_cols])
  score_z <- scale(score_matrix)
  pair_index <- which(upper.tri(matrix(0, nrow(score_z), nrow(score_z))), arr.ind = TRUE)
  haversine_km <- function(lon1, lat1, lon2, lat2) {
    rad <- pi / 180
    dlat <- (lat2 - lat1) * rad; dlon <- (lon2 - lon1) * rad
    a <- sin(dlat / 2)^2 + cos(lat1 * rad) * cos(lat2 * rad) * sin(dlon / 2)^2
    6371 * 2 * atan2(sqrt(a), sqrt(1 - a))
  }
  pair_scores <- tibble(
    cell_a = pair_index[, 1], cell_b = pair_index[, 2],
    distance_km = haversine_km(
      pca_cell_scores$lon[pair_index[, 1]], pca_cell_scores$lat[pair_index[, 1]],
      pca_cell_scores$lon[pair_index[, 2]], pca_cell_scores$lat[pair_index[, 2]]
    ),
    score_distance = sqrt(rowSums((score_z[pair_index[, 1], , drop = FALSE] -
      score_z[pair_index[, 2], , drop = FALSE])^2))
  ) |>
    left_join(pca_cell_scores |> transmute(cell_a = cell_id, lon_a = lon, lat_a = lat, n_lakes_a = n_lakes), by = "cell_a") |>
    left_join(pca_cell_scores |> transmute(cell_b = cell_id, lon_b = lon, lat_b = lat, n_lakes_b = n_lakes), by = "cell_b")
  distant_similarity_pairs <- pair_scores |>
    filter(distance_km >= 3000) |>
    arrange(score_distance, desc(distance_km)) |>
    slice_head(n = 12)
  distant_similarity_summary <- pair_scores |>
    filter(distance_km >= 3000) |>
    summarise(
      n_remote_pairs = n(),
      score_distance_q05 = quantile(score_distance, .05),
      best_score_distance = min(score_distance),
      best_distance_km = distance_km[which.min(score_distance)]
    )

  neighbour_pair_rows <- bind_rows(lapply(pc_cols, function(pc_col) {
    cells <- pca_cell_scores |> select(lon_bin, sinlat_bin, score = all_of(pc_col))
    east <- inner_join(mutate(cells, lon_bin = lon_bin + 1L), cells,
      by = c("lon_bin", "sinlat_bin"), suffix = c("_a", "_b"))
    north <- inner_join(mutate(cells, sinlat_bin = sinlat_bin + 1L), cells,
      by = c("lon_bin", "sinlat_bin"), suffix = c("_a", "_b"))
    tibble(component = toupper(pc_col), neighbour_correlation = cor(
      c(east$score_a, north$score_a), c(east$score_b, north$score_b)
    ), n_pairs = nrow(east) + nrow(north))
  }))
  loco_subspace_stability <- read_csv(file.path(pca_dir, "loco_subspace_stability.csv"), show_col_types = FALSE)

  aggregate_cell_anomalies <- function(path) {
    wide <- read_csv(path, show_col_types = FALSE)
    year_cols <- names(wide)[4:ncol(wide)]
    baseline_cols <- year_cols[year_cols %in% as.character(1981:1990)]
    length(baseline_cols) == 10 || stop("Expected 1981–1990 baseline columns: ", path)
    baseline <- rowMeans(as.matrix(wide[, baseline_cols]), na.rm = TRUE)
    wide |>
      mutate(.baseline = baseline) |>
      mutate(across(all_of(year_cols), ~ .x - .baseline)) |>
      select(-.baseline) |>
      assign_pca_cell() |>
      group_by(lon_bin, sinlat_bin) |>
      summarise(across(all_of(year_cols), ~ mean(.x, na.rm = TRUE)), .groups = "drop") |>
      pivot_longer(all_of(year_cols), names_to = "year", values_to = "anomaly") |>
      mutate(year = as.integer(year))
  }

  make_pole_composites <- function(cell_trajectories, representation) {
    memberships <- lapply(paste0("pc", 1:5), function(pc_col) {
      q <- quantile(pca_cell_scores[[pc_col]], c(.2, .8), na.rm = TRUE)
      pca_cell_scores |>
        transmute(
          lon_bin, sinlat_bin,
          component = toupper(pc_col),
          pole = case_when(
            .data[[pc_col]] <= q[[1]] ~ "Lower-score pole",
            .data[[pc_col]] >= q[[2]] ~ "Higher-score pole",
            .default = NA_character_
          )
        ) |>
        filter(!is.na(pole))
    }) |>
      bind_rows()
    cell_trajectories |>
      inner_join(memberships, by = c("lon_bin", "sinlat_bin"), relationship = "many-to-many") |>
      group_by(component, pole, year) |>
      summarise(
        anomaly_mean = mean(anomaly, na.rm = TRUE),
        anomaly_q25 = quantile(anomaly, .25, na.rm = TRUE),
        anomaly_q75 = quantile(anomaly, .75, na.rm = TRUE),
        n_cells = n(),
        .groups = "drop"
      ) |>
      mutate(representation = representation)
  }

  raw_cell_trajectories <- aggregate_cell_anomalies(
    file.path(data_dir, "02-annual-temperature", "output", "annual_mean_temperature.csv")
  )
  stl_cell_trajectories <- aggregate_cell_anomalies(
    file.path(data_dir, "05-annual-stl-trend", "output", "period12_robustfalse_ni5_no0_nt99", "annual_stl_trend.csv")
  )
  pc_pole_composites <- bind_rows(
    make_pole_composites(raw_cell_trajectories, "Raw annual LSWT"),
    make_pole_composites(stl_cell_trajectories, "STL trend")
  ) |>
    mutate(
      component = factor(component, levels = paste0("PC", 1:5)),
      pole = factor(pole, levels = c("Lower-score pole", "Higher-score pole")),
      representation = factor(representation, levels = c("STL trend", "Raw annual LSWT"))
    )

  list(
    lake_meta_data = lake_meta_data,
    pca_variance = pca_variance,
    pca_loadings = pca_loadings,
    pca_scores = pca_scores,
    pca_cell_scores = pca_cell_scores,
    pc_mode_composition = pc_mode_composition,
    pc_mode_dominance = pc_mode_dominance,
    distant_similarity_pairs = distant_similarity_pairs,
    distant_similarity_summary = distant_similarity_summary,
    neighbour_pair_rows = neighbour_pair_rows,
    loco_subspace_stability = loco_subspace_stability,
    pc_pole_composites = pc_pole_composites,
    loading_plot_data = loading_plot_data,
    pc_scatter_data = pca_scores |> filter(is.finite(pc1), is.finite(pc2)),
    prepare_pca_score_map_data = prepare_pca_score_map_data,
    scree_data = pca_variance |> filter(pc <= 10) |> mutate(is_main = pc <= 5),
    var_pc1 = pca_variance |> filter(pc == 1) |> pull(explained_variance),
    cumvar_pc5 = pca_variance |> filter(pc == 5) |> pull(cumulative_explained_variance)
  )
}
