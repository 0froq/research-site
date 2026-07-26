# Rendering-time preparation for Results 3.1--3.2.
# Depends on 01-global-kinematics-helpers.R having been sourced.

prepare_results_kinematics_data <- function(kinematics = prepare_kinematics_data()) {
  metrics <- kinematics$lake_warming_metrics |>
    left_join(
      kinematics$lake_meta_data |>
        select(lake_id, lon, lat, Continent, Lake_name, Country),
      by = "lake_id"
    ) |>
    filter(is.finite(long_term_warming_decade))

  long_term_distribution <- metrics |>
    transmute(warming = long_term_warming_decade)

  sign_summary <- metrics |>
    mutate(direction = if_else(long_term_warming_decade > 0, "Warming", "Cooling")) |>
    count(direction) |>
    mutate(proportion = n / sum(n))
  significance <- read_csv(
    file.path(data_process_dir, "steps", "20-trend-significance", "output", "lake_trend_significance.csv"),
    show_col_types = FALSE
  ) |>
    transmute(
      lake_id,
      significance_class = case_when(
        sen_slope > 0 & mk_p <= 0.05 ~ "Significant warming",
        sen_slope < 0 & mk_p <= 0.05 ~ "Significant cooling",
        .default = "Not significant"
      )
    )
  significance_summary <- significance |>
    count(significance_class) |>
    mutate(proportion = n / sum(n))
  tendency_significance <- metrics |>
    select(lake_id, warming_speed_change) |>
    inner_join(significance, by = "lake_id") |>
    filter(is.finite(warming_speed_change)) |>
    mutate(
      significant_full_trend = significance_class != "Not significant",
      tendency_quartile = ntile(warming_speed_change, 4),
      absolute_tendency_quartile = ntile(abs(warming_speed_change), 4)
    )
  significance_grid <- significance |>
    left_join(kinematics$lake_meta_data |> select(lake_id, lon, lat), by = "lake_id") |>
    filter(is.finite(lon), is.finite(lat), between(lat, -60, 85)) |>
    mutate(lon_cell = floor(lon), lat_cell = floor(lat)) |>
    count(lon_cell, lat_cell, significance_class) |>
    group_by(lon_cell, lat_cell) |>
    mutate(proportion = n / sum(n)) |>
    ungroup()

  # Two-layer area-weighted comparator. First, reconstruct one annual series
  # per 1° cell from lake-area weighted temperatures. Then estimate its Sen
  # slope and weight the resulting cell distribution by spherical cell area.
  # This is deliberately not an area-weighted average of lake-level slopes.
  lake_area <- kinematics$lake_meta_data |>
    select(lake_id, Lake_area) |>
    mutate(Lake_area = if_else(is.finite(Lake_area) & Lake_area > 0, Lake_area, NA_real_))
  annual_with_area <- kinematics$raw_annual |>
    left_join(kinematics$lake_meta_data |> select(lake_id, lon, lat), by = "lake_id") |>
    left_join(lake_area, by = "lake_id") |>
    filter(is.finite(lon), is.finite(lat), is.finite(Lake_area), between(lat, -60, 85)) |>
    mutate(lon_cell = floor(lon), lat_cell = floor(lat))
  annual_year_cols <- names(annual_with_area)[grepl("^X?\\d{4}$", names(annual_with_area))]
  sen_slope <- function(x) {
    x <- x[is.finite(x)]
    n <- length(x)
    if (n < 10) return(NA_real_)
    median(outer(x, x, "-")[upper.tri(matrix(0, n, n))] /
      outer(seq_len(n), seq_len(n), "-")[upper.tri(matrix(0, n, n))])
  }
  weighted_cell_slopes <- annual_with_area |>
    group_by(lon_cell, lat_cell) |>
    summarise(
      n_lakes = n(),
      across(all_of(annual_year_cols), ~ weighted.mean(.x, Lake_area, na.rm = TRUE)),
      .groups = "drop"
    ) |>
    rowwise() |>
    mutate(
      cell_sen_slope_decade = sen_slope(c_across(all_of(annual_year_cols))) * 10,
      cell_area_weight = cos((lat_cell + .5) * pi / 180)
    ) |>
    ungroup() |>
    filter(is.finite(cell_sen_slope_decade), cell_area_weight > 0)
  weighted_quantile <- function(x, w, probs) {
    keep <- is.finite(x) & is.finite(w) & w > 0
    x <- x[keep]; w <- w[keep]
    order_idx <- order(x); x <- x[order_idx]; w <- w[order_idx]
    cum_w <- cumsum(w) / sum(w)
    vapply(probs, function(p) x[which(cum_w >= p)[1]], numeric(1))
  }
  weighted_summary <- weighted_quantile(
    weighted_cell_slopes$cell_sen_slope_decade,
    weighted_cell_slopes$cell_area_weight, c(.25, .5, .75)
  )
  unweighted_skewness <- function(x) {
    x <- x[is.finite(x)]
    mu <- mean(x); m2 <- mean((x - mu)^2)
    mean((x - mu)^3) / m2^(3 / 2)
  }
  weighted_skewness <- function(x, w) {
    keep <- is.finite(x) & is.finite(w) & w > 0
    x <- x[keep]; w <- w[keep] / sum(w[keep])
    mu <- sum(w * x); m2 <- sum(w * (x - mu)^2)
    sum(w * (x - mu)^3) / m2^(3 / 2)
  }
  distribution_skewness <- c(
    lake_equal = unweighted_skewness(long_term_distribution$warming),
    area_weighted = weighted_skewness(weighted_cell_slopes$cell_sen_slope_decade, weighted_cell_slopes$cell_area_weight)
  )
  fig1_grid <- metrics |>
    filter(is.finite(lon), is.finite(lat), between(lat, -60, 85)) |>
    mutate(lon_cell = floor(lon), lat_cell = floor(lat)) |>
    group_by(lon_cell, lat_cell) |>
    summarise(lake_equal_sen_decade = mean(long_term_warming_decade), n_lakes = n(), .groups = "drop") |>
    left_join(
      significance |>
        left_join(kinematics$lake_meta_data |> select(lake_id, lon, lat), by = "lake_id") |>
        filter(is.finite(lon), is.finite(lat), between(lat, -60, 85)) |>
        mutate(lon_cell = floor(lon), lat_cell = floor(lat), is_significant = significance_class != "Not significant") |>
        group_by(lon_cell, lat_cell) |>
        summarise(significant_share = mean(is_significant), .groups = "drop"),
      by = c("lon_cell", "lat_cell")
    ) |>
    mutate(hatch = significant_share >= 1 / 2)

  local_rate_tendency_grid <- metrics |>
    filter(is.finite(lon), is.finite(lat), between(lat, -60, 85), is.finite(warming_speed_change)) |>
    mutate(lon_cell = floor(lon), lat_cell = floor(lat)) |>
    group_by(lon_cell, lat_cell) |>
    summarise(
      local_rate_tendency = mean(warming_speed_change),
      n_lakes = n(),
      .groups = "drop"
    )

  # Spatial autocorrelation is evaluated on the occupied 1° descriptive grid
  # used in Fig. 1. Queen neighbours share an edge or corner. This diagnoses
  # spatial organisation only; it is not a model of a spatial process.
  grid_nodes <- fig1_grid |>
    mutate(cell_id = row_number())
  neighbour_offsets <- tidyr::crossing(dx = -1:1, dy = -1:1) |>
    filter(dx != 0 | dy != 0)
  grid_edges <- neighbour_offsets |>
    tidyr::crossing(grid_nodes |>
      select(cell_id, lon_cell, lat_cell) |>
      rename(i = cell_id)) |>
    transmute(i, lon_cell = lon_cell + dx, lat_cell = lat_cell + dy) |>
    inner_join(
      grid_nodes |>
        select(cell_id, lon_cell, lat_cell) |>
        rename(j = cell_id),
      by = c("lon_cell", "lat_cell")
    ) |>
    filter(i < j) |>
    distinct(i, j)
  moran_i <- function(x, edges) {
    z <- x - mean(x)
    n <- length(z)
    w <- nrow(edges)
    (n / (2 * w)) * sum(z[edges$i] * z[edges$j]) / sum(z^2)
  }
  observed_moran_i <- moran_i(grid_nodes$lake_equal_sen_decade, grid_edges)
  set.seed(20260726)
  null_moran_i <- replicate(
    999,
    moran_i(sample(grid_nodes$lake_equal_sen_decade), grid_edges)
  )
  spatial_autocorrelation <- tibble(
    n_cells = nrow(grid_nodes),
    n_neighbour_pairs = nrow(grid_edges),
    moran_i = observed_moran_i,
    permutation_p = (sum(abs(null_moran_i) >= abs(observed_moran_i)) + 1) / 1000
  )

  latitude_summary <- metrics |>
    mutate(
      latitude_band = cut(
        lat, breaks = c(-60, -30, 0, 30, 60, 85), include.lowest = TRUE,
        labels = c("60–30°S", "30°S–0°", "0–30°N", "30–60°N", "60–85°N")
      )
    ) |>
    filter(!is.na(latitude_band))

  continent_summary <- metrics |>
    filter(!is.na(Continent)) |>
    mutate(Continent = factor(Continent, levels = c(
      "Africa", "Asia", "Europe", "North America", "Oceania", "South America"
    ))) |>
    filter(!is.na(Continent))

  # Detrended residual variability separates year-to-year departures from
  # each lake's Theil–Sen long-term drift. The ratio retains the scale of the
  # original annual series: 1 means residual variation is as large as the
  # full within-record standard deviation.
  annual_year_cols <- names(kinematics$raw_annual)[grepl("^X?\\d{4}$", names(kinematics$raw_annual))]
  annual_years <- as.integer(sub("^X", "", annual_year_cols))
  annual_values <- as.matrix(kinematics$raw_annual |> select(all_of(annual_year_cols)))
  full_pair_index <- combn(seq_along(annual_years), 2)
  full_time_difference <- annual_years[full_pair_index[1, ]] - annual_years[full_pair_index[2, ]]
  sen_detrended_sd <- function(x) {
    keep <- is.finite(x)
    if (sum(keep) < 10) return(c(residual_sd = NA_real_, annual_sd = NA_real_))
    y <- x[keep]
    t <- annual_years[keep]
    if (all(keep)) {
      slope <- median((y[full_pair_index[1, ]] - y[full_pair_index[2, ]]) / full_time_difference)
    } else {
      pair_index <- combn(seq_along(y), 2)
      slope <- median((y[pair_index[1, ]] - y[pair_index[2, ]]) /
        (t[pair_index[1, ]] - t[pair_index[2, ]]))
    }
    intercept <- median(y - slope * t)
    c(residual_sd = sd(y - (intercept + slope * t)), annual_sd = sd(y))
  }
  residual_stats <- vapply(seq_len(nrow(annual_values)), function(i) {
    sen_detrended_sd(annual_values[i, ])
  }, numeric(2)) |>
    t() |>
    as.data.frame() |>
    as_tibble() |>
    mutate(lake_id = kinematics$raw_annual$lake_id, .before = 1)
  residual_variability <- metrics |>
    select(lake_id, long_term_warming_decade) |>
    inner_join(residual_stats, by = "lake_id") |>
    filter(is.finite(residual_sd), is.finite(annual_sd), annual_sd > 0) |>
    mutate(
      residual_fraction = residual_sd / annual_sd,
      warming_quartile = factor(
        ntile(long_term_warming_decade, 4),
        levels = 1:4,
        labels = c("Q1: cooling / slowest", "Q2", "Q3", "Q4: fastest")
      )
    )
  residual_summary <- residual_variability |>
    group_by(warming_quartile) |>
    summarise(
      n = n(),
      median_residual_sd = median(residual_sd),
      median_annual_sd = median(annual_sd),
      median_residual_fraction = median(residual_fraction),
      q25_residual_fraction = quantile(residual_fraction, .25),
      q75_residual_fraction = quantile(residual_fraction, .75),
      .groups = "drop"
    )

  rate_tendency_distribution <- metrics |>
    transmute(rate_tendency = warming_speed_change)

  speed_time_distribution <- kinematics$rolling_speed |>
    pivot_longer(matches("^X?\\d{4}$"), names_to = "year", values_to = "speed") |>
    mutate(year = as.integer(sub("^X", "", year))) |>
    filter(is.finite(speed)) |>
    group_by(year) |>
    summarise(
      q05 = quantile(speed, .05), q25 = quantile(speed, .25), median = median(speed),
      q75 = quantile(speed, .75), q95 = quantile(speed, .95),
      prop_positive = mean(speed > 0), .groups = "drop"
    )
  read_window_summary <- function(path, label) {
    read_csv(path, show_col_types = FALSE) |>
      select(matches("^X?\\d{4}$")) |>
      pivot_longer(everything(), names_to = "year", values_to = "speed") |>
      mutate(year = as.integer(sub("^X", "", year)), window = label) |>
      filter(is.finite(speed)) |>
      group_by(window, year) |>
      summarise(median = median(speed), q25 = quantile(speed, .25), q75 = quantile(speed, .75), .groups = "drop")
  }
  window_summary <- bind_rows(
    read_window_summary(file.path(data, "14-trajectory-diagnostics", "output", "rolling_sen_speed_7yr.csv"), "7-year"),
    read_window_summary(file.path(data, "14-trajectory-diagnostics", "output", "rolling_sen_speed_10yr.csv"), "10-year")
  )

  # Representative paths are selected from lakes with comparable net warming:
  # the central decile of the long-term slope distribution. The four examples
  # are then selected by pre-specified, contrasting local-rate descriptors.
  central_limits <- quantile(metrics$long_term_warming_decade, c(.45, .55), na.rm = TRUE)
  speed_long <- kinematics$rolling_speed |>
    pivot_longer(matches("^X?\\d{4}$"), names_to = "year", values_to = "speed") |>
    mutate(year = as.integer(sub("^X", "", year))) |>
    filter(is.finite(speed))
  speed_time_long <- speed_long |>
    transmute(year, rate = speed)
  speed_descriptors <- speed_long |>
    group_by(lake_id) |>
    summarise(
      early_rate = mean(speed[year <= 1999], na.rm = TRUE),
      middle_rate = mean(speed[year >= 2000 & year <= 2010], na.rm = TRUE),
      late_rate = mean(speed[year >= 2011], na.rm = TRUE),
      speed_sd = sd(speed, na.rm = TRUE),
      curvature = middle_rate - mean(c(early_rate, late_rate)),
      .groups = "drop"
    ) |>
    filter(if_all(-lake_id, is.finite))
  candidate_paths <- metrics |>
    filter(between(long_term_warming_decade, central_limits[[1]], central_limits[[2]])) |>
    inner_join(speed_descriptors, by = "lake_id") |>
    mutate(rate_difference = late_rate - early_rate)


  # The examples deliberately span distinct rate histories and continents.
  # This is a visual-selection rule only: the examples do not define classes
  # or enter any population-level inference. Lake names never determine
  # membership and only break exact descriptor ties.
  select_extreme <- function(frame, descriptor, direction = c("min", "max")) {
    direction <- match.arg(direction)
    frame <- frame |>
      mutate(has_name = !is.na(Lake_name) & Lake_name != "")
    if (direction == "min") {
      frame <- frame |> arrange(.data[[descriptor]], desc(has_name), lake_id)
    } else {
      frame <- frame |> arrange(desc(.data[[descriptor]]), desc(has_name), lake_id)
    }
    frame |>
      slice_head(n = 1) |>
      select(-has_name)
  }
  relatively_even_choice <- candidate_paths |>
      filter(Continent == "South America", lat < 0) |>
      select_extreme("speed_sd", "min") |>
      mutate(path_type = "Relative even")
  late_warming_choice <- candidate_paths |>
      filter(Continent == "Europe", lon < 60) |>
      select_extreme("warming_speed_change", "max") |>
      mutate(path_type = "Late warming")
  late_cooling_choice <- candidate_paths |>
      filter(Continent == "North America") |>
      select_extreme("warming_speed_change", "min") |>
      mutate(path_type = "Late cooling")
  late_neutral_choice <- candidate_paths |>
      filter(Continent == "Oceania", lat < 0) |>
      mutate(abs_late_rate = abs(late_rate)) |>
      select_extreme("abs_late_rate", "min") |>
      select(-abs_late_rate) |>
      mutate(path_type = "Near-zero late rate")

  chosen_paths <- bind_rows(
    relatively_even_choice,
    late_warming_choice,
    late_cooling_choice,
    late_neutral_choice
  ) |>
    distinct(lake_id, .keep_all = TRUE) |>
    mutate(path_type = factor(path_type, levels = c(
      "Relative even", "Late warming", "Late cooling", "Near-zero late rate"
    ))) |>
    mutate(
      lake_label = if_else(
        !is.na(Lake_name) & Lake_name != "",
        paste0(as.character(path_type), ": ", Lake_name),
        paste0(as.character(path_type), ": unnamed lake ", lake_id, " (", Country, ")")
      ),
      lake_label = factor(lake_label, levels = lake_label[order(path_type)])
    )

  raw_paths <- kinematics$raw_annual |>
    pivot_longer(matches("^X?\\d{4}$"), names_to = "year", values_to = "temperature") |>
    mutate(year = as.integer(sub("^X", "", year))) |>
    inner_join(chosen_paths |> select(lake_id, path_type, lake_label), by = "lake_id") |>
    group_by(lake_id) |>
    mutate(anomaly = temperature - mean(temperature[year <= 1990], na.rm = TRUE)) |>
    ungroup() |>
    filter(is.finite(anomaly))
  selected_rates <- speed_long |>
    inner_join(chosen_paths |> select(lake_id, path_type, lake_label), by = "lake_id")
  sen_fit <- function(year, value) {
    keep <- is.finite(year) & is.finite(value)
    year <- year[keep]; value <- value[keep]
    slopes <- outer(value, value, "-")[upper.tri(matrix(0, length(value), length(value)))] /
      outer(year, year, "-")[upper.tri(matrix(0, length(year), length(year)))]
    slope <- median(slopes, na.rm = TRUE)
    tibble(sen_slope = slope, sen_intercept = median(value - slope * year, na.rm = TRUE))
  }
  raw_sen_lines <- raw_paths |>
    group_by(lake_id, path_type, lake_label) |>
    group_modify(~ sen_fit(.x$year, .x$anomaly)) |>
    ungroup()
  rate_sen_lines <- selected_rates |>
    group_by(lake_id, path_type, lake_label) |>
    group_modify(~ sen_fit(.x$year, .x$speed)) |>
    ungroup()
  example_raw_overlay <- tidyr::crossing(
    raw_paths,
    focus_label = levels(chosen_paths$lake_label)
  ) |>
    mutate(is_focus = as.character(lake_label) == focus_label)
  example_rate_overlay <- tidyr::crossing(
    selected_rates,
    focus_label = levels(chosen_paths$lake_label)
  ) |>
    mutate(is_focus = as.character(lake_label) == focus_label)
  example_raw_sen_lines <- tidyr::crossing(
    raw_sen_lines,
    focus_label = levels(chosen_paths$lake_label)
  ) |>
    mutate(is_focus = as.character(lake_label) == focus_label)
  example_rate_sen_lines <- tidyr::crossing(
    rate_sen_lines,
    focus_label = levels(chosen_paths$lake_label)
  ) |>
    mutate(is_focus = as.character(lake_label) == focus_label)

  list(
    long_term_distribution = long_term_distribution,
    sign_summary = sign_summary,
    significance_summary = significance_summary,
    tendency_significance = tendency_significance,
    significance_grid = significance_grid,
    weighted_cell_slopes = weighted_cell_slopes,
    weighted_summary = weighted_summary,
    distribution_skewness = distribution_skewness,
    fig1_grid = fig1_grid,
    local_rate_tendency_grid = local_rate_tendency_grid,
    latitude_summary = latitude_summary,
    continent_summary = continent_summary,
    spatial_autocorrelation = spatial_autocorrelation,
    residual_variability = residual_variability,
    residual_summary = residual_summary,
    rate_tendency_distribution = rate_tendency_distribution,
    speed_time_distribution = speed_time_distribution,
    speed_time_long = speed_time_long,
    window_summary = window_summary,
    candidate_paths = candidate_paths,
    chosen_paths = chosen_paths,
    raw_paths = raw_paths,
    selected_rates = selected_rates,
    example_lakes = chosen_paths,
    example_raw_overlay = example_raw_overlay,
    example_rate_overlay = example_rate_overlay,
    example_raw_sen_lines = example_raw_sen_lines,
    example_rate_sen_lines = example_rate_sen_lines,
    central_limits = central_limits
  )
}
