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

# Colours
## Text
col_text <- "grey20"
col_text_soft <- "grey40"
col_title <- "black"
col_subtitle <- "black"
col_axis_title <- "grey20"
col_legend_title <- "grey20"

## Line / frame / ...
col_plot_border <- "white" # Not displayed
col_panel_border <- "black"
col_strip_border <- "grey80"
col_axis <- "grey20"
col_ticks <- "grey20"
col_ticks_major <- "grey20"
col_ticks_minor <- "grey40"
col_grid <- "grey60"
col_grid_major <- "grey60"
col_grid_minor <- "grey80"
col_inchart_line <- "black"
col_inchart_fill <- "grey55"
col_inchart_geom_border <- "grey20"
col_map_ele <- "grey20"
col_inchart_patch_border <- "grey20"

## Bg
col_plot_bg <- "white"
col_panel_bg <- "white"
col_strip_bg <- "white"
col_inchart_patch_bg <- "white"

# Size
## Text
siz_text <- 6
siz_title <- 10
siz_subtitle <- 8
siz_axis_title <- 8
siz_legend_title <- 8

## Linewidth
wid_plot_border <- 0 # Not displayed
wid_panel_border <- 0.4
wid_strip_border <- 0.3
wid_axis <- 0.3
wid_ticks <- 0.3
wid_ticks_major <- 0.3
wid_ticks_minor <- 0.2
wid_grid <- 0.2
wid_grid_major <- 0.2
wid_grid_minor <- 0
wid_inchart_line <- 0.4
wid_inchart_geom_border <- 0.3
wid_map_ele <- 0.5
wid_inchart_patch_border <- 0.3

# Theme elements
plot_title <- element_text(
  size = siz_title,
  face = "bold",
  colour = col_title
)

plot_subtitle <- element_text(
  size = siz_subtitle,
  colour = col_subtitle
)

axis_title <- element_text(
  size = siz_axis_title,
  colour = col_axis_title
)

axis_text <- element_text(
  colour = col_text,
  size = siz_text,
)

axis_ticks <- element_line(
  colour = col_ticks,
  linewidth = wid_ticks
)

axis_minor_ticks <- element_line(
  colour = col_ticks_minor,
  linewidth = wid_ticks_minor,
)

axis_line <- element_line(
  colour = col_axis,
  linewidth = wid_axis,
)

inchart_patch_bg <- element_rect(
  colour = col_inchart_patch_border,
  linewidth = wid_inchart_patch_border,
  fill = col_inchart_patch_bg
)

panel_bg <- element_rect(
  colour = col_panel_border,
  linewidth = wid_panel_border,
)

panel_grid <- element_line(
  colour = col_grid,
  linewidth = wid_grid,
  linetype = "dashed"
)

panel_grid_minor <- element_line(
  colour = col_grid_minor,
  linewidth = wid_grid_minor,
  linetype = "dashed"
)

strip_background <- element_rect(
  colour = col_strip_border,
  linewidth = wid_strip_border,
)

# Coastline from rnaturalearth
coast <- ne_coastline(scale = 110, returnclass = "sf")
coast_line <- st_cast(coast, "LINESTRING")
coast_df <- st_coordinates(coast_line) |> as.data.frame()
coast_df_plot <- coast_df |> filter(Y >= -60)

the_geom_coastline = function() {
  geom_path(
    data = coast_df_plot,
    aes(x = X, y = Y, group = L1),
    color = col_map_ele, linewidth = wid_map_ele
  )
}

# Themes
theme_base <- function(base_size = 10, grid = FALSE) {
  base_theme <- theme_void(base_size = base_size) +
    theme(
      text = axis_text,
      title = axis_title,
      axis.title = axis_title,
      axis.title.y = element_text(angle = 90),
      axis.text = axis_text,
      axis.ticks = axis_ticks,
      axis.minor.ticks = axis_minor_ticks,
      axis.ticks.length = unit(1, "mm"),
      axis.minor.ticks.length = unit(0.3, "mm"),
      axis.line = axis_line,
      legend.background = element_blank(),
      legend.margin = margin(5, 5, 5, 5),
      legend.spacing = unit(3, "mm"),
      legend.key.height = unit(3, "mm"),
      legend.frame = inchart_patch_bg,
      legend.ticks = axis_ticks,
      legend.ticks.length = unit(1, "mm"),
      legend.axis.line = axis_line,
      legend.text = element_text(size = 6),
      legend.title = axis_title,
      legend.title.position = "top",
      legend.position = "inside",
      legend.direction = "horizontal",
      legend.justification = c(0, 0),
      legend.location = "panel",
      panel.background = element_blank(),
      panel.border = panel_bg,
      plot.background = element_blank(),
      plot.title = plot_title,
      plot.title.position = "panel",
      plot.caption.position = "panel",
      plot.subtitle = plot_subtitle,
      plot.margin = margin(5, 5, 5, 5),
      strip.background = strip_background,
      strip.text = plot_subtitle,
      strip.text.y = element_text(angle = -90),
    )

  if (grid) base_theme + theme_grid() else base_theme
}

theme_grid <- function(base_size = 10) {
  theme(
    panel.grid = panel_grid,
    panel.grid.minor = panel_grid_minor,
  )
}


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


theme_facet <- function(base_size = 10) {
  theme(
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

theme_map <- function(base_size = 10) {
  theme_base(base_size = base_size) + theme(
    aspect.ratio = 5 / 12,
  )
}

theme_map_grid <- function(base_size = 10) {
  theme_map(base_size = base_size) +
    theme_grid() +
    theme(
      panel.grid = element_line(
        colour = col_grid_minor,
        linewidth = wid_grid,
        linetype = "dashed"
      )
    )
}

theme_scatter_matrix <- function(base_size = 7.5, grid = TRUE, ticks = grid) {
  matrix_theme <- theme_base(base_size = base_size, grid = grid) +
    theme(
      panel.background = element_rect(fill = col_panel_bg, colour = NA),
      panel.border = panel_bg,
      axis.title = element_blank(),
      plot.margin = margin(1.5, 1.5, 1.5, 1.5)
    )

  if (!ticks) {
    matrix_theme <- matrix_theme + theme(
      axis.ticks = element_blank(),
      axis.minor.ticks = element_blank()
    )
  }

  matrix_theme
}

theme_inchart_table <- function() {
  theme_void() +
    theme(plot.background = inchart_patch_bg)
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
