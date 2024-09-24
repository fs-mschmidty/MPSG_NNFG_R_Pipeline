#' This function takes in the eligible species list with the native an known determination and a list of species that that already have distribution maps and downloads occurrence data in North America from GBIF.
#' @param x df of eligible species
#' @param maps_list df of eligible species with maps
get_gbif_occ_data <- function(x, maps_list) {
  map_source_na <- maps_list |>
    filter(is.na(source)) |>
    distinct(taxon_id) |>
    pull(taxon_id)

  t_ids <- x |>
    filter(
      `Is the Species Native and Known to Occur` %in% c("?", "Yes"),
      taxon_id %in% map_source_na,
      !str_detect(usfws_status, "Threatened|Endangered") |
        is.na(usfws_status)
    ) |>
    distinct(taxon_id) |>
    pull(taxon_id)

  lapply(t_ids, function(x) {
    occ_r <- occ_search(x, continent = "north_america", limit = 20000)
    if (!is.null(occ_r$data)) {
      occ_r$data |>
        filter(!is.na(decimalLongitude) & !is.na(decimalLatitude)) |>
        st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), crs = 4326) |>
        mutate(taxon_id = x)
    }
  }) |>
    bind_rows()
}

# map_source_na <- tar_read(map_source) |>
#   filter(is.na(source)) |>
#   distinct(taxon_id) |>
#   pull(taxon_id)
#
# t_ids <- tar_read(output_dne_eligible_lists) |>
#   filter(
#     `Is the Species Native and Known to Occur` %in% c("?", "Yes"),
#     taxon_id %in% map_source_na,
#     !str_detect(usfws_status, "Threatened|Endangered") |
#       is.na(usfws_status)
#   ) |>
#   distinct(taxon_id) |>
#   pull(taxon_id)
