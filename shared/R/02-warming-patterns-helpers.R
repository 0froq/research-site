# Rendering-time preparation for spatially balanced PCA chapter.

prepare_pca_data <- function(data_dir = data) {
  pca_dir <- file.path(data_dir, "16-spatial-balanced-pca", "output", "sinlat_equalarea_72x21_mean")
  lake_meta_data <- read_csv(file.path(data_dir, "00-lake-metadata", "output", "lake_metadata.csv"), show_col_types = FALSE)
  pca_variance <- read_csv(file.path(pca_dir, "pca_variance.csv"), show_col_types = FALSE)
  pca_loadings <- read_csv(file.path(pca_dir, "pca_loadings.csv"), show_col_types = FALSE)
  pca_scores <- read_csv(file.path(pca_dir, "lake_projected_scores.csv"), show_col_types = FALSE)
  cluster_profiles_k5 <- read_csv(file.path(pca_dir, "cluster_profiles_K5.csv"), show_col_types = FALSE) |>
    transmute(cluster = factor(paste0("C", cluster), levels = paste0("C", 1:5)),
      year, anomaly_median = trajectory_median, anomaly_q25 = trajectory_q25, anomaly_q75 = trajectory_q75)
  k_selection_metrics <- read_csv(file.path(pca_dir, "k_selection_metrics.csv"), show_col_types = FALSE)

  loading_plot_data <- pca_loadings |>
    pivot_longer(cols = starts_with("pc"), names_to = "component", values_to = "loading") |>
    filter(component %in% paste0("pc", 1:5)) |>
    mutate(component = factor(component, levels = paste0("pc", 1:5),
      labels = paste0("PC", 1:5, " (", round(pca_variance$explained_variance[1:5] * 100, 1), "%)")),
      is_positive = loading > 0)

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

  list(
    lake_meta_data = lake_meta_data,
    pca_variance = pca_variance,
    pca_loadings = pca_loadings,
    pca_scores = pca_scores,
    loading_plot_data = loading_plot_data,
    cluster_profiles_k5 = cluster_profiles_k5,
    k_selection_metrics = k_selection_metrics,
    pc_scatter_data = pca_scores |> filter(is.finite(pc1), is.finite(pc2)),
    prepare_pca_score_map_data = prepare_pca_score_map_data,
    scree_data = pca_variance |> mutate(is_main = pc <= 5),
    var_pc1 = pca_variance |> filter(pc == 1) |> pull(explained_variance),
    cumvar_pc5 = pca_variance |> filter(pc == 5) |> pull(cumulative_explained_variance)
  )
}
