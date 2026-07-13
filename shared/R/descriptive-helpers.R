# Helpers used by the descriptive chapter. Depends on shared/R/figure-style.R.

bin_lake_locations <- function(lake_xy, bin_size = 1, lat_min = -60) {
  lake_xy <- lake_xy |>
    filter(is.finite(lon), is.finite(lat))

  list(
    bins = lake_xy |>
      mutate(
        lon_bin = pmin(floor((lon + 180) / bin_size), 360 / bin_size - 1),
        lat_bin = pmin(floor((lat + 90) / bin_size), 180 / bin_size - 1),
        lon = -180 + (lon_bin + 0.5) * bin_size,
        lat = -90 + (lat_bin + 0.5) * bin_size
      ) |>
      count(lon, lat, name = "n") |>
      filter(lat >= lat_min),
    lon_counts = lake_xy |>
      mutate(lon_band = pmin(floor((lon + 180) / bin_size), 360 / bin_size - 1) * bin_size - 180 + bin_size / 2) |>
      count(lon_band, name = "n"),
    lat_counts = lake_xy |>
      mutate(lat_band = pmin(floor((lat + 90) / bin_size), 180 / bin_size - 1) * bin_size - 90 + bin_size / 2) |>
      count(lat_band, name = "n") |>
      filter(lat_band >= lat_min)
  )
}

make_continent_summary <- function(lake_meta) {
  lake_meta |>
    mutate(Continent = if_else(is.na(Continent) | trimws(Continent) == "", "Unknown", Continent)) |>
    count(Continent, name = "n") |>
    arrange(desc(n)) |>
    mutate(row = row_number(), y = -row, n_label = scales::comma(n))
}

make_continent_inchart <- function(continent_summary) {
  row_lines <- tibble(y = -seq(0.5, nrow(continent_summary) + 0.5, by = 1))

  ggplot() +
    geom_segment(
      data = row_lines,
      aes(x = 0.03, xend = 0.97, y = y, yend = y),
      color = col_inchart_geom_border,
      linewidth = wid_grid
    ) +
    geom_text(aes(x = 0.06, y = 0, label = "Continent"), hjust = 0, fontface = "bold", size = siz_text * 0.37, color = col_text) +
    geom_text(aes(x = 0.96, y = 0, label = "Count"), hjust = 1, fontface = "bold", size = siz_text * 0.37, color = col_text) +
    geom_text(data = continent_summary, aes(x = 0.06, y = y, label = Continent), hjust = 0, size = siz_text * 0.34, color = col_text) +
    geom_text(data = continent_summary, aes(x = 0.96, y = y, label = n_label), hjust = 1, size = siz_text * 0.34, color = col_text) +
    coord_cartesian(xlim = c(0, 1), ylim = c(-nrow(continent_summary) - 0.65, 0.65), expand = FALSE, clip = "off") +
    theme_inchart_table()
}

hex_round_axial <- function(q, r) {
  x <- q
  z <- r
  y <- -x - z
  rx <- round(x)
  ry <- round(y)
  rz <- round(z)
  x_diff <- abs(rx - x)
  y_diff <- abs(ry - y)
  z_diff <- abs(rz - z)
  choose_x <- x_diff > y_diff & x_diff > z_diff
  choose_y <- !choose_x & y_diff > z_diff
  rx <- ifelse(choose_x, -ry - rz, rx)
  ry <- ifelse(choose_y, -rx - rz, ry)
  rz <- ifelse(!choose_x & !choose_y, -rx - ry, rz)
  list(q = rx, r = rz)
}

make_hexagon_vertices <- function(cx, cy, side, id) {
  theta <- pi / 180 * seq(0, 300, by = 60)
  tibble(id = id, lon = cx + side * cos(theta), lat = cy + side * sin(theta))
}

