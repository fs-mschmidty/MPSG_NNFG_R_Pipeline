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

  el_taxon_ids <- eligible_lists$current_eligible_list |>
    select(taxon_id, scientific_name, common_name)

  available_maps <- el_taxon_ids |>
    left_join(iucn_taxon_id, by = "taxon_id") |>
    filter(!is.na(sci_name)) |>
    rename(query_name = sci_name) |>
    mutate(file_path = path_to_shp)

  available_maps
}
