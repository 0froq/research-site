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

  endpoint_years <- c(1995L, 2005L, 2015L, 2020L)
  endpoint_speed_points <- rolling_speed_long |>
    filter(year %in% endpoint_years, is.finite(speed), is.finite(lon), is.finite(lat)) |>
    filter(between(lon, -180, 180), between(lat, -60, 85)) |>
    mutate(
      q_float = (2 / 3 * (lon + 180)) / spatial_hex$hex_side,
      r_float = (-1 / 3 * (lon + 180) + sqrt(3) / 3 * (lat + 60)) / spatial_hex$hex_side
    )
  endpoint_rounded <- hex_round_axial(endpoint_speed_points$q_float, endpoint_speed_points$r_float)
  endpoint_hex <- endpoint_speed_points |>
    mutate(q_hex = endpoint_rounded$q, r_hex = endpoint_rounded$r) |>
    group_by(year, q_hex, r_hex) |>
    summarise(
      n = n(), speed = mean(speed),
      lon_c = -180 + spatial_hex$hex_side * 3 / 2 * first(q_hex),
      lat_c = -60 + spatial_hex$hex_side * sqrt(3) * (first(r_hex) + first(q_hex) / 2),
      .groups = "drop"
    ) |>
    filter(n >= 5) |>
    group_by(year) |>
    mutate(id = row_number()) |>
    group_modify(\(data, key) {
      bind_rows(lapply(seq_len(nrow(data)), \(i) {
        make_hexagon_vertices(data$lon_c[[i]], data$lat_c[[i]], spatial_hex$hex_side, data$id[[i]])
      })) |>
        left_join(data |> select(id, n, speed), by = "id")
    }) |>
    ungroup()

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
    endpoint_hex = endpoint_hex,
    lon_min = spatial_hex$limits$lon[[1]], lon_max = spatial_hex$limits$lon[[2]],
    lat_min = spatial_hex$limits$lat[[1]], lat_max = spatial_hex$limits$lat[[2]],
    warming_limit = 2, speed_change_limit = 3,
    rolling_speed = rolling_speed
  )
}
