#' This function takes in the eligible list and returns all species that have less than 7 observations in all databases or has the most recent observation within the last 40 years.
#' params x eligible species list. Note: again it is bad practice to put the whole list in here.
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
        max_overall_year < (2024 - 40) # may want to not hard code 2024 in here.
    ) |>
    select(taxon_id:common_name, NENHP_nObs:sum_nObs, max_overall_year, kingdom:family) |>
    mutate(
      "Is the Species Native and Known to Occur" = NA,
      "Justification for 'no'" = NA,
      "Supporting information (if needed) and BASI" = NA
    )
}
