#' this function just takes in all of the occupancy data from each of the respective occuncy data sources and combines them into a single object.
build_all_occ_data <- function(x) {
  lapply(x, function(x) {
    x$eligible_unit |>
      select(taxon_id) |>
      mutate(taxon_id = as.character(taxon_id))
  }) |>
    bind_rows()
}
