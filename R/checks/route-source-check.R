# Static counterpart of route-checks.R for CI environments without research data.
# It verifies that every public legacy alias is recorded exactly once in the map.

source_files <- list.files(".", pattern = "\\.qmd$", recursive = TRUE, full.names = TRUE)
source_files <- source_files[!grepl("^./_output/", source_files)]

front_matter <- function(path) {
  lines <- readLines(path, warn = FALSE)
  if (length(lines) < 3L || lines[[1]] != "---") return(character())
  end <- which(lines[-1] == "---")[1]
  if (is.na(end)) return(character())
  lines[2:end]
}

rows <- lapply(source_files, function(path) {
  values <- grep("warming-acceleration|warming-temporal-pathways", front_matter(path), value = TRUE)
  if (!length(values)) return(NULL)
  route <- trimws(sub("^\\s*-\\s*", "", values))
  for (token in c('"', "'", "[", "]")) route <- gsub(token, "", route, fixed = TRUE)
  data.frame(
    legacy_path = route,
    source_path = sub("^\\./", "", path),
    current_path = sub("\\.qmd$", ".html", sub("^\\./", "", path)),
    stringsAsFactors = FALSE
  )
})
aliases <- do.call(rbind, Filter(Negate(is.null), rows))
if (is.null(aliases) || !nrow(aliases) || anyDuplicated(aliases$legacy_path)) {
  stop("Legacy aliases are missing or duplicated.")
}

route_map <- read.csv(file.path("config", "legacy-routes.csv"), stringsAsFactors = FALSE)
aliases <- aliases[order(aliases$legacy_path), ]
route_map <- route_map[order(route_map$legacy_path), ]
row.names(aliases) <- NULL
row.names(route_map) <- NULL
if (!identical(aliases, route_map)) stop("Legacy route map is stale or incomplete.")
message("Legacy source map valid for ", nrow(aliases), " routes.")
