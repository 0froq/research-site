# Rendering-time preparation for descriptive cooling-season and ice diagnostics.

prepare_seasonal_ice_data <- function(data_dir = data) {
  diagnostics <- read_csv(
    file.path(data_dir, "14-trajectory-diagnostics", "output", "trajectory_diagnostics.csv"),
    show_col_types = FALSE
  )
  seasonal_columns <- unlist(lapply(c("full", "late"), function(window)
    paste0(c("annual", "DJF", "MAM", "JJA", "SON"), "_", window, "_sen_40yr")
  ))
  seasonal_long <- diagnostics |>
    mutate(
      cooling_period = case_when(
        annual_full_sen_40yr < 0 & annual_late_sen_40yr < 0 ~ "Cooling in both periods",
        annual_full_sen_40yr < 0 ~ "Full-period cooling only",
        annual_late_sen_40yr < 0 ~ "Late-period cooling only",
        TRUE ~ "No cooling in either period"
      ),
      latitude_band = case_when(
        abs(lat) < 35 ~ "Low latitude (<35°)",
        abs(lat) < 45 ~ "Mid latitude (35–45°)",
        TRUE ~ "Mid/high latitude (≥45°)"
      ),
      baseline_ice_band = case_when(
        ice_days_baseline_1981_1990_mean < 30 ~ "Low ice (<30 days)",
        ice_days_baseline_1981_1990_mean < 120 ~ "Seasonal ice (30–119 days)",
        TRUE ~ "Long ice (≥120 days)"
      )
    ) |>
    pivot_longer(all_of(seasonal_columns), names_to = "series", values_to = "trend_40yr") |>
    mutate(
      season = sub("_.*", "", series),
      window = sub(".*_(full|late)_.*", "\\1", series),
      season = factor(season, levels = c("annual", "DJF", "MAM", "JJA", "SON"),
        labels = c("Annual", "DJF", "MAM", "JJA", "SON")),
      cooling_period = factor(cooling_period, levels = c(
        "Cooling in both periods", "Full-period cooling only",
        "Late-period cooling only", "No cooling in either period"
      )),
      window = factor(window, levels = c("full", "late"), labels = c("1981–2020", "2001–2020"))
    )
  cooling_summary <- diagnostics |>
    summarise(
      n = n(),
      full_cooling = sum(annual_full_sen_40yr < 0, na.rm = TRUE),
      late_cooling = sum(annual_late_sen_40yr < 0, na.rm = TRUE),
      both_cooling = sum(annual_full_sen_40yr < 0 & annual_late_sen_40yr < 0, na.rm = TRUE),
      summer_dominant_mid_high = sum(
        summer_dominant_late_cooling == TRUE & abs(lat) >= 45, na.rm = TRUE
      )
    )
  list(diagnostics = diagnostics, seasonal_long = seasonal_long, cooling_summary = cooling_summary)
}