prepare_spatial_hex <- function(
  metrics,
  metadata,
  hex_height = 5,
  min_lakes = 5,
  lon_limits = c(-180, 180),
  lat_limits = c(-60, 85)
) {
  lon_min <- lon_limits[[1]]
  lon_max <- lon_limits[[2]]
  lat_min <- lat_limits[[1]]
  lat_max <- lat_limits[[2]]
  hex_side <- hex_height / sqrt(3)

  spatial_metrics <- metrics |>
    transmute(
      lake_id,
      warming_speed = raw_annual_mean_temp_sen_slope_40yr,
      acceleration = raw_annual_mean_temp_diff_sen_slope_1e3
    ) |>
    left_join(metadata |> select(lake_id, lon, lat), by = "lake_id") |>
    filter(is.finite(lon), is.finite(lat), is.finite(warming_speed), is.finite(acceleration)) |>
    filter(between(lon, lon_min, lon_max), between(lat, lat_min, lat_max)) |>
    mutate(
      q_float = (2 / 3 * (lon - lon_min)) / hex_side,
      r_float = (-1 / 3 * (lon - lon_min) + sqrt(3) / 3 * (lat - lat_min)) / hex_side
    )

  rounded <- hex_round_axial(spatial_metrics$q_float, spatial_metrics$r_float)
  spatial_points <- spatial_metrics |>
    mutate(q_hex = rounded$q, r_hex = rounded$r)

  summary <- spatial_points |>
    group_by(q_hex, r_hex) |>
    summarise(
      n = n(),
      warming_speed = mean(warming_speed, na.rm = TRUE),
      acceleration = mean(acceleration, na.rm = TRUE),
      lon_c = lon_min + hex_side * 3 / 2 * first(q_hex),
      lat_c = lat_min + hex_side * sqrt(3) * (first(r_hex) + first(q_hex) / 2),
      .groups = "drop"
    ) |>
    filter(
      n >= min_lakes,
      between(lon_c, lon_min - hex_height, lon_max + hex_height),
      between(lat_c, lat_min - hex_height, lat_max + hex_height)
    )

  polygons <- bind_rows(lapply(seq_len(nrow(summary)), function(i) {
    make_hexagon_vertices(summary$lon_c[[i]], summary$lat_c[[i]], hex_side, i)
  })) |>
    left_join(summary |> mutate(id = row_number()), by = "id")

  list(
    metrics = spatial_points,
    summary = summary,
    polygons = polygons,
    limits = list(lon = lon_limits, lat = lat_limits),
    hex_side = hex_side
  )
}

format_axis_number <- function(x, digits = 2) {
  label <- formatC(x, format = "f", digits = digits)
  label <- sub("0+$", "", label)
  label <- sub("\\.$", "", label)
  label[label == "-0"] <- "0"
  label
}

format_axis_last_unit <- function(x, unit, digits = 2) {
  label <- format_axis_number(x, digits)
  label[length(label)] <- paste(label[length(label)], unit)
  label
}

split_kde_core <- function(data, x = "x", y = "y", core_quantile = 0.05, grid_n = 120, contour_n = 4) {
  stopifnot(core_quantile > 0, core_quantile < 1)

  points <- data |>
    filter(is.finite(.data[[x]]), is.finite(.data[[y]]))
  if (nrow(points) < 10) {
    return(list(points = points, outliers = points[0, ], contours = tibble(), threshold = NA_real_))
  }

  kde <- MASS::kde2d(points[[x]], points[[y]], n = grid_n)
  x_index <- pmin(findInterval(points[[x]], kde$x, all.inside = TRUE), length(kde$x))
  y_index <- pmin(findInterval(points[[y]], kde$y, all.inside = TRUE), length(kde$y))
  points$density <- kde$z[cbind(x_index, y_index)]

  threshold <- unname(quantile(points$density, core_quantile, na.rm = TRUE))
  max_density <- max(kde$z, na.rm = TRUE)
  levels <- seq(threshold, max_density * 0.95, length.out = contour_n)
  levels <- unique(levels[is.finite(levels) & levels <= max_density])

  contour_lines <- bind_rows(lapply(levels, function(level) {
    contourLines(kde$x, kde$y, kde$z, levels = level) |>
      lapply(function(line) {
        tibble(
          x = line$x,
          y = line$y,
          contour_level = level,
          contour_id = seq_along(line$x)
        )
      }) |>
      bind_rows(.id = "path")
  })) |>
    mutate(group = interaction(contour_level, path, drop = TRUE))

  list(
    points = points,
    outliers = filter(points, density < threshold),
    contours = contour_lines,
    threshold = threshold
  )
}
