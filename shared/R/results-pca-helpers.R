# Rendering-time preparation for Results 3.4.
# Depends on 03-warming-pattern-decomposition-helpers.R.

prepare_results_pca_data <- function(pca = prepare_pca_data(), data_dir = data) {
  sinlat_min <- sin(-60 * pi / 180)
  sinlat_max <- sin(85 * pi / 180)

  # The PCA sign has no intrinsic meaning. For display, orient PC1 so that its
  # loading is positively correlated with the equal-area global STL trajectory.
  global_stl <- pca$stl_cell_trajectories |>
    group_by(year) |>
    summarise(global_cell_mean = mean(anomaly), .groups = "drop")
  pc1_alignment <- cor(pca$pca_loadings$pc1, global_stl$global_cell_mean)
  pc1_sign <- if (is.finite(pc1_alignment) && pc1_alignment < 0) -1 else 1

  cell_scores <- pca$pca_cell_scores |>
    mutate(
      pc1_display = pc1 * pc1_sign,
      pc23_magnitude = sqrt(pc2^2 + pc3^2),
      pc23_angle = atan2(pc3, pc2)
    )
  loading_display <- pca$pca_loadings |>
    mutate(pc1_display = pc1 * pc1_sign)

  # The fitted grid is regular in longitude and sin(latitude), not latitude.
  cell_map_data <- cell_scores |>
    mutate(
      lon_width = 360 / 72,
      lon_left = -180 + (lon_bin - 1) * lon_width,
      lon_right = lon_left + lon_width,
      sinlat_lower = sinlat_min + (sinlat_bin - 1) / 21 * (sinlat_max - sinlat_min),
      sinlat_upper = sinlat_min + sinlat_bin / 21 * (sinlat_max - sinlat_min),
      lat_lower = asin(sinlat_lower) * 180 / pi,
      lat_upper = asin(sinlat_upper) * 180 / pi
    )

  metadata <- read_csv(file.path(data_dir, "00-lake-metadata", "output", "lake_metadata.csv"), show_col_types = FALSE)
  assign_cell <- function(frame) {
    frame |>
      filter(is.finite(lon), is.finite(lat), between(lat, -60, 85)) |>
      mutate(
        lon_bin = pmin(floor((lon + 180) / 360 * 72) + 1, 72),
        sinlat_bin = pmin(floor((sin(lat * pi / 180) - sinlat_min) /
          (sinlat_max - sinlat_min) * 21) + 1, 21)
      )
  }
  warming <- read_csv(
    file.path(data_dir, "06-lake-warming-metrics", "output", "period12_robustfalse_ni5_no0_nt99", "lake_warming_metrics.csv"),
    show_col_types = FALSE,
    col_select = c(lake_id, raw_annual_mean_temp_sen_slope_40yr)
  ) |>
    left_join(metadata |> select(lake_id, lon, lat), by = "lake_id") |>
    assign_cell() |>
    group_by(lon_bin, sinlat_bin) |>
    summarise(long_term_warming_decade = mean(raw_annual_mean_temp_sen_slope_40yr / 4, na.rm = TRUE), .groups = "drop")
  tendency <- read_csv(
    file.path(data_dir, "14-trajectory-diagnostics", "output", "trajectory_diagnostics.csv"),
    show_col_types = FALSE,
    col_select = c(lake_id, annual_roll10_sen_accel_1e3)
  ) |>
    left_join(metadata |> select(lake_id, lon, lat), by = "lake_id") |>
    assign_cell() |>
    group_by(lon_bin, sinlat_bin) |>
    summarise(warming_rate_tendency = mean(annual_roll10_sen_accel_1e3, na.rm = TRUE), .groups = "drop")

  pathway_overlap <- cell_scores |>
    left_join(warming, by = c("lon_bin", "sinlat_bin")) |>
    left_join(tendency, by = c("lon_bin", "sinlat_bin")) |>
    filter(if_all(c(pc1_display, pc2, pc3, pc23_magnitude, long_term_warming_decade, warming_rate_tendency), is.finite))

  # Queen adjacency among occupied equal-area cells.
  make_edges <- function(frame) {
    offsets <- expand_grid(dx = -1:1, dy = -1:1) |>
      filter(!(dx == 0 & dy == 0))
    bind_rows(lapply(seq_len(nrow(offsets)), function(i) {
      frame |>
        transmute(cell_i = cell_id, lon_target = lon_bin + offsets$dx[[i]], lat_target = sinlat_bin + offsets$dy[[i]]) |>
        inner_join(
          frame |> transmute(cell_j = cell_id, lon_target = lon_bin, lat_target = sinlat_bin),
          by = c("lon_target", "lat_target")
        ) |>
        filter(cell_i < cell_j) |>
        select(cell_i, cell_j)
    })) |>
      distinct()
  }
  edges <- make_edges(cell_scores)
  moran_i <- function(x) {
    z <- x - mean(x, na.rm = TRUE)
    names(z) <- cell_scores$cell_id
    n <- length(z); s0 <- 2 * nrow(edges)
    (n / s0) * (2 * sum(z[as.character(edges$cell_i)] * z[as.character(edges$cell_j)])) / sum(z^2)
  }
  set.seed(20260726)
  moran_test <- function(x, permutations = 999) {
    observed <- moran_i(x)
    simulated <- replicate(permutations, moran_i(sample(x, length(x), replace = FALSE)))
    tibble(moran_i = observed, permutation_p = (1 + sum(abs(simulated) >= abs(observed))) / (permutations + 1))
  }
  moran_summary <- bind_rows(
    PC1 = moran_test(cell_scores$pc1_display),
    PC2 = moran_test(cell_scores$pc2),
    PC3 = moran_test(cell_scores$pc3),
    `PC2–PC3 magnitude` = moran_test(cell_scores$pc23_magnitude),
    .id = "field"
  )

  haversine_km <- function(lon1, lat1, lon2, lat2) {
    rad <- pi / 180
    dlat <- (lat2 - lat1) * rad; dlon <- (lon2 - lon1) * rad
    a <- sin(dlat / 2)^2 + cos(lat1 * rad) * cos(lat2 * rad) * sin(dlon / 2)^2
    6371 * 2 * atan2(sqrt(a), sqrt(1 - a))
  }
  pair_index <- which(upper.tri(matrix(0, nrow(cell_scores), nrow(cell_scores))), arr.ind = TRUE)
  pair_base <- tibble(
    i = pair_index[, 1], j = pair_index[, 2],
    distance_km = haversine_km(
      cell_scores$lon[pair_index[, 1]], cell_scores$lat[pair_index[, 1]],
      cell_scores$lon[pair_index[, 2]], cell_scores$lat[pair_index[, 2]]
    )
  ) |>
    mutate(distance_bin = cut(distance_km, breaks = c(seq(0, 12000, 1000), Inf), include.lowest = TRUE))
  correlogram <- bind_rows(lapply(c("pc1_display", "pc2", "pc3", "pc23_magnitude"), function(field) {
    z <- as.numeric(scale(cell_scores[[field]]))
    pair_base |>
      mutate(product = z[i] * z[j]) |>
      group_by(distance_bin) |>
      summarise(
        distance_mid_km = median(distance_km),
        standardized_covariance = mean(product),
        n_pairs = n(),
        .groups = "drop"
      ) |>
      mutate(field = recode(field,
        pc1_display = "PC1", pc2 = "PC2", pc3 = "PC3", pc23_magnitude = "PC2–PC3 magnitude"
      ))
  }))

  association_stats <- expand_grid(
    response = c("Long-term warming", "Warming-rate tendency"),
    predictor = c("PC1 score", "PC2 score", "PC3 score", "PC2–PC3 magnitude")
  ) |>
    rowwise() |>
    mutate(
      x = list(switch(predictor,
        "PC1 score" = pathway_overlap$pc1_display,
        "PC2 score" = pathway_overlap$pc2,
        "PC3 score" = pathway_overlap$pc3,
        "PC2–PC3 magnitude" = pathway_overlap$pc23_magnitude
      )),
      y = list(switch(response,
        "Long-term warming" = pathway_overlap$long_term_warming_decade,
        "Warming-rate tendency" = pathway_overlap$warming_rate_tendency
      )),
      spearman_rho = cor(unlist(x), unlist(y), method = "spearman"),
      linear_r2 = summary(lm(unlist(y) ~ unlist(x)))$r.squared
    ) |>
    ungroup() |>
    select(response, predictor, spearman_rho, linear_r2)

  central_limits <- quantile(pathway_overlap$long_term_warming_decade, c(.45, .55), na.rm = TRUE)
  central_band_pc23 <- pathway_overlap |>
    filter(between(long_term_warming_decade, central_limits[[1]], central_limits[[2]])) |>
    mutate(warming_band = "Central decile of long-term warming")
  central_band_summary <- central_band_pc23 |>
    summarise(
      n_cells = n(),
      low_warming = min(long_term_warming_decade),
      high_warming = max(long_term_warming_decade),
      pc2_iqr = IQR(pc2),
      pc3_iqr = IQR(pc3),
      magnitude_iqr = IQR(pc23_magnitude)
    )

  continent_scores <- pca$pca_scores |>
    left_join(metadata |> select(lake_id, Continent), by = "lake_id") |>
    filter(!is.na(Continent)) |>
    pivot_longer(c(pc1, pc2, pc3, pc4, pc5), names_to = "component", values_to = "score") |>
    mutate(component = factor(toupper(component), levels = paste0("PC", 1:5)))

  list(
    cell_scores = cell_scores,
    cell_map_data = cell_map_data,
    loading_display = loading_display,
    global_stl = global_stl,
    pc1_sign = pc1_sign,
    pc1_alignment = pc1_alignment,
    pathway_overlap = pathway_overlap,
    association_stats = association_stats,
    central_band_pc23 = central_band_pc23,
    central_band_summary = central_band_summary,
    moran_summary = moran_summary,
    correlogram = correlogram,
    continent_scores = continent_scores
  )
}
