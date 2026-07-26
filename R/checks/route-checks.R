# Verify legacy aliases and moved-page redirect targets after a Quarto render.
# Run from `site/`: Rscript R/checks/route-checks.R

source_files <- list.files(".", pattern = "\\.qmd$", recursive = TRUE, full.names = TRUE)
source_files <- source_files[!grepl("^./_output/", source_files)]

front_matter <- function(path) {
  lines <- readLines(path, warn = FALSE)
  if (length(lines) < 3L || lines[[1]] != "---") return(character())
  end <- which(lines[-1] == "---")[1]
  if (is.na(end)) return(character())
  lines[2:end]
}

alias_rows <- lapply(source_files, function(path) {
  header <- front_matter(path)
  values <- grep("warming-acceleration|warming-temporal-pathways", header, value = TRUE)
  if (!length(values)) return(NULL)
  route <- sub("^\\s*-\\s*", "", values)
  route <- gsub('"', "", route, fixed = TRUE)
  route <- gsub("'", "", route, fixed = TRUE)
  route <- gsub("[", "", route, fixed = TRUE)
  route <- gsub("]", "", route, fixed = TRUE)
  data.frame(source = path, route = trimws(route), stringsAsFactors = FALSE)
})
aliases <- do.call(rbind, Filter(Negate(is.null), alias_rows))

if (is.null(aliases) || !nrow(aliases)) stop("No legacy aliases discovered.")
if (anyDuplicated(aliases$route)) stop("Duplicate legacy alias routes found.")

route_map_path <- file.path("config", "legacy-routes.csv")
if (!file.exists(route_map_path)) stop("Legacy route map is missing: ", route_map_path)
route_map <- read.csv(route_map_path, stringsAsFactors = FALSE)
required_columns <- c("legacy_path", "source_path", "current_path")
if (!identical(names(route_map), required_columns)) {
  stop("Legacy route map must contain exactly: ", paste(required_columns, collapse = ", "))
}
if (anyDuplicated(route_map$legacy_path)) stop("Duplicate legacy paths in route map.")
expected_map <- data.frame(
  legacy_path = aliases$route,
  source_path = sub("^\\./", "", aliases$source),
  current_path = sub("\\.qmd$", ".html", sub("^\\./", "", aliases$source)),
  stringsAsFactors = FALSE
)
route_map <- route_map[order(route_map$legacy_path), ]
expected_map <- expected_map[order(expected_map$legacy_path), ]
row.names(route_map) <- NULL
row.names(expected_map) <- NULL
if (!identical(route_map, expected_map)) {
  stop("Legacy route map does not match the current Quarto aliases. Regenerate it intentionally.")
}

targets <- file.path("_output", sub("\\.qmd$", ".html", aliases$source))
missing <- aliases$source[!file.exists(targets)]
if (length(missing)) stop("Rendered target missing for: ", paste(missing, collapse = ", "))

moved <- c(
  "explorations/warming-temporal-pathways/manuscript/results/02-seasonal-ice-context.qmd",
  "explorations/warming-temporal-pathways/manuscript/results/06-teleconnection-candidate-atlas.qmd",
  "explorations/warming-temporal-pathways/manuscript/results/07-candidate-tables.qmd"
)
for (path in moved) {
  target <- sub("\\.qmd$", ".html", file.path("_output", path))
  text <- paste(readLines(target, warn = FALSE), collapse = "\n")
  if (!grepl('http-equiv="refresh"', text, fixed = TRUE)) {
    stop("Moved route lacks a redirect: ", path)
  }
}

message("Route checks passed for ", nrow(aliases), " legacy aliases and ", length(moved), " moved pages.")
