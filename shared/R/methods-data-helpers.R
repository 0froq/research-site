# Rendering-time preparation for the Methods data-coverage figure.
# Depends on figure-style.R and descriptive-helpers.R.

prepare_methods_data <- function(data_dir = data) {
  raw_monthly <- readr::read_csv(
    file.path(data_dir, "01-monthly-temperature", "output", "monthly_temperature.csv"),
    show_col_types = FALSE,
    col_select = c(lake_id, lon, lat)
  )
  lake_meta_data <- readr::read_csv(
    file.path(data_dir, "00-lake-metadata", "output", "lake_metadata.csv"),
    show_col_types = FALSE
  )

  list(
    lake_density_data = bin_lake_locations(raw_monthly |> dplyr::select(lon, lat)),
    continent_bar = make_continent_inchart(make_continent_summary(lake_meta_data))
  )
}
