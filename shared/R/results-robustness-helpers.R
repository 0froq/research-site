# Rendering-time preparation for Results robustness section.

prepare_results_robustness_data <- function(data_dir = data) {
  root <- file.path(data_dir, "16-spatial-balanced-pca", "output")
  active <- file.path(root, "sinlat_equalarea_72x21_mean")
  reference_loadings <- read_csv(file.path(active, "pca_loadings.csv"), show_col_types = FALSE)

  loading_alignment <- function(reference, refit, reference_pcs, refit_pcs = reference_pcs) {
    shared <- inner_join(reference, refit, by = "year", suffix = c("_ref", "_refit"))
    ref <- as.matrix(shared[, paste0("pc", reference_pcs, "_ref")])
    candidate <- as.matrix(shared[, paste0("pc", refit_pcs, "_refit")])
    # Restricting a full-period loading to retained years destroys its original
    # orthonormality. QR gives comparable orthonormal bases before the SVD.
    ref_basis <- qr.Q(qr(ref))[, seq_along(reference_pcs), drop = FALSE]
    candidate_basis <- qr.Q(qr(candidate))[, seq_along(refit_pcs), drop = FALSE]
    cosines <- svd(crossprod(ref_basis, candidate_basis))$d
    tibble(
      n_years = nrow(shared),
      min_cosine = min(cosines),
      mean_cosine = mean(cosines),
      max_angle_deg = max(acos(pmin(1, pmax(-1, cosines))) * 180 / pi),
      mean_angle_deg = mean(acos(pmin(1, pmax(-1, cosines))) * 180 / pi)
    )
  }
  pc1_alignment <- function(reference, refit) {
    shared <- inner_join(reference, refit, by = "year", suffix = c("_ref", "_refit"))
    tibble(
      n_years = nrow(shared),
      cosine = abs(sum(shared$pc1_ref * shared$pc1_refit) /
        sqrt(sum(shared$pc1_ref^2) * sum(shared$pc1_refit^2)))
    )
  }
  loco <- read_csv(file.path(active, "loco_subspace_stability.csv"), show_col_types = FALSE) |>
    mutate(omitted_continent = factor(omitted_continent, levels = c("Europe", "North America", "Asia", "Africa", "South America", "Oceania")))
  loco_cross <- read_csv(file.path(active, "loco_cross_component_congruence.csv"), show_col_types = FALSE) |>
    filter(reference_pc %in% 2:3, refit_pc %in% 2:5) |>
    mutate(
      omitted_continent = factor(omitted_continent, levels = levels(loco$omitted_continent)),
      reference_pc = factor(paste0("PC", reference_pc)),
      refit_pc = factor(paste0("PC", refit_pc))
    )
  loco_refit_loadings <- read_csv(file.path(active, "loco_refit_loadings.csv"), show_col_types = FALSE)
  loco_pc1 <- split(loco_refit_loadings, loco_refit_loadings$omitted_continent) |>
    lapply(\(refit) pc1_alignment(reference_loadings, refit) |>
      mutate(omitted_continent = unique(refit$omitted_continent))) |>
    bind_rows() |>
    mutate(omitted_continent = factor(omitted_continent, levels = levels(loco$omitted_continent)))

  lodo_blocks <- c("1981–1990", "1991–2000", "2001–2010", "2011–2020")
  lodo_paths <- c(
    "sinlat_equalarea_72x21_mean_omit1981_1990",
    "sinlat_equalarea_72x21_mean_omit1991_2000",
    "sinlat_equalarea_72x21_mean_omit2001_2010",
    "sinlat_equalarea_72x21_mean_omit2011_2020"
  )
  lodo <- bind_rows(Map(function(block, path) {
    refit <- read_csv(file.path(root, path, "pca_loadings.csv"), show_col_types = FALSE)
    pc1_alignment(reference_loadings, refit) |>
      mutate(metric = "PC1 alignment", omitted_block = block) |>
      transmute(omitted_block, metric, value = cosine, n_years) |>
      bind_rows(
        loading_alignment(reference_loadings, refit, 2:3) |>
          mutate(metric = "PC2–PC3 subspace", omitted_block = block) |>
          transmute(omitted_block, metric, value = min_cosine, n_years)
      )
  }, lodo_blocks, lodo_paths)) |>
    mutate(
      omitted_block = factor(omitted_block, levels = lodo_blocks),
      metric = factor(metric, levels = c("PC1 alignment", "PC2–PC3 subspace"))
    )
  lodo_detail <- bind_rows(Map(function(block, path) {
    refit <- read_csv(file.path(root, path, "pca_loadings.csv"), show_col_types = FALSE)
    pc1 <- pc1_alignment(reference_loadings, refit)
    pc23 <- loading_alignment(reference_loadings, refit, 2:3)
    tibble(
      omitted_block = block,
      pc1_cosine = pc1$cosine,
      pc23_min_cosine = pc23$min_cosine,
      pc23_max_angle_deg = pc23$max_angle_deg,
      pc23_mean_angle_deg = pc23$mean_angle_deg,
      n_years = pc1$n_years
    )
  }, lodo_blocks, lodo_paths)) |>
    mutate(omitted_block = factor(omitted_block, levels = lodo_blocks))
  branches <- c(
    "Raw annual" = "raw_annual_sinlat_equalarea_72x21_mean",
    "7-year rolling" = "rolling7_annual_sinlat_equalarea_72x21_mean",
    "9-year rolling" = "rolling9_annual_sinlat_equalarea_72x21_mean",
    "11-year rolling" = "rolling11_annual_sinlat_equalarea_72x21_mean",
    "36 × 11 grid" = "sinlat_equalarea_36x11_mean",
    "144 × 42 grid" = "sinlat_equalarea_144x42_mean"
  )
  branch_congruence <- bind_rows(lapply(names(branches), function(label) {
    path <- file.path(root, branches[[label]], "reference_cross_component_congruence.csv")
    read_csv(path, show_col_types = FALSE, col_types = cols(.default = col_character())) |>
      mutate(
        reference_pc = readr::parse_number(reference_pc),
        balanced_pc = readr::parse_number(balanced_pc),
        congruence = readr::parse_number(congruence)
      ) |>
      filter(reference_pc %in% 1:3, balanced_pc %in% 1:5, is.finite(congruence)) |>
      group_by(reference_pc) |>
      summarise(best_congruence = max(congruence), matched_pc = balanced_pc[which.max(congruence)], .groups = "drop") |>
      mutate(branch = label)
  })) |>
    mutate(branch = factor(branch, levels = names(branches)), reference_pc = factor(paste0("PC", reference_pc), levels = paste0("PC", 1:3)))
  branch_variance <- bind_rows(lapply(names(branches), function(label) {
    read_csv(file.path(root, branches[[label]], "pca_variance.csv"), show_col_types = FALSE) |>
      filter(pc <= 10) |>
      mutate(branch = label)
  })) |>
    mutate(branch = factor(branch, levels = names(branches)))
  raw_input_match <- read_csv(
    file.path(root, branches[["Raw annual"]], "reference_cross_component_congruence.csv"),
    show_col_types = FALSE,
    col_types = cols(.default = col_character())
  ) |>
    mutate(
      reference_pc = readr::parse_number(reference_pc),
      comparison_pc = readr::parse_number(balanced_pc),
      congruence = readr::parse_number(congruence)
    ) |>
    filter(reference_pc <= 5, comparison_pc <= 9) |>
    group_by(reference_pc) |>
    slice_max(congruence, n = 1, with_ties = FALSE) |>
    ungroup() |>
    mutate(reference_pc = factor(paste0("PC", reference_pc), levels = paste0("PC", 1:5)))
  list(
    loco = loco,
    loco_cross = loco_cross,
    loco_pc1 = loco_pc1,
    lodo = lodo,
    lodo_detail = lodo_detail,
    branch_congruence = branch_congruence,
    branch_variance = branch_variance,
    raw_input_match = raw_input_match
  )
}
