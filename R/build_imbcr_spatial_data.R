#' This cleans the IMBCR data from the raw download, adding a taxon_id() from the mpsgSO package. Note: this was failing due to fields that are empty "".
#' @param fp a file path to a .Rdata file including a raw download of IMBCR data.
#' @param x the name of the .Rdata file to parse.
build_imbcr_spatial_data <- function(fp, x) {
  attach(file.path(fp, x))

  sci_name <- sf_imbcr |>
    as_tibble() |>
    count(scientific_name) |>
    filter(scientific_name != "", !is.na(scientific_name)) |>
    select(scientific_name) |>
    get_taxonomies()

  sf_imbcr |>
    left_join(sci_name, by = "scientific_name")
}
