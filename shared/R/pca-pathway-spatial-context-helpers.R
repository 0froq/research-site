# Rendering-time preparation for descriptive PCA--raw-pathway context figures.
# Depends on figure-style.R having been sourced.

prepare_pca_pathway_spatial_context_data <- function(data_dir = data) {
  pca_dir <- file.path(data_dir, "16-spatial-balanced-pca", "output", "sinlat_equalarea_72x21_mean")
  trajectory_dir <- file.path(data_dir, "14-trajectory-diagnostics", "output")

  cell_scores <- read_csv(
    file.path(pca_dir, "spatial_cell_scores.csv"),
    show_col_types = FALSE
  ) |>
    select(cell_id, lon_bin, sinlat_bin, lon, lat, n_lakes, all_of(paste0("pc", 1:5)))

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

  annual_raw <- read_csv(
    file.path(data_dir, "02-annual-temperature", "output", "annual_mean_temperature.csv"),
    show_col_types = FALSE
  )
  year_cols <- names(annual_raw)[4:ncol(annual_raw)]
  baseline_cols <- as.character(1981:1990)
  stopifnot(all(baseline_cols %in% year_cols))

  raw_cell_trajectory <- annual_raw |>
    mutate(.baseline = rowMeans(as.matrix(pick(all_of(baseline_cols))), na.rm = TRUE)) |>
    mutate(across(all_of(year_cols), ~ .x - .baseline)) |>
    select(-.baseline) |>
    assign_pca_cell() |>
    group_by(lon_bin, sinlat_bin) |>
    summarise(across(all_of(year_cols), ~ mean(.x, na.rm = TRUE)), .groups = "drop") |>
    pivot_longer(all_of(year_cols), names_to = "year", values_to = "raw_anomaly") |>
    mutate(year = as.integer(year))

  rolling_speed <- read_csv(
    file.path(trajectory_dir, "rolling_sen_speed_10yr.csv"),
    show_col_types = FALSE
  ) |>
    select(lake_id, matches("^X?\\d{4}$")) |>
    pivot_longer(matches("^X?\\d{4}$"), names_to = "year", values_to = "speed") |>
    mutate(year = as.integer(sub("^X", "", year)))

  lake_coordinates <- annual_raw |>
    select(lake_id, lon, lat)

  cell_speed <- rolling_speed |>
    inner_join(lake_coordinates, by = "lake_id") |>
    assign_pca_cell() |>
    group_by(lon_bin, sinlat_bin, year) |>
    summarise(speed = mean(speed, na.rm = TRUE), .groups = "drop") |>
    filter(is.finite(speed))

  cell_speed_summary <- cell_speed |>
    group_by(lon_bin, sinlat_bin) |>
    summarise(
      speed_early = median(speed[between(year, 1990, 1999)], na.rm = TRUE),
      speed_late = median(speed[between(year, 2011, 2020)], na.rm = TRUE),
      .groups = "drop"
    ) |>
    mutate(
      late_minus_early_speed = speed_late - speed_early,
      across(everything(), ~ ifelse(is.finite(.x), .x, NA_real_))
    )

  speed_change <- read_csv(
    file.path(trajectory_dir, "trajectory_diagnostics.csv"),
    show_col_types = FALSE,
    col_select = c(lake_id, annual_roll10_sen_accel_1e3)
  ) |>
    inner_join(lake_coordinates, by = "lake_id") |>
    assign_pca_cell() |>
    group_by(lon_bin, sinlat_bin) |>
    summarise(speed_change_1e3 = mean(annual_roll10_sen_accel_1e3, na.rm = TRUE), .groups = "drop")

  cell_context <- cell_scores |>
    inner_join(cell_speed_summary, by = c("lon_bin", "sinlat_bin")) |>
    inner_join(speed_change, by = c("lon_bin", "sinlat_bin"))

  score_poles <- cell_scores |>
    pivot_longer(starts_with("pc"), names_to = "component", values_to = "score") |>
    group_by(component) |>
    mutate(
      q20 = quantile(score, .2, na.rm = TRUE),
      q80 = quantile(score, .8, na.rm = TRUE),
      pole = case_when(
        score <= q20 ~ "Lower-score pole",
        score >= q80 ~ "Higher-score pole",
        .default = NA_character_
      )
    ) |>
    ungroup() |>
    filter(!is.na(pole)) |>
    select(cell_id, lon_bin, sinlat_bin, component, pole)

  pole_raw_trajectory <- raw_cell_trajectory |>
    inner_join(score_poles, by = c("lon_bin", "sinlat_bin"), relationship = "many-to-many") |>
    group_by(component, pole, year) |>
    summarise(
      mean = mean(raw_anomaly, na.rm = TRUE),
      q25 = quantile(raw_anomaly, .25, na.rm = TRUE),
      q75 = quantile(raw_anomaly, .75, na.rm = TRUE),
      n_cells = n(),
      .groups = "drop"
    )

  pole_speed_trajectory <- cell_speed |>
    inner_join(score_poles, by = c("lon_bin", "sinlat_bin"), relationship = "many-to-many") |>
    group_by(component, pole, year) |>
    summarise(
      mean = mean(speed, na.rm = TRUE),
      q25 = quantile(speed, .25, na.rm = TRUE),
      q75 = quantile(speed, .75, na.rm = TRUE),
      n_cells = n(),
      .groups = "drop"
    )

  pole_rate_summary <- cell_context |>
    inner_join(score_poles, by = c("cell_id", "lon_bin", "sinlat_bin")) |>
    group_by(component, pole) |>
    summarise(
      speed_change_1e3 = mean(speed_change_1e3, na.rm = TRUE),
      late_minus_early_speed = mean(late_minus_early_speed, na.rm = TRUE),
      n_cells = n(),
      .groups = "drop"
    ) |>
    pivot_wider(names_from = pole, values_from = c(speed_change_1e3, late_minus_early_speed)) |>
    mutate(
      speed_change_pole_difference = `speed_change_1e3_Higher-score pole` - `speed_change_1e3_Lower-score pole`,
      late_speed_pole_difference = `late_minus_early_speed_Higher-score pole` - `late_minus_early_speed_Lower-score pole`
    ) |>
    select(component, n_cells, speed_change_pole_difference, late_speed_pole_difference)

  map_context <- cell_context |>
    select(cell_id, lon, lat, n_lakes, pc2, pc3, speed_change_1e3, late_minus_early_speed) |>
    pivot_longer(c(pc2, pc3, speed_change_1e3, late_minus_early_speed), names_to = "field", values_to = "value") |>
    group_by(field) |>
    mutate(
      clamp = max(abs(quantile(value, c(.02, .98), na.rm = TRUE))),
      value_clamped = pmax(pmin(value, clamp), -clamp),
      value_display = value_clamped / clamp,
      field = factor(field,
        levels = c("pc2", "pc3", "speed_change_1e3", "late_minus_early_speed"),
        labels = c("PC2 score", "PC3 score", "Warming-speed change", "Late minus early speed")
      )
    ) |>
    ungroup()

  list(
    cell_context = cell_context,
    map_context = map_context,
    pole_raw_trajectory = pole_raw_trajectory |>
      mutate(component = factor(component, levels = paste0("pc", 1:5), labels = paste0("PC", 1:5))),
    pole_speed_trajectory = pole_speed_trajectory |>
      mutate(component = factor(component, levels = paste0("pc", 1:5), labels = paste0("PC", 1:5))),
    pole_rate_summary = pole_rate_summary |>
      mutate(component = factor(component, levels = paste0("pc", 1:5), labels = paste0("PC", 1:5)))
  )
}
