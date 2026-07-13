# Rendering-time preparation for the warming-pattern decomposition chapter.
# Depends on figure-style.R having been sourced.

prepare_pca_data <- function(data_dir = data) {
  pca_dir <- file.path(
    data_dir, "07-warming-response-clustering", "output",
    "stl_trend_period12_robustfalse_ni5_no0_nt99_baseline1981_1990_pca095_k4-8"
  )
  lake_meta_data <- read_csv(
    file.path(data_dir, "00-lake-metadata", "output", "lake_metadata.csv"),
    show_col_types = FALSE
  )
  pca_variance <- read_csv(file.path(pca_dir, "pca_variance.csv"), show_col_types = FALSE)
  pca_loadings <- read_csv(file.path(pca_dir, "pca_loadings.csv"), show_col_types = FALSE)
  pca_scores <- read_csv(file.path(pca_dir, "pca_scores.csv"), show_col_types = FALSE)
  pca_with_meta <- pca_scores |>
    left_join(
      lake_meta_data |> select(lake_id, Continent, Depth_avg, Lake_area, Elevation),
      by = "lake_id"
    ) |>
    mutate(point_size = scales::rescale(sqrt(pmax(Lake_area, 0, na.rm = TRUE)), to = c(0.3, 3)))
  loading_plot_data <- pca_loadings |>
    pivot_longer(cols = starts_with("pc"), names_to = "component", values_to = "loading") |>
    filter(component %in% paste0("pc", 1:5)) |>
    mutate(
      component = factor(
        component, levels = paste0("pc", 1:5),
        labels = paste0("PC", 1:5, " (", round(pca_variance$explained_variance[1:5] * 100, 1), "%)")
      ),
      is_positive = loading > 0
    )
  prepare_pca_score_map_data <- function(pc_col) {
    values <- pca_with_meta[[pc_col]]
    lower <- quantile(values, 0.02, na.rm = TRUE)
    upper <- quantile(values, 0.98, na.rm = TRUE)
    list(
      data = pca_with_meta |> mutate(score_clamped = pmax(pmin(.data[[pc_col]], upper), lower)),
      limit = max(abs(lower), abs(upper))
    )
  }

  predictor_data <- pca_with_meta |>
    transmute(
      lake_id, pc1, pc2, pc3,
      abs_lat = abs(lat), elevation = Elevation,
      log_depth = if_else(!is.na(Depth_avg) & Depth_avg > 0, log10(Depth_avg), NA_real_),
      log_area = if_else(!is.na(Lake_area) & Lake_area > 0, log10(Lake_area), NA_real_),
      continent = factor(
        Continent,
        levels = c("Africa", "Asia", "Europe", "North America", "Oceania", "South America")
      )
    ) |>
    filter(if_all(c(pc1, pc2, pc3, abs_lat, elevation, log_depth, log_area, continent), ~ !is.na(.x)))
  predictor_terms <- c("abs_lat", "elevation", "log_depth", "log_area", "continent")

  run_pc_regression <- function(pc_col) {
    model <- lm(reformulate(predictor_terms, response = pc_col), data = predictor_data)
    model_summary <- summary(model)
    tibble(
      pc = toupper(pc_col), term = rownames(model_summary$coefficients),
      estimate = model_summary$coefficients[, "Estimate"],
      std.error = model_summary$coefficients[, "Std. Error"],
      statistic = model_summary$coefficients[, "t value"],
      p.value = model_summary$coefficients[, "Pr(>|t|)"],
      r_squared = model_summary$r.squared, adj_r_squared = model_summary$adj.r.squared,
      n = nobs(model)
    )
  }
  regression_coefficients <- bind_rows(
    run_pc_regression("pc1"), run_pc_regression("pc2"), run_pc_regression("pc3")
  )
  partial_r2_all <- bind_rows(lapply(c("pc1", "pc2", "pc3"), function(pc_col) {
    full_model <- lm(reformulate(predictor_terms, response = pc_col), data = predictor_data)
    full_r2 <- summary(full_model)$r.squared
    groups <- list(
      Latitude = "abs_lat", Elevation = "elevation", Depth = "log_depth",
      Area = "log_area", Continent = "continent"
    )
    bind_rows(lapply(names(groups), function(group_name) {
      reduced_model <- lm(
        reformulate(setdiff(predictor_terms, groups[[group_name]]), response = pc_col),
        data = predictor_data
      )
      tibble(
        pc = toupper(pc_col), predictor = group_name,
        partial_r2 = full_r2 - summary(reduced_model)$r.squared
      )
    }))
  }))

  coefficient_cell <- function(pc, term) {
    row <- regression_coefficients |>
      filter(.data$pc == .env$pc, .data$term == .env$term)
    if (nrow(row) != 1) return("—")
    stars <- case_when(
      row$p.value < 0.001 ~ "***", row$p.value < 0.01 ~ "**",
      row$p.value < 0.05 ~ "*", TRUE ~ ""
    )
    digits <- if (row$term == "elevation") 6 else 3
    paste0(sprintf(paste0("%+.", digits, "f"), row$estimate), stars)
  }
  r2_cell <- function(pc) {
    row <- regression_coefficients |> filter(.data$pc == .env$pc) |> slice(1)
    sprintf("%.3f", row$r_squared)
  }
  continent_cell <- function(pc, continent) coefficient_cell(pc, paste0("continent", continent))
  partial_r2_cell <- function(pc, predictor) {
    row <- partial_r2_all |>
      filter(.data$pc == .env$pc, .data$predictor == .env$predictor)
    if (nrow(row) != 1) return("—")
    sprintf("%.3f", row$partial_r2)
  }

  list(
    lake_meta_data = lake_meta_data,
    pca_variance = pca_variance, pca_loadings = pca_loadings,
    pca_scores = pca_scores, pca_with_meta = pca_with_meta,
    scree_data = pca_variance |> mutate(is_main = pc <= 5, pc_label = paste0("PC", pc)),
    loading_plot_data = loading_plot_data,
    pc_scatter_data = pca_with_meta |> filter(!is.na(Continent)),
    prepare_pca_score_map_data = prepare_pca_score_map_data,
    n_pcs_95 = pca_variance |> filter(cumulative_explained_variance >= 0.95) |> slice_min(pc) |> pull(pc),
    var_pc1 = pca_variance |> filter(pc == 1) |> pull(explained_variance),
    var_pc2 = pca_variance |> filter(pc == 2) |> pull(explained_variance),
    var_pc3 = pca_variance |> filter(pc == 3) |> pull(explained_variance),
    var_pc4 = pca_variance |> filter(pc == 4) |> pull(explained_variance),
    var_pc5 = pca_variance |> filter(pc == 5) |> pull(explained_variance),
    cumvar_pc5 = pca_variance |> filter(pc == 5) |> pull(cumulative_explained_variance),
    predictor_data = predictor_data,
    regression_coefficients = regression_coefficients,
    partial_r2_all = partial_r2_all,
    coefficient_cell = coefficient_cell, r2_cell = r2_cell,
    continent_cell = continent_cell, partial_r2_cell = partial_r2_cell
  )
}
