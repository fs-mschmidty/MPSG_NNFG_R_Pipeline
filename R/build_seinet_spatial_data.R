build_seinet_spatial_data <- function(fp, x) {
  attach(file.path(fp, x))

  df_names <- sf_seinet |>
    st_drop_geometry() |>
    as_tibble() |>
    count(scientificName) |>
    rename(scientific_name = scientificName) |>
    filter(scientific_name != "")

  taxonomies <- df_names |>
    get_taxonomies(query_field = "scientific_name")

  sf_seinet |>
    rename(scientific_name = scientificName) |> 
    left_join(taxonomies, by = "scientific_name")
}
