# Shared paths and visual style for figures rendered from Quarto.

library(ggplot2)
library(ggside)
library(ggthemes)
library(dplyr)
library(readr)
library(scales)
library(tidyr)
library(patchwork)
library(cowplot)
library(paletteer)

find_quarto_project <- function(path = getwd()) {
  path <- normalizePath(path, mustWork = TRUE)
  repeat {
    if (file.exists(file.path(path, "_quarto.yml"))) {
      return(path)
    }
    parent <- dirname(path)
    if (identical(parent, path)) {
      stop("Could not find _quarto.yml from ", getwd())
    }
    path <- parent
  }
}

project_dir <- find_quarto_project()
repo_root <- normalizePath(file.path(project_dir, ".."), mustWork = TRUE)
data_process_dir <- file.path(repo_root, "data-process")

knitr::opts_knit$set(root.dir = data_process_dir)

rdata <- file.path(data_process_dir, "analysis", "r-data")
out <- file.path(project_dir, "shared", "assets")

figure_dpi <- 300
figure_bg <- "white"
base_size <- 10

if (!knitr::is_latex_output() && requireNamespace("ragg", quietly = TRUE)) {
  knitr::opts_chunk$set(dev = "ragg_png", dpi = figure_dpi)
}

col_text <- "grey20"
col_text_soft <- "grey40"
col_axis_text <- "grey20"
col_subtitle <- "grey10"
col_grid <- "grey60"
col_grid_light <- "grey80"
col_panel_bg <- "white"
col_strip_bg <- "grey90"
col_strip_border <- "grey80"

pal_direction <- c(
  warming = "#b84a3a",
  cooling = "#2f6f9f"
)

pal_direction_fill <- c(
  warming = "#e99782",
  cooling = "#79b5d7"
)

pal_state <- c(
  "warming + accelerating" = "#b84a3a",
  "warming + decelerating" = "#e99782",
  "cooling + accelerating" = "#79b5d7",
  "cooling + decelerating" = "#2f6f9f"
)

pal_cluster <- c(
  "C1" = "#5778a4", "C2" = "#e49444", "C3" = "#d1615d", "C4" = "#85b6b2",
  "C5" = "#6a9f58", "C6" = "#e7ca60", "C7" = "#a98dd2", "C8" = "#7a6b3a"
)

pal_diverging <- c(low = "#2f6f9f", mid = "#f7f7f4", high = "#b84a3a")
pal_density <- c("#f7f1ec", "#e9c6ad", "#c99569", "#7b765f", "#242823")

scale_atomic_diverging <- function(..., midpoint = 0, name = waiver()) {
  scale_fill_gradient2(
    low = pal_diverging[["low"]],
    mid = pal_diverging[["mid"]],
    high = pal_diverging[["high"]],
    midpoint = midpoint,
    name = name,
    ...
  )
}

scale_atomic_density <- function(..., name = waiver()) {
  scale_fill_gradientn(colors = pal_density, name = name, ...)
}

write_derived_csv <- function(x, path, ...) {
  if (isTRUE(getOption("hiatus.write_derived", FALSE))) {
    readr::write_csv(x, path, ...)
  }
  invisible(x)
}

prepare_warming_accel_data <- function() {
  if (!exists("warming_accel_data", envir = .figure_cache, inherits = FALSE)) {
    metrics <- read_csv(file.path(rdata, "canonical_lake_metrics.csv"), show_col_types = FALSE)
    sen_accel <- read_csv(file.path(rdata, "stl_sen_acceleration_masked.csv"),
      show_col_types = FALSE
    )
    stopifnot(
      nrow(metrics) == nrow(sen_accel),
      all(metrics$row_index == sen_accel$row_index)
    )
    metrics <- metrics %>%
      mutate(stl_accel_sen_slope_1e3 = sen_accel$stl_accel_sen_slope_1e3)
    assign("warming_accel_data", metrics, envir = .figure_cache)
  }
  get("warming_accel_data", envir = .figure_cache, inherits = FALSE)
}

sen_slope_40 <- function(y) {
  n <- length(y)
  if (n < 2) {
    return(NA_real_)
  }
  slopes <- outer(y, y, "-") / outer(seq_len(n), seq_len(n), "-")
  median(slopes[lower.tri(slopes)], na.rm = TRUE) * 40
}

.figure_cache <- new.env(parent = emptyenv())

