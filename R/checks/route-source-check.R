# Static counterpart of route-checks.R for CI environments without research data.
# It verifies that every public legacy alias is recorded exactly once in the map.

source_files <- list.files(".", pattern = "\\.qmd$", recursive = TRUE, full.names = TRUE)
source_files <- source_files[!grepl("^./_output/", source_files)]
source_files <- source_files[!grepl("^./explorations/warming-temporal-pathways/archive/", source_files)]

front_matter <- function(path) {
  lines <- readLines(path, warn = FALSE)
  if (length(lines) < 3L || lines[[1]] != "---") return(character())
  end <- which(lines[-1] == "---")[1]
  if (is.na(end)) return(character())
  lines[2:end]
}

rows <- lapply(source_files, function(path) {
  header <- front_matter(path)
  matches <- regmatches(
    header,
    gregexpr("/explorations/(warming-acceleration|warming-temporal-pathways)/[^\"'\\]\\s,]+", header, perl = TRUE)
  )
  route <- unlist(matches, use.names = FALSE)
  if (!length(route)) return(NULL)
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

aliases <- aliases[order(aliases$legacy_path), ]
row.names(aliases) <- NULL

route_map_path <- file.path("config", "legacy-routes.csv")
if (identical(Sys.getenv("REGENERATE_LEGACY_ROUTE_MAP"), "1")) {
  write.csv(aliases, route_map_path, row.names = FALSE, quote = TRUE)
  message("Regenerated legacy route map for ", nrow(aliases), " routes.")
  quit(save = "no", status = 0)
}

route_map <- read.csv(route_map_path, stringsAsFactors = FALSE)
route_map <- route_map[order(route_map$legacy_path), ]
row.names(route_map) <- NULL
if (!identical(aliases, route_map)) stop("Legacy route map is stale or incomplete.")
message("Legacy source map valid for ", nrow(aliases), " routes.")
