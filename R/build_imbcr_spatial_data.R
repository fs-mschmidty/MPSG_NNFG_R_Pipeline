build_imbcr_spatial_data <- function(fp, x) {
  attach(file.path(fp, x))

  common_names <- sf_imbcr |>
    count(Species) |>
    pull(Species)

  resolve_common_name <- comm2sci(common_names, db = "itis", simplify = FALSE)

  sci_names <- imap(
    resolve_common_name,
    function(x, y) {
      if (nrow(x) != 0) {
        x |>
          mutate(common_name = y) |>
          filter(!is.na(unitname2)) |>
          head(1)
      }
    }
  ) |>
    bind_rows() |>
    select(scientific_name = combinedname, common_name) |>
    get_taxonomies()

  sf_imbcr |>
    left_join(sci_names, by = c("Species" = "common_name"))
}
