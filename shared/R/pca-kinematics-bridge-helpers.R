# Rendering-time preparation for the PCA--raw-kinematics bridge.
# Depends on figure-style.R having been sourced.

prepare_pca_kinematics_bridge_data <- function(data_dir = data) {
  pca_dir <- file.path(data_dir, "16-spatial-balanced-pca", "output", "sinlat_equalarea_72x21_mean")
  metric_dir <- file.path(data_dir, "06-lake-warming-metrics", "output", "period12_robustfalse_ni5_no0_nt99")
  trajectory_dir <- file.path(data_dir, "14-trajectory-diagnostics", "output")

  cell_scores <- read_csv(
    file.path(pca_dir, "spatial_cell_scores.csv"),
    show_col_types = FALSE
  ) |>
    select(cell_id, lon_bin, sinlat_bin, lon, lat, n_lakes, all_of(paste0("pc", 1:5)))
  long_warming <- read_csv(
    file.path(metric_dir, "lake_warming_metrics.csv"),
    show_col_types = FALSE,
    col_select = c(lake_id, lat, lon, raw_annual_mean_temp_sen_slope_40yr)
  ) |>
    transmute(lake_id, lat, lon, long_warming_decade = raw_annual_mean_temp_sen_slope_40yr / 4)
  speed_change <- read_csv(
    file.path(trajectory_dir, "trajectory_diagnostics.csv"),
    show_col_types = FALSE,
    col_select = c(lake_id, annual_roll10_sen_accel_1e3)
  ) |>
    rename(speed_change_1e3 = annual_roll10_sen_accel_1e3)
  rolling_speed <- read_csv(
    file.path(trajectory_dir, "rolling_sen_speed_10yr.csv"),
    show_col_types = FALSE
  ) |>
    select(lake_id, matches("^X?\\d{4}$")) |>
    pivot_longer(matches("^X?\\d{4}$"), names_to = "year", values_to = "speed") |>
    mutate(year = as.integer(sub("^X", "", year)))

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

  lake_speed_summary <- rolling_speed |>
    group_by(lake_id) |>
    summarise(
      speed_mean = mean(speed, na.rm = TRUE),
      speed_sd = sd(speed, na.rm = TRUE),
      speed_positive_fraction = mean(speed > 0, na.rm = TRUE),
      speed_early = median(speed[between(year, 1990, 1999)], na.rm = TRUE),
      speed_late = median(speed[between(year, 2011, 2020)], na.rm = TRUE),
      speed_late_minus_early = speed_late - speed_early,
      .groups = "drop"
    ) |>
    mutate(across(-lake_id, ~ ifelse(is.finite(.x), .x, NA_real_)))

  lake_kinematics <- long_warming |>
    inner_join(speed_change, by = "lake_id") |>
    inner_join(lake_speed_summary, by = "lake_id")

  cell_kinematics <- lake_kinematics |>
    assign_pca_cell() |>
    group_by(lon_bin, sinlat_bin) |>
    summarise(
      n_lakes_kinematics = n(),
      across(
        c(long_warming_decade, speed_change_1e3, speed_mean, speed_sd,
          speed_positive_fraction, speed_early, speed_late, speed_late_minus_early),
        ~ mean(.x, na.rm = TRUE)
      ),
      .groups = "drop"
    ) |>
    inner_join(cell_scores, by = c("lon_bin", "sinlat_bin")) |>
    mutate(long_warming_quintile = ntile(long_warming_decade, 5))

  mode_composition <- cell_scores |>
    pivot_longer(starts_with("pc"), names_to = "component", values_to = "score") |>
    group_by(cell_id) |>
    mutate(relative_energy = score^2 / sum(score^2)) |>
    ungroup()
  mode_dominance <- mode_composition |>
    group_by(cell_id) |>
    summarise(
      pc1_energy_fraction = relative_energy[component == "pc1"],
      secondary_energy_fraction = 1 - pc1_energy_fraction,
      effective_mode_count = exp(-sum(relative_energy * log(pmax(relative_energy, .Machine$double.eps)))),
      .groups = "drop"
    )
  composition_kinematics <- mode_dominance |>
    inner_join(cell_kinematics, by = "cell_id")

  metric_labels <- c(
    long_warming_decade = "Long-term warming",
    speed_mean = "Mean 10-year speed",
    speed_sd = "10-year speed variability",
    speed_positive_fraction = "Warming-speed endpoint fraction",
    speed_change_1e3 = "Warming-speed change",
    speed_late_minus_early = "Late minus early speed"
  )
  overall_associations <- tidyr::crossing(
    component = paste0("pc", 1:5), metric = names(metric_labels)
  ) |>
    rowwise() |>
    mutate(
      n_cells = sum(is.finite(cell_kinematics[[component]]) & is.finite(cell_kinematics[[metric]])),
      spearman = cor(cell_kinematics[[component]], cell_kinematics[[metric]],
        method = "spearman", use = "complete.obs"
      )
    ) |>
    ungroup() |>
    mutate(
      component = factor(component, levels = paste0("pc", 1:5), labels = paste0("PC", 1:5)),
      metric = factor(metric, levels = names(metric_labels), labels = unname(metric_labels))
    )

  within_warming_quintile <- cell_kinematics |>
    group_by(long_warming_quintile) |>
    group_modify(\(data, key) {
      tidyr::crossing(
        component = paste0("pc", 1:5),
        metric = c("speed_change_1e3", "speed_late_minus_early", "speed_sd")
      ) |>
        rowwise() |>
        mutate(
          n_cells = sum(is.finite(data[[component]]) & is.finite(data[[metric]])),
          spearman = cor(data[[component]], data[[metric]], method = "spearman", use = "complete.obs")
        ) |>
        ungroup()
    }) |>
    ungroup() |>
    mutate(
      component = factor(component, levels = paste0("pc", 1:5), labels = paste0("PC", 1:5)),
      metric = factor(metric, levels = c("speed_change_1e3", "speed_late_minus_early", "speed_sd"),
        labels = c("Warming-speed change", "Late minus early speed", "Speed variability"))
    )

  composition_metric_labels <- c(
    long_warming_decade = "Long-term warming",
    speed_mean = "Mean 10-year speed",
    speed_sd = "10-year speed variability",
    speed_positive_fraction = "Warming-speed endpoint fraction",
    speed_change_1e3 = "Warming-speed change"
  )
  composition_associations <- tidyr::crossing(
    composition = c("pc1_energy_fraction", "secondary_energy_fraction", "effective_mode_count"),
    metric = names(composition_metric_labels)
  ) |>
    rowwise() |>
    mutate(
      n_cells = sum(is.finite(composition_kinematics[[composition]]) & is.finite(composition_kinematics[[metric]])),
      spearman = cor(composition_kinematics[[composition]], composition_kinematics[[metric]],
        method = "spearman", use = "complete.obs"
      )
    ) |>
    ungroup() |>
    mutate(
      composition = factor(composition,
        levels = c("pc1_energy_fraction", "secondary_energy_fraction", "effective_mode_count"),
        labels = c("PC1 relative energy", "Secondary relative energy", "Effective mode count")
      ),
      metric = factor(metric, levels = names(composition_metric_labels), labels = unname(composition_metric_labels))
    )

  # A deliberately strict cross-geography check. Raw local-rate poles are
  # defined before looking at PCA contributions. The PC2--PC3 reconstruction
  # is rotation-invariant within that subspace, so a LOCO failure cannot be
  # repaired by relabelling PC2 and PC3.
  rate_poles <- cell_kinematics |>
    select(cell_id, speed_late_minus_early) |>
    filter(is.finite(speed_late_minus_early)) |>
    mutate(
      quintile = ntile(speed_late_minus_early, 5),
      pole = case_when(
        quintile == 1 ~ "Late-rate weakening",
        quintile == 5 ~ "Late-rate strengthening",
        .default = NA_character_
      )
    ) |>
    filter(!is.na(pole))

  reference_scores <- read_csv(file.path(pca_dir, "spatial_cell_scores.csv"), show_col_types = FALSE) |>
    mutate(omitted_continent = "Reference")
  reference_loadings <- read_csv(file.path(pca_dir, "pca_loadings.csv"), show_col_types = FALSE) |>
    mutate(omitted_continent = "Reference")
  loco_scores <- read_csv(file.path(pca_dir, "loco_refit_cell_scores.csv"), show_col_types = FALSE)
  loco_loadings <- read_csv(file.path(pca_dir, "loco_refit_loadings.csv"), show_col_types = FALSE)

  pc23_loco_rate_poles <- bind_rows(reference_scores, loco_scores) |>
    inner_join(rate_poles, by = "cell_id") |>
    select(omitted_continent, cell_id, pole, pc2, pc3) |>
    pivot_longer(c(pc2, pc3), names_to = "component", values_to = "score") |>
    inner_join(
      bind_rows(reference_loadings, loco_loadings) |>
        select(omitted_continent, year, pc2, pc3) |>
        pivot_longer(c(pc2, pc3), names_to = "component", values_to = "loading"),
      by = c("omitted_continent", "component"), relationship = "many-to-many"
    ) |>
    mutate(
      contribution = score * loading,
      period = case_when(
        between(year, 1990, 1999) ~ "early",
        between(year, 2011, 2020) ~ "late",
        .default = NA_character_
      )
    ) |>
    filter(!is.na(period)) |>
    group_by(omitted_continent, pole, period) |>
    summarise(
      contribution = sum(contribution) / n_distinct(cell_id),
      .groups = "drop"
    ) |>
    pivot_wider(names_from = period, values_from = contribution) |>
    mutate(late_minus_early = late - early) |>
    select(omitted_continent, pole, late_minus_early) |>
    pivot_wider(names_from = pole, values_from = late_minus_early) |>
    mutate(
      pole_contrast = `Late-rate strengthening` - `Late-rate weakening`,
      omitted_continent = factor(omitted_continent,
        levels = c("Reference", "Africa", "Asia", "Europe", "North America", "Oceania", "South America")
      )
    )

  list(
    cell_kinematics = cell_kinematics,
    overall_associations = overall_associations,
    within_warming_quintile = within_warming_quintile,
    composition_kinematics = composition_kinematics,
    composition_associations = composition_associations,
    pc23_loco_rate_poles = pc23_loco_rate_poles
  )
}
