build_spatial_eligible_and_unit <- function(x, admin_bd, eligible_list) {
  t_ids <- eligible_list |>
    pull(taxon_id)

  eligible <- x |>
    filter(taxon_id %in% t_ids)

  admin_bd_cl <- admin_bd |>
    st_union() |>
    st_as_sf()

  eligible_unit <- eligible |>
    st_intersection(admin_bd_cl)

  lst(eligible, eligible_unit)
}
