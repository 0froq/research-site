# Rendering-time preparation for PCA stability contract figures.

prepare_pca_stability_contract_data <- function(data_dir = data) {
  cross_component_congruence <- read_csv(
    file.path(data_dir, "15-pca-stability", "output", "pca_cross_component_congruence.csv"),
    show_col_types = FALSE
  ) |>
    mutate(
      reference_pc = factor(paste0("Reference PC", reference_pc), levels = paste0("Reference PC", 2:5)),
      refit_pc = factor(paste0("Refit PC", refit_pc), levels = paste0("Refit PC", 2:9)),
      omitted_continent = factor(omitted_continent, levels = c("Europe", "North America", "Africa", "Asia", "Oceania", "South America"))
    )
  balanced_loco_congruence <- read_csv(
    file.path(data_dir, "16-spatial-balanced-pca", "output",
      "sinlat_equalarea_72x21_mean", "loco_cross_component_congruence.csv"),
    show_col_types = FALSE
  ) |>
    mutate(
      reference_pc = factor(paste0("Reference PC", reference_pc), levels = paste0("Reference PC", 2:5)),
      refit_pc = factor(paste0("Refit PC", refit_pc), levels = paste0("Refit PC", 2:9)),
      omitted_continent = factor(omitted_continent, levels = c("Europe", "North America", "Africa", "Asia", "Oceania", "South America"))
    )
  list(
    cross_component_congruence = cross_component_congruence,
    balanced_loco_congruence = balanced_loco_congruence
  )
}