prepare_cluster_data <- function(include_area = FALSE,
                                 include_accel = FALSE,
                                 include_warming = FALSE) {
  if (!exists("cluster_base", envir = .figure_cache, inherits = FALSE)) {
    trend <- read_csv(file.path(rdata, "annual_stl_trend.csv"), show_col_types = FALSE)
    year_cols <- grep("^trend_", names(trend), value = TRUE)
    trend_matrix <- as.matrix(trend[, year_cols])
    complete_idx <- complete.cases(trend_matrix)
    trend_sub <- trend[complete_idx, ]
    trend_mat <- trend_matrix[complete_idx, ]
    trend_sub$mean_temp <- rowMeans(trend_mat)

    set.seed(42)
    trend_scaled <- t(scale(t(trend_mat)))
    feat_BT <- cbind(trend_scaled, scale(trend_sub$mean_temp))
    km <- kmeans(feat_BT, centers = 8, nstart = 10, iter.max = 100)
    trend_sub$cluster <- factor(km$cluster)

    cluster_order <- trend_sub %>%
      group_by(cluster) %>%
      summarise(mt = mean(mean_temp), .groups = "drop") %>%
      arrange(mt) %>%
      mutate(new_label = paste0("C", row_number()))

    trend_sub <- trend_sub %>%
      left_join(cluster_order %>% select(cluster, new_label), by = "cluster") %>%
      mutate(cluster_label = factor(new_label, levels = paste0("C", 1:8)))

    cluster_meta <- trend_sub %>%
      group_by(cluster_label) %>%
      summarise(n = n(), mt = mean(mean_temp), .groups = "drop")

    label_map <- setNames(
      paste0(cluster_meta$cluster_label, " (", comma(cluster_meta$n), ", ", sprintf("%.1f", cluster_meta$mt), "\u00b0C)"),
      cluster_meta$cluster_label
    )

    assign("cluster_base", list(
      trend = trend,
      trend_sub = trend_sub,
      trend_mat = trend_mat,
      year_cols = year_cols,
      complete_idx = complete_idx,
      cluster_order = cluster_order,
      cluster_meta = cluster_meta,
      label_map = label_map
    ), envir = .figure_cache)
  }

  data <- get("cluster_base", envir = .figure_cache, inherits = FALSE)
  trend_sub <- data$trend_sub

  if (include_area) {
    if (!exists("cluster_area", envir = .figure_cache, inherits = FALSE)) {
      attr <- read_csv("processed/lake-attributes/data-lake-attributes.csv", show_col_types = FALSE)
      area_km2 <- attr$Lake_area[data$complete_idx] / 1e6
      area_clip <- quantile(area_km2, c(0.05, 0.95), na.rm = TRUE)
      area_data <- tibble(
        area_km2_clipped = pmin(pmax(area_km2, area_clip[[1]]), area_clip[[2]])
      ) %>%
        mutate(
          point_area = rescale(log10(area_km2_clipped), to = c(0.1, 2), from = log10(area_clip)),
          point_size = sqrt(point_area)
        )
      assign("cluster_area", area_data, envir = .figure_cache)
    }
    trend_sub <- bind_cols(trend_sub, get("cluster_area", envir = .figure_cache, inherits = FALSE))
  }

  if (include_accel) {
    if (!exists("cluster_accel", envir = .figure_cache, inherits = FALSE)) {
      sen_accel <- read_csv(file.path(rdata, "stl_sen_acceleration_masked.csv"),
        show_col_types = FALSE
      )
      assign("cluster_accel", tibble(accel = sen_accel$stl_accel_sen_slope_1e3[data$complete_idx]),
        envir = .figure_cache
      )
    }
    trend_sub <- bind_cols(trend_sub, get("cluster_accel", envir = .figure_cache, inherits = FALSE))
  }

  if (include_warming) {
    if (!exists("cluster_warming", envir = .figure_cache, inherits = FALSE)) {
      warming <- vapply(seq_len(nrow(data$trend_mat)), function(i) {
        sen_slope_40(data$trend_mat[i, ])
      }, numeric(1))
      assign("cluster_warming", tibble(warming = warming), envir = .figure_cache)
    }
    trend_sub <- bind_cols(trend_sub, get("cluster_warming", envir = .figure_cache, inherits = FALSE))
  }

  data$trend_sub <- trend_sub
  data
}

theme_atomic_base <- function(base_size = 10, grid = FALSE) {
  theme_bw(base_size = base_size) + theme(
    panel.grid = if (grid) {
      element_line(color = col_grid_light, linewidth = 0.2)
    } else {
      element_blank()
    },
    plot.title = element_text(face = "bold", size = 11, color = col_text),
    plot.subtitle = element_text(size = 8, color = col_subtitle),
    axis.title = element_text(face = "bold", size = 9),
    axis.text = element_text(size = 7),
    legend.key = element_rect(fill = col_panel_bg, colour = NA)
  )
}

theme_atomic_facet <- function(base_size = 10) {
  theme_atomic_base(base_size = base_size, grid = FALSE) + theme(
    strip.background = element_rect(
      fill = col_strip_bg, color = col_strip_border
    ),
    strip.text = element_text(face = "bold", size = 7),
    legend.position = "bottom"
  )
}

theme_atomic_map <- function(base_size = 10) {
  theme_bw(base_size = base_size) + theme(
    panel.grid = element_blank(),
    plot.title = element_text(face = "bold", size = 11, color = col_text),
    plot.subtitle = element_text(size = 8, color = col_subtitle),
    axis.title = element_text(face = "bold", size = 9),
    axis.text = element_text(size = 7),
    legend.key = element_rect(fill = col_panel_bg, colour = NA)
  )
}

save_figure <- function(filename, plot, width, height,
                        dpi = figure_dpi,
                        bg = figure_bg) {
  ggsave(file.path(out, filename), plot,
    width = width,
    height = height,
    dpi = dpi,
    bg = bg
  )
}
