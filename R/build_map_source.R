#' This function takes in the maps that were retrieved by rbien, ebirdst and manually from IUCN and returns the eligible list with a source list of the maps.
#' @param el_list eligible list.
#' @param iucn_maps simple feature of IUCN maps.
#' @param bien_maps simple featuer of BIEN maps.
#' @param bird_maps simple feature of ebirdst maps.
build_map_source <- function(el_list, iucn_maps, bien_maps, bird_maps) {
  iucn_maps_cl <- iucn_maps |>
    as_tibble() |>
    distinct(taxon_id) |>
    mutate(source = "IUCN")

  bien_maps_cl <- bien_maps |>
    as_tibble() |>
    distinct(taxon_id) |>
    mutate(source = "BIEN")

  bird_maps_cl <- bird_maps |>
    as_tibble() |>
    distinct(taxon_id) |>
    mutate(source = "EBIRD")

  all_maps <- bind_rows(
    iucn_maps_cl,
    bien_maps_cl,
    bird_maps_cl
  )

  el_list |>
    select(taxon_id, scientific_name, common_name, kingdom:genus) |>
    left_join(all_maps, by = "taxon_id")
}
