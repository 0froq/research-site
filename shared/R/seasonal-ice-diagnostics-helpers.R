# Rendering-time preparation for rolling seasonal, extreme-temperature, and ice diagnostics.
# Depends on figure-style.R having been sourced.

prepare_seasonal_ice_data <- function(data_dir = data) {
  diagnostics_dir <- file.path(data_dir, "14-trajectory-diagnostics", "output")
  dynamics_summary <- read_csv(
    file.path(diagnostics_dir, "rolling_dynamics_summary.csv"),
    show_col_types = FALSE
  )

  alignment_long <- dynamics_summary |>
    select(
      lake_id, lat, lon,
      matches("^annual_rate_spearman_(DJF|MAM|JJA|SON|max30|min30|ice_mean|warm_cold_contrast|seasonal_range|seasonal_sd)$")
    ) |>
    pivot_longer(
      starts_with("annual_rate_spearman_"),
      names_to = "series", values_to = "spearman_alignment"
    ) |>
    mutate(
      series = sub("^annual_rate_spearman_", "", series),
      series = factor(series,
        levels = c("DJF", "MAM", "JJA", "SON", "max30", "min30", "ice_mean", "warm_cold_contrast", "seasonal_range", "seasonal_sd"),
        labels = c("DJF", "MAM", "JJA", "SON", "Max 30-day", "Min 30-day", "Ice duration", "JJA − DJF contrast", "Seasonal range", "Seasonal SD")
      )
    )

  alignment_status_long <- dynamics_summary |>
    select(
      lake_id,
      matches("^annual_rate_spearman_n_overlap_(DJF|MAM|JJA|SON|max30|min30|ice_mean|warm_cold_contrast|seasonal_range|seasonal_sd)$"),
      matches("^annual_rate_spearman_defined_(DJF|MAM|JJA|SON|max30|min30|ice_mean|warm_cold_contrast|seasonal_range|seasonal_sd)$")
    ) |>
    pivot_longer(
      -lake_id,
      names_to = c(".value", "series"),
      names_pattern = "^annual_rate_spearman_(n_overlap|defined)_(.*)$"
    ) |>
    mutate(
      series = factor(series,
        levels = c("DJF", "MAM", "JJA", "SON", "max30", "min30", "ice_mean", "warm_cold_contrast", "seasonal_range", "seasonal_sd"),
        labels = c("DJF", "MAM", "JJA", "SON", "Max 30-day", "Min 30-day", "Ice duration", "JJA − DJF contrast", "Seasonal range", "Seasonal SD")
      )
    )

  # Deterministic visual sample: one point represents roughly 100 lakes.
  alignment_visual_sample <- alignment_long |>
    filter(is.finite(spearman_alignment)) |>
    group_by(series) |>
    group_modify(\(frame, key) slice_sample(
      frame, n = max(1L, ceiling(nrow(frame) / 100))
    )) |>
    ungroup()

  conditional_alignment_long <- dynamics_summary |>
    select(
      lake_id, lat, lon,
      matches("^annual_rate_spearman_(positive_annual|negative_annual)_(DJF|MAM|JJA|SON|max30|min30|warm_cold_contrast|seasonal_range|seasonal_sd|ice_loss_DJF|ice_loss_MAM|ice_loss_JJA|ice_loss_SON)$")
    ) |>
    pivot_longer(
      -c(lake_id, lat, lon),
      names_to = c("annual_state", "series"),
      names_pattern = "^annual_rate_spearman_(positive_annual|negative_annual)_(.*)$",
      values_to = "spearman_alignment"
    ) |>
    mutate(
      annual_state = factor(
        annual_state,
        levels = c("positive_annual", "negative_annual"),
        labels = c("Positive annual rate", "Negative annual rate")
      ),
      family = case_when(
        startsWith(series, "ice_loss_") ~ "Seasonal ice loss",
        series %in% c("warm_cold_contrast", "seasonal_range", "seasonal_sd") ~ "Thermal asymmetry",
        .default = "Temperature"
      ),
      series = sub("^ice_loss_", "", series),
      series = factor(
        series,
        levels = c("DJF", "MAM", "JJA", "SON", "max30", "min30", "warm_cold_contrast", "seasonal_range", "seasonal_sd"),
        labels = c("DJF", "MAM", "JJA", "SON", "Max 30-day", "Min 30-day", "JJA − DJF contrast", "Seasonal range", "Seasonal SD")
      )
    )

  endpoint_change_long <- dynamics_summary |>
    select(lake_id, lat, lon, ends_with("_delta_1990_2020")) |>
    pivot_longer(
      ends_with("_delta_1990_2020"),
      names_to = "series", values_to = "endpoint_change"
    ) |>
    mutate(
      series = sub("_rate_delta_1990_2020$", "", series),
      series = sub("_mean_delta_1990_2020$", "", series),
      series = factor(series,
        levels = c("annual", "DJF", "MAM", "JJA", "SON", "max30", "min30", "ice"),
        labels = c("Annual", "DJF", "MAM", "JJA", "SON", "Max 30-day", "Min 30-day", "Ice duration")
      )
    )

  prepare_alignment_grid <- function(series_name, min_lakes = 3) {
    alignment_long |>
      filter(series == series_name) |>
      mutate(lon_cell = floor(lon), lat_cell = floor(lat)) |>
      group_by(lon_cell, lat_cell) |>
      summarise(
        n_lakes = n(),
        n_defined = sum(is.finite(spearman_alignment)),
        median_alignment = median(spearman_alignment, na.rm = TRUE),
        q25_alignment = quantile(spearman_alignment, .25, na.rm = TRUE),
        q75_alignment = quantile(spearman_alignment, .75, na.rm = TRUE),
        .groups = "drop"
      ) |>
      filter(n_defined >= min_lakes)
  }

  prepare_alignment_grids <- function(min_lakes = 3) {
    series_levels <- levels(alignment_long$series)
    setNames(lapply(series_levels, prepare_alignment_grid, min_lakes = min_lakes), series_levels) |>
      bind_rows(.id = "series") |>
      mutate(series = factor(series, levels = levels(alignment_long$series)))
  }

  prepare_alignment_availability_grids <- function(min_lakes = 3) {
    alignment_long |>
      mutate(is_defined = is.finite(spearman_alignment), lon_cell = floor(lon), lat_cell = floor(lat)) |>
      group_by(series, lon_cell, lat_cell) |>
      summarise(
        n_lakes = n(),
        n_defined = sum(is_defined),
        defined_fraction = n_defined / n_lakes,
        .groups = "drop"
      ) |>
      filter(n_lakes >= min_lakes)
  }

  summarise_alignment <- function() {
    alignment_long |>
      group_by(series) |>
      summarise(
        n_lakes = n(),
        n_defined = sum(is.finite(spearman_alignment)),
        defined_fraction = n_defined / n_lakes,
        median_alignment = median(spearman_alignment, na.rm = TRUE),
        q25_alignment = quantile(spearman_alignment, .25, na.rm = TRUE),
        q75_alignment = quantile(spearman_alignment, .75, na.rm = TRUE),
        .groups = "drop"
      )
  }

  prepare_conditional_alignment_grids <- function(family_name, series_names, min_lakes = 3) {
    conditional_alignment_long |>
      filter(family == family_name, series %in% series_names) |>
      mutate(
        lon_cell = floor(lon), lat_cell = floor(lat),
        is_defined = is.finite(spearman_alignment)
      ) |>
      group_by(annual_state, series, lon_cell, lat_cell) |>
      summarise(
        n_lakes = n(),
        n_defined = sum(is_defined),
        defined_fraction = n_defined / n_lakes,
        median_alignment = median(spearman_alignment, na.rm = TRUE),
        .groups = "drop"
      ) |>
      filter(n_defined >= min_lakes)
  }

  summarise_conditional_alignment <- function(family_name = NULL) {
    out <- conditional_alignment_long
    if (!is.null(family_name)) out <- filter(out, family == family_name)
    out |>
      group_by(annual_state, family, series) |>
      summarise(
        n_lakes = n(),
        n_defined = sum(is.finite(spearman_alignment)),
        defined_fraction = n_defined / n_lakes,
        median_alignment = median(spearman_alignment, na.rm = TRUE),
        q25_alignment = quantile(spearman_alignment, .25, na.rm = TRUE),
        q75_alignment = quantile(spearman_alignment, .75, na.rm = TRUE),
        .groups = "drop"
      )
  }

  thermal_state_long <- dynamics_summary |>
    select(
      lake_id, lat, lon,
      matches("^(positive_annual|negative_annual)_(warm_cold_contrast|seasonal_range|seasonal_sd)_(n_endpoints|median_rate|positive_fraction)$")
    ) |>
    pivot_longer(
      -c(lake_id, lat, lon),
      names_to = c("annual_state", "diagnostic", ".value"),
      names_pattern = "^(positive_annual|negative_annual)_(warm_cold_contrast|seasonal_range|seasonal_sd)_(n_endpoints|median_rate|positive_fraction)$"
    ) |>
    mutate(
      annual_state = factor(
        annual_state,
        levels = c("positive_annual", "negative_annual"),
        labels = c("Positive annual rate", "Negative annual rate")
      ),
      diagnostic = factor(
        diagnostic,
        levels = c("warm_cold_contrast", "seasonal_range", "seasonal_sd"),
        labels = c("JJA − DJF contrast", "Seasonal range", "Seasonal SD")
      )
    )

  prepare_thermal_state_grid <- function(diagnostics, min_lakes = 3) {
    thermal_state_long |>
      filter(diagnostic %in% diagnostics, n_endpoints > 0) |>
      mutate(lon_cell = floor(lon), lat_cell = floor(lat)) |>
      group_by(annual_state, diagnostic, lon_cell, lat_cell) |>
      summarise(
        n_lakes = n(),
        median_rate = median(median_rate, na.rm = TRUE),
        positive_rate_fraction = median(positive_fraction, na.rm = TRUE),
        .groups = "drop"
      ) |>
      filter(n_lakes >= min_lakes)
  }

  summarise_thermal_state <- function() {
    thermal_state_long |>
      filter(n_endpoints > 0) |>
      group_by(annual_state, diagnostic) |>
      summarise(
        n_lakes = n(),
        median_endpoint_rate = median(median_rate, na.rm = TRUE),
        q25_endpoint_rate = quantile(median_rate, .25, na.rm = TRUE),
        q75_endpoint_rate = quantile(median_rate, .75, na.rm = TRUE),
        median_positive_fraction = median(positive_fraction, na.rm = TRUE),
        .groups = "drop"
      )
  }

  prepare_ice_alignment_pair <- function(first_season, second_season) {
    first_name <- paste0("annual_rate_spearman_ice_loss_", first_season)
    second_name <- paste0("annual_rate_spearman_ice_loss_", second_season)
    dynamics_summary |>
      select(lake_id, lat, lon, all_of(c(first_name, second_name))) |>
      rename(first_alignment = all_of(first_name), second_alignment = all_of(second_name)) |>
      filter(is.finite(first_alignment), is.finite(second_alignment)) |>
      mutate(
        pair = paste(first_season, second_season, sep = " vs "),
        sign_class = case_when(
          first_alignment >= 0 & second_alignment >= 0 ~ "Both positive",
          first_alignment < 0 & second_alignment < 0 ~ "Both negative",
          first_alignment >= 0 & second_alignment < 0 ~ "First positive / second negative",
          TRUE ~ "First negative / second positive"
        )
      )
  }

  ice_alignment_pairs <- bind_rows(
    prepare_ice_alignment_pair("JJA", "SON"),
    prepare_ice_alignment_pair("DJF", "MAM")
  )
  ice_pair_palette <- c(
    "Both positive" = "#009E73",
    "Both negative" = "#7A7A7A",
    "First positive / second negative" = "#D55E00",
    "First negative / second positive" = "#0072B2"
  )

  summarise_ice_alignment_pairs <- function() {
    ice_alignment_pairs |>
      group_by(pair) |>
      summarise(
        n_lakes = n(),
        spearman_between_seasons = cor(first_alignment, second_alignment, method = "spearman"),
        opposite_sign_fraction = mean((first_alignment < 0) != (second_alignment < 0)),
        .groups = "drop"
      )
  }

  prepare_ice_alignment_pair_grid <- function(min_lakes = 3) {
    ice_alignment_pairs |>
      mutate(lon_cell = floor(lon), lat_cell = floor(lat)) |>
      count(pair, lon_cell, lat_cell, sign_class, name = "n_class") |>
      group_by(pair, lon_cell, lat_cell) |>
      mutate(n_lakes = sum(n_class), class_fraction = n_class / n_lakes) |>
      slice_max(n_class, n = 1, with_ties = FALSE) |>
      ungroup() |>
      filter(n_lakes >= min_lakes)
  }

  read_rolling_series <- function(name) {
    suffix <- if (name == "annual") "" else paste0("_", name)
    read_csv(
      file.path(diagnostics_dir, paste0("rolling_sen_speed_10yr", suffix, ".csv")),
      show_col_types = FALSE
    ) |>
      pivot_longer(matches("^X?\\d{4}$"), names_to = "year", values_to = "rate") |>
      mutate(year = as.integer(sub("^X", "", year)), series = name)
  }

  read_rolling_ice_state <- function() {
    read_csv(
      file.path(diagnostics_dir, "rolling_ice_days_mean_10yr.csv"),
      show_col_types = FALSE
    ) |>
      pivot_longer(matches("^X?\\d{4}$"), names_to = "year", values_to = "ice_days_mean") |>
      mutate(year = as.integer(sub("^X", "", year)))
  }

  read_rolling_ice_loss <- function(season = NULL) {
    suffix <- if (is.null(season)) "" else paste0("_", season)
    read_csv(
      file.path(diagnostics_dir, paste0("rolling_ice_loss_sen_speed_10yr", suffix, ".csv")),
      show_col_types = FALSE
    ) |>
      pivot_longer(matches("^X?\\d{4}$"), names_to = "year", values_to = "ice_loss_rate") |>
      mutate(year = as.integer(sub("^X", "", year)))
  }

  read_rolling_ice_year_loss <- function() {
    read_csv(
      file.path(diagnostics_dir, "rolling_ice_year_loss_sen_speed_10yr.csv"),
      show_col_types = FALSE
    ) |>
      pivot_longer(matches("^X?\\d{4}$"), names_to = "ice_year_end", values_to = "ice_year_loss_rate") |>
      mutate(ice_year_end = as.integer(sub("^X", "", ice_year_end)))
  }

  direct_ice_phase_endpoints <- read_rolling_ice_loss() |>
    rename(annual_ice_loss_rate = ice_loss_rate) |>
    inner_join(
      read_rolling_ice_loss("JJA") |> select(lake_id, year, jja_ice_loss_rate = ice_loss_rate),
      by = c("lake_id", "year")
    ) |>
    inner_join(
      read_rolling_ice_loss("SON") |> select(lake_id, year, son_ice_loss_rate = ice_loss_rate),
      by = c("lake_id", "year")
    ) |>
    filter(is.finite(jja_ice_loss_rate), is.finite(son_ice_loss_rate), is.finite(annual_ice_loss_rate)) |>
    mutate(
      direct_phase = case_when(
        jja_ice_loss_rate > 0 & son_ice_loss_rate < 0 ~ "JJA loss / SON gain",
        jja_ice_loss_rate > 0 & son_ice_loss_rate > 0 ~ "JJA and SON loss",
        jja_ice_loss_rate < 0 & son_ice_loss_rate < 0 ~ "JJA and SON gain",
        jja_ice_loss_rate < 0 & son_ice_loss_rate > 0 ~ "JJA gain / SON loss",
        .default = "At least one stable season"
      )
    )

  summarise_direct_ice_phase <- function() {
    direct_ice_phase_endpoints |>
      group_by(direct_phase) |>
      summarise(
        n_endpoint_observations = n(),
        n_lakes = n_distinct(lake_id),
        median_annual_ice_loss_rate = median(annual_ice_loss_rate),
        q25_annual_ice_loss_rate = quantile(annual_ice_loss_rate, .25),
        q75_annual_ice_loss_rate = quantile(annual_ice_loss_rate, .75),
        .groups = "drop"
      )
  }

  prepare_northern_ice_year_phase <- function(first_season, second_season, second_year_offset) {
    first <- read_rolling_ice_loss(first_season) |>
      filter(lat >= 0) |>
      select(lake_id, lat, lon, year, first_loss_rate = ice_loss_rate)
    second <- read_rolling_ice_loss(second_season) |>
      transmute(lake_id, year = year - second_year_offset, second_loss_rate = ice_loss_rate)
    ice_year <- read_rolling_ice_year_loss() |>
      select(lake_id, ice_year_end, ice_year_loss_rate)
    first |>
      inner_join(second, by = c("lake_id", "year")) |>
      mutate(ice_year_end = year + 1L) |>
      inner_join(ice_year, by = c("lake_id", "ice_year_end")) |>
      filter(is.finite(first_loss_rate), is.finite(second_loss_rate), is.finite(ice_year_loss_rate)) |>
      mutate(
        pair = paste(first_season, second_season, sep = " vs "),
        direct_phase = case_when(
          first_loss_rate > 0 & second_loss_rate < 0 ~ paste0(first_season, " loss / ", second_season, " gain"),
          first_loss_rate > 0 & second_loss_rate > 0 ~ paste0(first_season, " and ", second_season, " loss"),
          first_loss_rate < 0 & second_loss_rate < 0 ~ paste0(first_season, " and ", second_season, " gain"),
          first_loss_rate < 0 & second_loss_rate > 0 ~ paste0(first_season, " gain / ", second_season, " loss"),
          .default = "At least one stable season"
        )
      )
  }

  northern_ice_year_phase_endpoints <- bind_rows(
    prepare_northern_ice_year_phase("JJA", "SON", 0L),
    prepare_northern_ice_year_phase("SON", "DJF", 1L)
  )

  summarise_northern_ice_year_phase <- function() {
    northern_ice_year_phase_endpoints |>
      group_by(pair, direct_phase) |>
      summarise(
        n_endpoint_observations = n(),
        n_lakes = n_distinct(lake_id),
        median_ice_year_loss_rate = median(ice_year_loss_rate),
        q25_ice_year_loss_rate = quantile(ice_year_loss_rate, .25),
        q75_ice_year_loss_rate = quantile(ice_year_loss_rate, .75),
        .groups = "drop"
      )
  }

  list(
    dynamics_summary = dynamics_summary,
    alignment_long = alignment_long,
    alignment_visual_sample = alignment_visual_sample,
    alignment_status_long = alignment_status_long,
    conditional_alignment_long = conditional_alignment_long,
    thermal_state_long = thermal_state_long,
    ice_alignment_pairs = ice_alignment_pairs,
    ice_pair_palette = ice_pair_palette,
    endpoint_change_long = endpoint_change_long,
    prepare_alignment_grid = prepare_alignment_grid,
    prepare_alignment_grids = prepare_alignment_grids,
    prepare_alignment_availability_grids = prepare_alignment_availability_grids,
    summarise_alignment = summarise_alignment,
    prepare_conditional_alignment_grids = prepare_conditional_alignment_grids,
    summarise_conditional_alignment = summarise_conditional_alignment,
    prepare_thermal_state_grid = prepare_thermal_state_grid,
    summarise_thermal_state = summarise_thermal_state,
    summarise_ice_alignment_pairs = summarise_ice_alignment_pairs,
    prepare_ice_alignment_pair_grid = prepare_ice_alignment_pair_grid,
    read_rolling_series = read_rolling_series,
    read_rolling_ice_state = read_rolling_ice_state,
    read_rolling_ice_loss = read_rolling_ice_loss,
    read_rolling_ice_year_loss = read_rolling_ice_year_loss,
    direct_ice_phase_endpoints = direct_ice_phase_endpoints,
    summarise_direct_ice_phase = summarise_direct_ice_phase,
    northern_ice_year_phase_endpoints = northern_ice_year_phase_endpoints,
    summarise_northern_ice_year_phase = summarise_northern_ice_year_phase
  )
}
