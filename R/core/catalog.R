# Shared dataset catalog for rendering-time R helpers.

read_data_catalog <- function() {
  path <- file.path(data_process_dir, "pipeline", "data-catalog.csv")
  if (!file.exists(path)) {
    path <- file.path(project_dir, "config", "data-catalog.csv")
  }
  readr::read_csv(path, show_col_types = FALSE)
}

dataset_dir <- function(id, catalog = read_data_catalog()) {
  match <- catalog[catalog$dataset_id == id, , drop = FALSE]
  if (nrow(match) != 1) stop("Unknown or duplicate dataset id: ", id)
  file.path(data_process_dir, match$path[[1]])
}

dataset_file <- function(id, ..., catalog = read_data_catalog()) {
  file.path(dataset_dir(id, catalog = catalog), ...)
}
