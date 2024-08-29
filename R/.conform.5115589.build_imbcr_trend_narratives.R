build_imbcr_trend_narratives <- function(imbcr_grass, imbcr_bcr18) {
  trend_narratives <- imbcr_grass |>
    filter(str_detect(stratum, "^NE|^SD|^USFS")) |>
    rowwise() |>
    mutate(
      stratum = case_when(
        stratum == "NE-BCR18" ~ "NE-BCR18: Shortgrass Prairie Region in Nebraska",
        stratum == "SD-BCR18" ~ "SD-BCR18: Shortgrass Prairie Region in South Dakota",
        str_detect(stratum, "^USFS-Region") ~ glue("USFS-R2-Grasslands: {stratum}"),
        TRUE ~ stratum
      ),
      stratum_name = str_split(stratum, ": ")[[1]][2],
      stratum_short_code = str_split(stratum, ": ")[[1]][1],
      d_t = round(as.numeric(percent_change_yr_density), 2),
      lcl95_d = round(as.numeric(lcl95_d), 2),
      ucl95_d = round(as.numeric(ucl95_d), 2),
      d_n_p = case_when(
        d_t > 0 & as.numeric(f_density_trend) > 0.9 ~ "estimated a increasing",
        d_t < 0 & as.numeric(f_density_trend) > 0.9 ~ "estimated a decreasing",
        TRUE ~ "estimated an uncertain"
      ),
      o_t = round(as.numeric(percent_change_yr_occupancy), 2),
      lcl95_occ = round(as.numeric(lcl95_occ), 2),
      ucl95_occ = round(as.numeric(ucl95_occ), 2),
      o_t_p = case_when(
        o_t > 0 & as.numeric(f_occupancy_trend) > 0.9 ~ "estimated a increasing",
        o_t < 0 & as.numeric(f_occupancy_trend) > 0.9 ~ "estimated a decreasing",
        TRUE ~ "estimated an uncertain"
      ),
      narrative = glue("Surveys conducted by the Bird Conservancy of the Rockies on the {stratum_name} ({stratum_short_code}), {d_n_p} median density population trend of {d_t}% [95% CL {lcl95_d}%, {ucl95_d}%] per year and {o_t_p} median occupancy trend of {o_t}% [95% CL {lcl95_occ}%, {ucl95_occ}%] per year from {str_replace(years,'-', ' to ')}.")
    )

  trend_narratives_bcr18 <- imbcr_bcr18 |>
    mutate(stratum = "BCR18: Shortgrass Prairie Region") |>
    mutate(
      stratum_name = str_split(stratum, ": ")[[1]][2],
      stratum_short_code = str_split(stratum, ": ")[[1]][1],
      d_t = round(as.numeric(percent_change_yr_density), 2),
      lcl95_d = round(as.numeric(lcl95_d), 2),
      ucl95_d = round(as.numeric(ucl95_d), 2),
      d_n_p = case_when(
        d_t > 0 & as.numeric(f_density_trend) > 0.9 ~ "estimated a increasing",
        d_t < 0 & as.numeric(f_density_trend) > 0.9 ~ "estimated a decreasing",
        TRUE ~ "estimated an uncertain"
      ),
      o_t = round(as.numeric(percent_change_yr_occupancy), 2),
      lcl95_occ = round(as.numeric(lcl95_occ), 2),
      ucl95_occ = round(as.numeric(ucl95_occ), 2),
      o_t_p = case_when(
        o_t > 0 & as.numeric(f_occupancy_trend) > 0.9 ~ "estimated a increasing",
        o_t < 0 & as.numeric(f_occupancy_trend) > 0.9 ~ "estimated a decreasing",
        TRUE ~ "estimated an uncertain"
      ),
      narrative = glue("Surveys conducted by the Bird Conservancy of the Rockies on the {stratum_name} ({stratum_short_code}), {d_n_p} median density population trend of {d_t}% [95% CL {lcl95_d}%, {ucl95_d}%] per year and {o_t_p} median occupancy trend of {o_t}% [95% CL {lcl95_occ}%, {ucl95_occ}%] per year from {str_replace(years,'-', ' to ')}.")
    )

  combined_trend_narratives <- trend_narratives |>
    bind_rows(trend_narratives_bcr18)

  combined_trend_narratives
  # imbcr_grass_cl <- imbcr_grass |>
  #   clean_names() |>
  #   filter(str_detect(stratum, "^NE|^SD|^USFS")) |>
  #   rename(common_name = species)

  # common_names <- imbcr_for_ks_ne |>
  #   count(common_name) |>
  #   pull(common_name)
  #
  # resolve_common_name <- comm2sci(common_names, db = "itis", simplify = FALSE)
  #
  # sci_names <- imap(
  #   resolve_common_name,
  #   function(x, y) {
  #     if (nrow(x) != 0) {
  #       x |>
  #         mutate(common_name = y) |>
  #         filter(!is.na(unitname2)) |>
  #         head(1)
  #     }
  #   }
  # ) |>
  #   bind_rows() |>
  #   select(scientific_name = combinedname, common_name) |>
  #   get_taxonomies()
  #
  # imbcr_grass_cl |>
  #   left_join(sci_names, by = "common_name")
}
