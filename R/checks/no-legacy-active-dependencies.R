# Activity-boundary audit. Run from `site/`.
# Historical material under explorations/.../archive is deliberately exempt.

active_qmd <- list.files("explorations/warming-temporal-pathways", pattern = "\\.qmd$",
  recursive = TRUE, full.names = TRUE)
active_qmd <- active_qmd[!grepl("/archive/", active_qmd)]
active_r <- list.files("R", pattern = "\\.R$", recursive = TRUE, full.names = TRUE)
active_r <- active_r[!grepl("^R/checks/", active_r)]

legacy_qmd <- active_qmd[vapply(active_qmd, function(path) {
  any(grepl("shared/R|data-process/steps|/steps/", readLines(path, warn = FALSE)))
}, logical(1))]
if (length(legacy_qmd)) {
  stop("Active QMD files retain legacy helper/data paths: ", paste(legacy_qmd, collapse = ", "))
}

legacy_r <- active_r[vapply(active_r, function(path) {
  lines <- sub("#.*$", "", readLines(path, warn = FALSE))
  any(grepl('"[0-9]{2}-[^\"]+"[[:space:]]*,[[:space:]]*"output"|"steps/"', lines))
}, logical(1))]
if (length(legacy_r)) {
  stop("Active R helpers retain numbered-output paths: ", paste(legacy_r, collapse = ", "))
}

message("No active QMD or R helper depends on legacy numbered outputs.")
