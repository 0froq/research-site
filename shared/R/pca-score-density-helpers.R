# Rendering-time preparation for PCA score-space density diagnostics.
# Depends on figure-style.R having been sourced.

prepare_pca_score_density_data <- function(data_dir = data) {
  pca_dir <- file.path(data_dir, "16-spatial-balanced-pca", "output", "sinlat_equalarea_72x21_mean")

  lake_scores <- read_csv(
    file.path(pca_dir, "lake_projected_scores.csv"),
    show_col_types = FALSE,
    col_select = c(lake_id, lon, lat, pc1, pc2, pc3, pc4, pc5)
  ) |>
    filter(is.finite(pc2), is.finite(pc3))

  cell_scores <- read_csv(
    file.path(pca_dir, "spatial_cell_scores.csv"),
    show_col_types = FALSE,
    col_select = c(cell_id, lon, lat, n_lakes, pc1, pc2, pc3, pc4, pc5)
  ) |>
    filter(is.finite(pc2), is.finite(pc3))

  limits <- c(
    max(abs(quantile(lake_scores$pc2, c(.005, .995), na.rm = TRUE)),
      abs(quantile(lake_scores$pc3, c(.005, .995), na.rm = TRUE)))
  )

  find_kde_peaks <- function(scores, source) {
    bandwidth <- c(MASS::bandwidth.nrd(scores$pc2), MASS::bandwidth.nrd(scores$pc3))
    bind_rows(lapply(c(.7, .9, 1.1, 1.3, 1.6), function(factor) {
      estimate <- MASS::kde2d(
        scores$pc2, scores$pc3,
        h = bandwidth * factor,
        n = 120,
        lims = rep(c(-limits, limits), 2)
      )
      surface <- estimate$z
      core <- surface[2:119, 2:119]
      is_peak <- matrix(TRUE, nrow = 118, ncol = 118)
      for (row_shift in -1:1) {
        for (column_shift in -1:1) {
          if (row_shift != 0 || column_shift != 0) {
            is_peak <- is_peak & core > surface[(2 + row_shift):(119 + row_shift), (2 + column_shift):(119 + column_shift)]
          }
        }
      }
      heights <- sort(core[is_peak & core >= .1 * max(surface)], decreasing = TRUE)
      tibble(
        source = source,
        bandwidth_factor = factor,
        n_peaks = length(heights),
        secondary_peak_relative = ifelse(length(heights) >= 2, heights[[2]] / heights[[1]], NA_real_)
      )
    }))
  }

  kde_peak_summary <- bind_rows(
    find_kde_peaks(lake_scores, "Projected lakes"),
    find_kde_peaks(cell_scores, "Equal-area cells")
  )

  make_kde_surface <- function(scores, bandwidth_factor = 1.1) {
    bandwidth <- c(MASS::bandwidth.nrd(scores$pc2), MASS::bandwidth.nrd(scores$pc3))
    estimate <- MASS::kde2d(
      scores$pc2, scores$pc3,
      h = bandwidth * bandwidth_factor,
      n = 120,
      lims = rep(c(-limits, limits), 2)
    )
    list(x = estimate$x, y = estimate$y, z = estimate$z / max(estimate$z))
  }

  lake_kde_surface <- make_kde_surface(lake_scores)
  cell_kde_surface <- make_kde_surface(cell_scores)

  find_surface_peaks <- function(surface) {
    core <- surface$z[2:119, 2:119]
    is_peak <- matrix(TRUE, nrow = 118, ncol = 118)
    for (row_shift in -1:1) {
      for (column_shift in -1:1) {
        if (row_shift != 0 || column_shift != 0) {
          is_peak <- is_peak & core > surface$z[(2 + row_shift):(119 + row_shift), (2 + column_shift):(119 + column_shift)]
        }
      }
    }
    indices <- which(is_peak & core >= .1, arr.ind = TRUE)
    tibble(
      pc2 = surface$x[indices[, 1] + 1],
      pc3 = surface$y[indices[, 2] + 1],
      height = core[indices]
    ) |>
      arrange(desc(height)) |>
      slice_head(n = 2) |>
      mutate(core = paste0("Density core ", row_number()))
  }

  lake_density_peaks <- find_surface_peaks(lake_kde_surface)
  line_points <- tibble(t = seq(0, 1, length.out = 101)) |>
    transmute(
      pc2 = lake_density_peaks$pc2[[1]] * (1 - t) + lake_density_peaks$pc2[[2]] * t,
      pc3 = lake_density_peaks$pc3[[1]] * (1 - t) + lake_density_peaks$pc3[[2]] * t
    )
  surface_value <- function(pc2, pc3, surface) {
    x_index <- pmax(1, pmin(length(surface$x), findInterval(pc2, surface$x)))
    y_index <- pmax(1, pmin(length(surface$y), findInterval(pc3, surface$y)))
    surface$z[cbind(x_index, y_index)]
  }
  density_saddle <- min(surface_value(line_points$pc2, line_points$pc3, lake_kde_surface))
  lake_core_membership <- lake_scores |>
    mutate(
      density = surface_value(pc2, pc3, lake_kde_surface),
      distance_core_1 = (pc2 - lake_density_peaks$pc2[[1]])^2 + (pc3 - lake_density_peaks$pc3[[1]])^2,
      distance_core_2 = (pc2 - lake_density_peaks$pc2[[2]])^2 + (pc3 - lake_density_peaks$pc3[[2]])^2,
      core = case_when(
        density < density_saddle ~ NA_character_,
        distance_core_1 <= distance_core_2 ~ lake_density_peaks$core[[1]],
        .default = lake_density_peaks$core[[2]]
      )
    ) |>
    filter(!is.na(core))
  lake_core_map <- lake_core_membership |>
    mutate(lon_cell = floor(lon), lat_cell = floor(lat)) |>
    count(core, lon_cell, lat_cell, name = "n_lakes")

  list(
    lake_scores = lake_scores,
    cell_scores = cell_scores,
    limit = limits,
    kde_peak_summary = kde_peak_summary,
    lake_kde_surface = lake_kde_surface,
    cell_kde_surface = cell_kde_surface,
    lake_density_peaks = lake_density_peaks,
    density_saddle = density_saddle,
    lake_core_membership = lake_core_membership,
    lake_core_map = lake_core_map
  )
}
