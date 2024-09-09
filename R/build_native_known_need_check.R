build_native_known_need_check <- function(x) {
  x$current_eligible_list |>
    rowwise() |>
    mutate(
      min_overall_year = min(c_across(contains("minYear")), na.rm = T),
      max_overall_year = max(c_across(contains("maxYear")), na.rm = T)
    ) |>
    ungroup() |>
    filter(
      sum_nObs < 7 |
        max_overall_year < (2024 - 40)
    ) |>
    select(taxon_id:common_name, NENHP_nObs:sum_nObs, max_overall_year, kingdom:family) |>
    mutate(
      "Is the Species Native and Known to Occur" = NA,
      "Justification for 'no'" = NA,
      "Supporting information (if needed) and BASI" = NA
    )
}
