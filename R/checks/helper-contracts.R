# Fast contract checks for the helpers used by the active manuscript. Run from
# `site/`: Rscript R/checks/helper-contracts.R

source("R/core/style.R")
source("R/core/spatial.R")
source("R/domains/kinematics.R")
source("R/domains/pathways.R")
source("R/figures/results/01-global-kinematics.R")
source("R/figures/results/04-spatial-organization.R")
source("R/figures/results/05-trajectory-robustness.R")

kinematics <- prepare_kinematics_data()
stopifnot(nrow(kinematics$lake_warming_metrics) > 0L)
stopifnot(!anyDuplicated(kinematics$lake_warming_metrics$lake_id))

results_kinematics <- prepare_results_kinematics_data(kinematics)
stopifnot(nrow(results_kinematics$fig1_grid) > 0L)

pca <- prepare_pca_data()
stopifnot(nrow(pca$pca_cell_scores) > 0L)
stopifnot(all(c("pc1", "pc2", "pc3", "pc4", "pc5") %in% names(pca$pca_cell_scores)))

spatial <- prepare_results_pca_data(pca)
stopifnot(nrow(spatial$pathway_overlap) > 0L)

robustness <- prepare_results_robustness_data()
stopifnot(nrow(robustness$loco) > 0L, nrow(robustness$lodo) > 0L)

message("Active manuscript helper contracts passed.")
