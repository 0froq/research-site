# Rendering-time data preparation for the warming-response cluster chapter.

regional_cluster_definitions <- function() {
  list(
    levels = paste0("C", 1:5),
    colours = c(
      C1 = "#9e2a2f", C2 = "#d4770b", C3 = "#2d8659",
      C4 = "#00a5cf", C5 = "#7b4d9e"
    ),
    names = c(
      C1 = "Late-accelerating moderate warming",
      C2 = "Early decline / late rebound",
      C3 = "Strong sustained warming",
      C4 = "Weak / near-stable warming",
      C5 = "Early warming then plateau"
    ),
    interpretations = c(
      C1 = "Slow early change followed by stronger post-2000 warming",
      C2 = "Flat or slightly negative early trajectory, then late warming rebound",
      C3 = "Persistent warming throughout the full 40-year record",
      C4 = "Largest low-response class, close to baseline through time",
      C5 = "Early warming followed by flattening or slight decline"
    )
  )
}

prepare_regional_cluster_data <- function(data_dir = data) {
  definitions <- regional_cluster_definitions()
  cluster_dir <- file.path(
    data_dir,
    "07-warming-response-clustering",
    "output",
    "stl_trend_period12_robustfalse_ni5_no0_nt199_baseline1981_1990_pca095_k4-8"
  )

  clusters <- read_csv(
    file.path(cluster_dir, "lake_clusters_recommended.csv"),
    show_col_types = FALSE
  ) |>
    mutate(cluster_label = factor(paste0("C", cluster), levels = definitions$levels))

  profiles <- read_csv(
    file.path(cluster_dir, "cluster_profiles_K5.csv"),
    show_col_types = FALSE
  ) |>
    mutate(cluster_label = factor(paste0("C", cluster), levels = definitions$levels))

  lake_meta <- read_csv(
    file.path(data_dir, "00-lake-metadata", "output", "lake_metadata.csv"),
    show_col_types = FALSE,
    col_select = c(lake_id, Lake_area, log_Lake_area, Continent)
  )

  metrics <- read_csv(
    file.path(
      data_dir, "06-lake-warming-metrics", "output",
      "period12_robustfalse_ni5_no0_nt199", "lake_warming_metrics.csv"
    ),
    show_col_types = FALSE,
    col_select = c(
      lake_id,
      mean_temp = raw_annual_mean_temp_mean,
      warming_speed = raw_annual_mean_temp_sen_slope_40yr,
      acceleration = stl_annual_trend_diff_sen_slope_1e3
    )
  )

  plot_data <- clusters |>
    left_join(lake_meta, by = "lake_id") |>
    left_join(metrics, by = "lake_id") |>
    mutate(
      point_size = scales::rescale(
        pmin(pmax(log_Lake_area, 0), 2),
        to = c(0.35, 1.35),
        from = c(0, 2)
      ),
      point_size = if_else(is.finite(point_size), point_size, 0.45)
    )

  summary <- plot_data |>
    group_by(cluster_label) |>
    summarise(
      n = n(),
      mean_temp = mean(mean_temp, na.rm = TRUE),
      warming_speed = mean(warming_speed, na.rm = TRUE),
      acceleration = mean(acceleration, na.rm = TRUE),
      .groups = "drop"
    ) |>
    left_join(
      profiles |>
        filter(year == 2020) |>
        group_by(cluster_label) |>
        summarise(anomaly_2020 = first(anomaly_mean), .groups = "drop"),
      by = "cluster_label"
    ) |>
    mutate(
      response_type = unname(definitions$names[as.character(cluster_label)]),
      short_interpretation = unname(definitions$interpretations[as.character(cluster_label)]),
      label = paste0(
        as.character(cluster_label), ": ", response_type, "\n",
        scales::comma(n), " lakes; 2020 anomaly ",
        sprintf("%+.2f", anomaly_2020), " °C"
      )
    ) |>
    arrange(cluster_label)

  map_limits <- list(lon = c(-180, 180), lat = c(-60, 90))
  map_data <- plot_data |>
    filter(between(lat, map_limits$lat[[1]], map_limits$lat[[2]]))

  list(
    plot_data = plot_data,
    map_data = map_data,
    summary = summary,
    colours = definitions$colours,
    levels = definitions$levels,
    map_limits = map_limits
  )
}

prepare_cluster_metric_long <- function(plot_data) {
  plot_data |>
    transmute(
      cluster_label,
      `Mean temperature\n(°C)` = mean_temp,
      `Sen slope\n(°C / 40 yr)` = warming_speed,
      `STL trend diff slope\n(10-3 °C / yr2)` = acceleration
    ) |>
    pivot_longer(-cluster_label, names_to = "metric", values_to = "value") |>
    filter(is.finite(value)) |>
    mutate(
      metric = factor(
        metric,
        levels = c(
          "Mean temperature\n(°C)", "Sen slope\n(°C / 40 yr)",
          "STL trend diff slope\n(10-3 °C / yr2)"
        )
      )
    )
}

prepare_cluster_density_data <- function(
  plot_data,
  warming_limits = c(-1, 2),
  acceleration_limits = c(-2.5, 3.5)
) {
  plot_data |>
    filter(
      is.finite(warming_speed),
      is.finite(acceleration),
      between(warming_speed, warming_limits[[1]], warming_limits[[2]]),
      between(acceleration, acceleration_limits[[1]], acceleration_limits[[2]])
    )
}

make_cluster_table_accessors <- function(cluster_summary) {
  value <- function(cluster, column) {
    row <- match(cluster, as.character(cluster_summary$cluster_label))
    if (is.na(row)) NA else cluster_summary[[column]][[row]]
  }

  list(
    value = value,
    count = function(cluster) scales::comma(value(cluster, "n")),
    anomaly = function(cluster) paste0(sprintf("%+.2f", value(cluster, "anomaly_2020")), " °C")
  )
}
