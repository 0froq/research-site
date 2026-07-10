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
library(grid)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)

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

data <- file.path(data_process_dir, "steps")
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

col_line <- "grey20"

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

# Draw a ggplot/cowplot object inside a fixed-aspect viewport.
# This keeps the map + marginal panels from being stretched when the
# chunk device aspect ratio differs from the figure content aspect ratio.
draw_fixed_aspect <- function(plot, aspect = 4 / 3) {
  device_size <- grDevices::dev.size("in")
  device_aspect <- device_size[[1]] / device_size[[2]]

  if (device_aspect > aspect) {
    vp_width <- aspect / device_aspect
    vp_height <- 1
  } else {
    vp_width <- 1
    vp_height <- device_aspect / aspect
  }

  grid.newpage()
  print(
    plot,
    vp = viewport(
      width = unit(vp_width, "npc"),
      height = unit(vp_height, "npc")
    )
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

theme_atomic_base <- function(base_size = 10, grid = FALSE) {
  theme_bw(base_size = base_size) + theme(
    panel.grid = element_line(color = col_grid_light, linewidth = 0.3),
    plot.title = element_text(face = "bold", size = 14, color = col_text),
    plot.subtitle = element_text(size = 12, color = col_subtitle),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
  )
}

theme_atomic_facet <- function(base_size = 10) {
  theme_atomic_base(base_size = base_size, grid = FALSE) + theme(
    ggside.panel.background = element_blank(),
    ggside.panel.border = element_blank(),
    ggside.panel.grid = element_blank(),
    # ggside.axis.text = element_blank(),
    # ggside.axis.ticks = element_blank(),
    ggside.axis.title = element_blank(),
    ggside.axis.line.y.left = element_line(color = "grey20", linewidth = 0.3),
    ggside.axis.line.x.bottom = element_line(color = "grey20", linewidth = 0.3),
  )
}

theme_atomic_map <- function(base_size = 10) {
  theme_atomic_base(base_size = base_size) + theme(
    panel.grid = element_line(
      color = "grey85",
      linewidth = 0.3,
      linetype = "dashed"
    ),
    aspect.ratio = 5 / 12,
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
