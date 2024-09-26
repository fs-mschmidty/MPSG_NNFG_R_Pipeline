build_bbs_trend_narratives <- function() {
  regions <- c("S18", "NEB", "SD", "US1", "S17")
  regions_long_names <- c("the Shortgrass Prairie Bird Conservation Region (S18)", "Nebraska", "South Dakota", "the United States", "the Badlands and Prairies Bird Conservation Region (S17)")
  region_df <- tibble(region = regions, region_long_name = regions_long_names)


  bbs_narratives <- core_trend |>
    filter(region %in% regions) |>
    left_join(region_df, by = "region") |>
    mutate(
      trend_description = case_when(
        significance == 1 ~ "increasing",
        significance == 2 ~ "decreasing",
        is.na(significance) ~ "uncertain"
      ),
      narrative_chunk = glue("in {region_long_name} the trend is {trend_description} with a trend of {trend}% [95% CI {x2_5_percent_ci}%, {x97_5_percent_ci}%]")
    ) |>
    group_by(species_name) |>
    summarize(
      narrative_total_chunk = paste(narrative_chunk, collapse = "; "),
      n = n()
    ) |>
    mutate(
      citation = "{Hostelter et al. 2023}",
      narrative_total_chunk = ifelse(n == 2, str_replace(narrative_total_chunk, ";", " and"), str_replace(narrative_total_chunk, ";(?=[^;]*$)", ", and")),
      narrative_total_chunk = str_replace(narrative_total_chunk, "i", "I"),
      narrative_total_chunk = str_replace_all(narrative_total_chunk, ";", ","),
      final_narrative = glue("The USGS estimates population trend with data from the North American Breeding Bird Survey collected from 1966 to 2022. {narrative_total_chunk} {citation}.")
    )
}
