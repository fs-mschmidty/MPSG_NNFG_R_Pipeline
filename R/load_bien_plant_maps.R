load_bien_plant_maps <- function(folder, eligible_list) {
  files <- list.files(folder, pattern = ".shp$", full.names = T)

  all_maps <- lapply(files, st_read) |>
    bind_rows() |>
    mutate(scientific_name = str_replace_all(species, "_", " "))

  el_list_cl <- eligible_list |>
    select(scientific_name, taxon_id)

  all_maps_cl <- all_maps |>
    left_join(el_list_cl, by = "scientific_name")

  get_missing_taxon_ids <- all_maps_cl |>
    filter(is.na(taxon_id)) |>
    select(-taxon_id) |>
    as_tibble() |>
    get_taxonomies() |>
    select(scientific_name, taxon_id)

  finalized_taxon_ids <- el_list_cl |>
    bind_rows(get_missing_taxon_ids)

  all_maps |>
    left_join(finalized_taxon_ids) |>
    select(scientific_name, taxon_id, species, gid)
}
