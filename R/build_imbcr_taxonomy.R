#' This function was deemed to be unnecesarry and is therefore deprocated, tests were conducted to prove that common_names were sufficient to join data from bird dbs to eligible lists and overviews.
build_imbcr_taxonomy <- function(x) {
  common_names <- x |>
    rename(common_name = species) |>
    count(common_name) |>
    pull(common_name)

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

  x |>
    left_join(sci_names, by = c("species" = "common_name"))
}
