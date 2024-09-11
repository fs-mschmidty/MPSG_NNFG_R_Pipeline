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
