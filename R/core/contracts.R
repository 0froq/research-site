require_columns <- function(data, columns, dataset = deparse(substitute(data))) {
  absent <- setdiff(columns, names(data))
  if (length(absent)) stop(dataset, " is missing required columns: ", paste(absent, collapse = ", "))
  invisible(data)
}

require_file <- function(path, label = path) {
  if (!file.exists(path)) stop("Missing required input: ", label, " (", path, ")")
  invisible(path)
}
