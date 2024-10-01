#' This function checks a IUCN shapefile to determine which species overlap the NNFG body and then runs taxonomies on those that do and then returns a list of those species that are on the eligible species.
#' @param path_to_shp path to a IUCN range map shapefile.
#' @param eligible_lists a list of eligible lists with current_eligible_list in it. NOTE:see refactor comment below.
#' @param nnfg_bd the NNFG body. NOTE: I may add in a buffer to this that is quite liberal in the future.
build_iucn_available_maps <- function(path_to_shp, eligible_lists, nnfg_bd) {
  sf_use_s2(FALSE)

  iucn_shp <- st_read(path_to_shp) |>
    st_make_valid()

  nnfg_bd_cl <- nnfg_bd |>
    st_transform(st_crs(iucn_shp)) |>
    st_make_valid()

  iucn_unit_sp <- iucn_shp |>
    st_crop(nnfg_bd_cl)

  unit_sp_w_taxonomies <- iucn_unit_sp |>
    as_tibble() |>
    count(sci_name) |>
    get_taxonomies(query_field = "sci_name")

  iucn_taxon_id <- unit_sp_w_taxonomies |>
    select(sci_name, taxon_id)

  # I would change this so that you don't  need to subset a list $ and just add an input for a list.
  el_taxon_ids <- eligible_lists$current_eligible_list |>
    select(taxon_id, scientific_name, common_name)

  available_maps <- el_taxon_ids |>
    left_join(iucn_taxon_id, by = "taxon_id") |>
    filter(!is.na(sci_name)) |>
    rename(query_name = sci_name) |>
    mutate(file_path = path_to_shp)

  available_maps
}
