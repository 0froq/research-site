# Rendering-time preparation for the global-kinematics chapter.
# Depends on figure-style.R and descriptive-helpers.R having been sourced.

summarise_kinematics_metric <- function(x, positive_name, nonpositive_name) {
  x <- x[is.finite(x)]
  tibble(
    n_finite = length(x),
    !!positive_name := sum(x > 0),
    !!nonpositive_name := sum(x <= 0),
    prop_positive = mean(x > 0),
    mean = mean(x), sd = sd(x), median = median(x),
    q25 = quantile(x, 0.25), q75 = quantile(x, 0.75)
  )
}

prepare_kinematics_data <- function(data_dir = data) {
  raw_monthly <- read_csv(
    file.path(data_dir, "01-monthly-temperature", "output", "monthly_temperature.csv"),
    show_col_types = FALSE
  )
  lake_meta_data <- read_csv(
    file.path(data_dir, "00-lake-metadata", "output", "lake_metadata.csv"),
    show_col_types = FALSE
  )
  metrics_path <- file.path(data_dir, "06-lake-warming-metrics", "output",
    "period12_robustfalse_ni5_no0_nt99", "lake_warming_metrics.csv")
  required <- c(
    "raw_annual_mean_temp_sen_slope_40yr",
    "raw_annual_mean_temp_diff_sen_slope_1e3"
  )
  available_columns <- names(read_csv(metrics_path, n_max = 0, show_col_types = FALSE))
  missing_columns <- setdiff(required, available_columns)
  if (length(missing_columns) > 0) {
    stop(
      "Step 06 must be rerun before rendering Global Kinematics; missing: ",
      paste(missing_columns, collapse = ", "), call. = FALSE
    )
  }
  lake_warming_metrics <- read_csv(
    metrics_path, show_col_types = FALSE,
    col_select = c(lake_id, raw_annual_mean_temp_mean, all_of(required))
  )

  raw_warming_summary <- summarise_kinematics_metric(
    lake_warming_metrics$raw_annual_mean_temp_sen_slope_40yr,
    "n_warming", "n_cooling"
  ) |>
    mutate(prop_warming = prop_positive)
  accel_summary <- summarise_kinematics_metric(
    lake_warming_metrics$raw_annual_mean_temp_diff_sen_slope_1e3,
    "n_positive", "n_negative"
  )

  joint_state_summary <- lake_warming_metrics |>
    transmute(
      warming_speed = raw_annual_mean_temp_sen_slope_40yr,
      acceleration = raw_annual_mean_temp_diff_sen_slope_1e3,
      state = case_when(
        warming_speed > 0 & acceleration > 0 ~ "warming + accelerating",
        warming_speed > 0 & acceleration <= 0 ~ "warming + decelerating",
        warming_speed <= 0 & acceleration > 0 ~ "cooling + accelerating",
        warming_speed <= 0 & acceleration <= 0 ~ "cooling + decelerating",
        TRUE ~ NA_character_
      )
    ) |>
    filter(is.finite(warming_speed), is.finite(acceleration), !is.na(state)) |>
    count(state, name = "n") |>
    mutate(
      prop = n / sum(n),
      state = factor(state, levels = names(pal_state))
    ) |>
    arrange(state)

  state_value <- function(label, column) {
    value <- joint_state_summary |>
      filter(state == label) |>
      (\(x) x[[column]])()
    if (length(value) == 0) NA_real_ else value[[1]]
  }

  spatial_hex <- prepare_spatial_hex(
    metrics = lake_warming_metrics,
    metadata = lake_meta_data,
    hex_height = 5, min_lakes = 5,
    lon_limits = c(-180, 180), lat_limits = c(-60, 85)
  )
  spatial_hex_summary <- spatial_hex$summary |>
    mutate(id = row_number(), warming_scaled = warming_speed / 2, acceleration_scaled = acceleration / 3)
  spatial_hex_poly <- spatial_hex$polygons |>
    left_join(
      spatial_hex_summary |> select(id, warming_scaled, acceleration_scaled),
      by = "id"
    )
  spatial_continent_summary <- spatial_hex$metrics |>
    left_join(lake_meta_data |> select(lake_id, Continent), by = "lake_id") |>
    mutate(
      Continent = if_else(is.na(Continent) | trimws(Continent) == "", "Unknown", Continent),
      state = case_when(
        warming_speed > 0 & acceleration > 0 ~ "warming + accelerating",
        warming_speed > 0 & acceleration <= 0 ~ "warming + decelerating",
        warming_speed <= 0 & acceleration > 0 ~ "cooling + accelerating",
        warming_speed <= 0 & acceleration <= 0 ~ "cooling + decelerating"
      )
    ) |>
    group_by(Continent) |>
    summarise(
      n = n(), warming_pct = mean(warming_speed > 0),
      accelerating_pct = mean(acceleration > 0),
      warming_accelerating_pct = mean(state == "warming + accelerating"),
      mean_warming = mean(warming_speed), mean_acceleration = mean(acceleration),
      .groups = "drop"
    ) |>
    mutate(continent_abbr = recode(
      Continent, "Africa" = "AF", "Asia" = "AS", "Europe" = "EU",
      "North America" = "NA", "South America" = "SA", "Oceania" = "OC",
      "Antarctica" = "AN", "Unknown" = "UN", .default = toupper(substr(Continent, 1, 2))
    )) |>
    arrange(desc(n))

  continent_stat <- function(abbr, column) {
    value <- spatial_continent_summary |>
      filter(continent_abbr == abbr) |>
      (\(x) x[[column]])()
    if (length(value) == 0 || !is.finite(value[[1]])) NA_real_ else value[[1]]
  }

  list(
    raw_monthly = raw_monthly,
    lake_meta_data = lake_meta_data,
    lake_warming_metrics = lake_warming_metrics,
    lakes_num = nrow(raw_monthly),
    start_year = as.integer(sub(".*?(\\d{4}).*", "\\1", names(raw_monthly)[4])),
    end_year = as.integer(sub(".*?(\\d{4}).*", "\\1", tail(names(raw_monthly), 1))),
    raw_warming_summary = raw_warming_summary,
    accel_summary = accel_summary,
    joint_state_summary = joint_state_summary,
    state_count = function(label) state_value(label, "n"),
    state_prop = function(label) state_value(label, "prop"),
    scatter_matrix_data = lake_warming_metrics |>
      transmute(
        `Mean temperature` = raw_annual_mean_temp_mean,
        `Long-term warming speed` = raw_annual_mean_temp_sen_slope_40yr,
        Acceleration = raw_annual_mean_temp_diff_sen_slope_1e3
      ) |>
      filter(if_all(everything(), is.finite)),
    spatial_hex = spatial_hex,
    spatial_metrics = spatial_hex$metrics,
    spatial_hex_summary = spatial_hex_summary,
    spatial_hex_poly = spatial_hex_poly,
    lon_min = spatial_hex$limits$lon[[1]], lon_max = spatial_hex$limits$lon[[2]],
    lat_min = spatial_hex$limits$lat[[1]], lat_max = spatial_hex$limits$lat[[2]],
    warming_limit = 2, acceleration_limit = 3,
    spatial_continent_summary = spatial_continent_summary,
    continent_stat = continent_stat
  )
}
