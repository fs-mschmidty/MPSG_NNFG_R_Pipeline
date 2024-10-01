#' This function builds a single narrative from narratives by strata from IMBCR.
#' @params imbcr_grass a spreadsheet of IMBCR trends that is requested from Jennifer Timmer.
#' @notes: This could probably be further automated if you setup a cleaning step to make sure the input was filtered and the strata were all correctly formated. Also the output would need some sort of appropriate input for the opening narrative.
build_imbcr_trend_narratives <- function(imbcr_grass) {
  trend_narratives <- imbcr_grass |>
    filter(str_detect(stratum, "^NE|^SD|^BCR18|^Nebraska")) |>
    filter(stratum != "NE-BCR17") |>
    rowwise() |>
    mutate(
      stratum = case_when(
        stratum == "NE-BCR18" ~ "NE-BCR18: Shortgrass Prairie Region in Nebraska",
        stratum == "SD-BCR18" ~ "SD-BCR18: Shortgrass Prairie Region in South Dakota",
        stratum == "SD-BCR17" ~ "SD-BCR17: Badlands and Prairies in South Dakota",
        stratum == "BCR18" ~ "BCR18: Shortgrass Prairie Region",
        str_detect(stratum, "^Nebraska National Grasslands") ~ glue("NNG: {stratum}"),
        str_detect(stratum, "^Nebraska National Forests") ~ glue("NNF: {stratum}"),
        str_detect(stratum, "^USFS-Region") ~ glue("USFS-R2-Grasslands: {stratum}"),
        TRUE ~ stratum
      ),
      stratum_name = str_split(stratum, ": ")[[1]][2],
      stratum_short_code = str_split(stratum, ": ")[[1]][1],
      order = case_when(
        str_detect(stratum_short_code, "^[A-Z]{2}-BCR[1-9]{2}-") ~ 1,
        str_detect(stratum_short_code, "NNF|NNG") ~ 2,
        str_detect(stratum_short_code, "^[A-Z]{2}-BCR[1-9]{2}") ~ 3,
        TRUE ~ 4
      ),
      d_t = round(as.numeric(percent_change_yr_density), 2),
      lcl95_d = round(as.numeric(lcl95_d), 2),
      ucl95_d = round(as.numeric(ucl95_d), 2),
      d_n_p = case_when(
        d_t > 0 & as.numeric(f_density_trend) >= 0.9 ~ "estimated a increasing",
        d_t < 0 & as.numeric(f_density_trend) >= 0.9 ~ "estimated a decreasing",
        TRUE ~ "estimated an uncertain"
      ),
      o_t = round(as.numeric(percent_change_yr_occupancy), 2),
      lcl95_occ = round(as.numeric(lcl95_occ), 2),
      ucl95_occ = round(as.numeric(ucl95_occ), 2),
      o_t_p = case_when(
        o_t > 0 & as.numeric(f_occupancy_trend) >= 0.9 ~ "estimated a increasing",
        o_t < 0 & as.numeric(f_occupancy_trend) >= 0.9 ~ "estimated a decreasing",
        TRUE ~ "estimated an uncertain"
      ),
      narrative_single = glue("{stratum_name} ({stratum_short_code}) {d_n_p} median density population trend of {d_t}% [95% CL {lcl95_d}%, {ucl95_d}%, (n={label_comma()(no_of_detections)}, f={round(as.numeric(f_density_trend), 3)})] per year and {o_t_p} median occupancy trend of {o_t}% [95% CL {lcl95_occ}%, {ucl95_occ}%, (n={label_comma()(no_of_points)}, f={round(round(f_occupancy_trend), 3)})] per year from {str_replace(years,'-', ' to ')}")
    ) |>
    arrange(order, stratum_name) |>
    group_by(species) |>
    summarize(narrative = paste(narrative_single, collapse = "; "), n = n()) |>
    ungroup() |>
    mutate(narrative = glue("Surveys were conducted by the Bird Conservations of the Rockies on the Nebraska National Forests and Grasslands. Trend estimates are considered robust if the f-statistic is greater than or equal to 0.9 and uncertain if they are less than 0.9. Surveys reported the following trends by strata: {narrative}."))
  trend_narratives
}
