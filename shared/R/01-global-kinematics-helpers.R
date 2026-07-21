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
  required <- c("raw_annual_mean_temp_sen_slope_40yr")
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
  trajectory_dir <- file.path(data_dir, "14-trajectory-diagnostics", "output")
  trajectory_metrics <- read_csv(
    file.path(trajectory_dir, "trajectory_diagnostics.csv"), show_col_types = FALSE,
    col_select = c(lake_id, annual_roll10_sen_accel_1e3)
  )
  rolling_speed <- read_csv(
    file.path(trajectory_dir, "rolling_sen_speed_10yr.csv"), show_col_types = FALSE
  ) |>
    select(lake_id, matches("^X?\\d{4}$"))
  raw_annual <- read_csv(
    file.path(data_dir, "02-annual-temperature", "output", "annual_mean_temperature.csv"),
    show_col_types = FALSE
  ) |>
    select(lake_id, matches("^X?\\d{4}$"))
  rolling_speed_long <- rolling_speed |>
    pivot_longer(cols = matches("^X?\\d{4}$"), names_to = "year", values_to = "speed") |>
    mutate(year = as.integer(sub("^X", "", year))) |>
    left_join(lake_meta_data |> select(lake_id, lon, lat), by = "lake_id")
  lake_warming_metrics <- lake_warming_metrics |>
    left_join(trajectory_metrics, by = "lake_id") |>
    rename(warming_speed_change = annual_roll10_sen_accel_1e3)

  raw_warming_summary <- summarise_kinematics_metric(
    lake_warming_metrics$raw_annual_mean_temp_sen_slope_40yr,
    "n_warming", "n_cooling"
  ) |>
    mutate(prop_warming = prop_positive)
  speed_change_summary <- summarise_kinematics_metric(
    lake_warming_metrics$warming_speed_change,
    "n_positive", "n_negative"
  )

  spatial_input <- lake_warming_metrics |>
    transmute(
      lake_id,
      raw_annual_mean_temp_sen_slope_40yr,
      raw_annual_mean_temp_diff_sen_slope_1e3 = warming_speed_change
    )
  spatial_hex <- prepare_spatial_hex(
    metrics = spatial_input,
    metadata = lake_meta_data,
    hex_height = 5, min_lakes = 5,
    lon_limits = c(-180, 180), lat_limits = c(-60, 85)
  )
  spatial_hex_summary <- spatial_hex$summary |>
    mutate(id = row_number(), warming_scaled = warming_speed / 2, speed_change_scaled = speed_change / 3)
  spatial_hex_poly <- spatial_hex$polygons |>
    left_join(
      spatial_hex_summary |> select(id, warming_scaled, speed_change_scaled),
      by = "id"
    )

  spatial_grid <- spatial_input |>
    left_join(lake_meta_data |> select(lake_id, lon, lat), by = "lake_id") |>
    filter(is.finite(lon), is.finite(lat), between(lon, -180, 180), between(lat, -60, 85)) |>
    mutate(lon_cell = floor(lon), lat_cell = floor(lat)) |>
    group_by(lon_cell, lat_cell) |>
    summarise(
      n = n(),
      warming_scaled = mean(raw_annual_mean_temp_sen_slope_40yr, na.rm = TRUE) / 2,
      speed_change_scaled = mean(raw_annual_mean_temp_diff_sen_slope_1e3, na.rm = TRUE) / 3,
      .groups = "drop"
    ) |>
    filter(n >= 3)

  endpoint_years <- c(1990L, 2000L, 2010L, 2020L)
  endpoint_speed_grid <- rolling_speed_long |>
    filter(year %in% endpoint_years, is.finite(speed), is.finite(lon), is.finite(lat)) |>
    filter(between(lon, -180, 180), between(lat, -60, 85)) |>
    mutate(
      lon_cell = floor(lon), lat_cell = floor(lat)
    ) |>
    group_by(year, lon_cell, lat_cell) |>
    summarise(
      n = n(), speed = mean(speed),
      .groups = "drop"
    ) |>
    filter(n >= 3)

  raw_annual_global <- raw_annual |>
    pivot_longer(cols = matches("^X?\\d{4}$"), names_to = "year", values_to = "temperature") |>
    mutate(year = as.integer(sub("^X", "", year))) |>
    group_by(year) |>
    summarise(
      median = median(temperature, na.rm = TRUE),
      q25 = quantile(temperature, .25, na.rm = TRUE),
      q75 = quantile(temperature, .75, na.rm = TRUE),
      .groups = "drop"
    ) |>
    filter(is.finite(median))

  # Equal-area counterpart to lake-equal global summaries. One occupied PCA
  # cell contributes one trajectory, so dense lake regions cannot dominate the
  # displayed global line merely through sampling density.
  assign_equal_area_cell <- function(frame) {
    sinlat_min <- sin(-60 * pi / 180); sinlat_max <- sin(85 * pi / 180)
    frame |>
      filter(is.finite(lat), is.finite(lon), between(lat, -60, 85)) |>
      mutate(
        lon_bin = pmin(floor((lon + 180) / 360 * 72) + 1, 72),
        sinlat_bin = pmin(floor((sin(lat * pi / 180) - sinlat_min) /
          (sinlat_max - sinlat_min) * 21) + 1, 21)
      )
  }
  equal_area_annual_global <- raw_annual |>
    left_join(lake_meta_data |> select(lake_id, lon, lat), by = "lake_id") |>
    assign_equal_area_cell() |>
    pivot_longer(matches("^X?\\d{4}$"), names_to = "year", values_to = "temperature") |>
    mutate(year = as.integer(sub("^X", "", year))) |>
    group_by(lon_bin, sinlat_bin, year) |>
    summarise(cell_temperature = mean(temperature, na.rm = TRUE), .groups = "drop") |>
    group_by(year) |>
    summarise(mean = mean(cell_temperature, na.rm = TRUE), .groups = "drop")
  equal_area_speed_global <- rolling_speed_long |>
    assign_equal_area_cell() |>
    group_by(lon_bin, sinlat_bin, year) |>
    summarise(cell_speed = mean(speed, na.rm = TRUE), .groups = "drop") |>
    group_by(year) |>
    summarise(mean = mean(cell_speed, na.rm = TRUE), .groups = "drop")

  list(
    raw_monthly = raw_monthly,
    lake_meta_data = lake_meta_data,
    lake_warming_metrics = lake_warming_metrics,
    lakes_num = nrow(raw_monthly),
    start_year = as.integer(sub(".*?(\\d{4}).*", "\\1", names(raw_monthly)[4])),
    end_year = as.integer(sub(".*?(\\d{4}).*", "\\1", tail(names(raw_monthly), 1))),
    raw_warming_summary = raw_warming_summary,
    speed_change_summary = speed_change_summary,
    rolling_speed_long = rolling_speed_long,
    scatter_matrix_data = lake_warming_metrics |>
      transmute(
        `Mean temperature` = raw_annual_mean_temp_mean,
        `Long-term warming` = raw_annual_mean_temp_sen_slope_40yr,
        `Warming-speed change` = warming_speed_change
      ) |>
      filter(if_all(everything(), is.finite)),
    spatial_hex = spatial_hex,
    spatial_metrics = spatial_hex$metrics,
    spatial_hex_summary = spatial_hex_summary,
    spatial_hex_poly = spatial_hex_poly,
    spatial_grid = spatial_grid,
    endpoint_speed_grid = endpoint_speed_grid,
    raw_annual_global = raw_annual_global,
    equal_area_annual_global = equal_area_annual_global,
    equal_area_speed_global = equal_area_speed_global,
    lon_min = spatial_hex$limits$lon[[1]], lon_max = spatial_hex$limits$lon[[2]],
    lat_min = spatial_hex$limits$lat[[1]], lat_max = spatial_hex$limits$lat[[2]],
    warming_limit = 2, speed_change_limit = 3,
    rolling_speed = rolling_speed
  )
}
