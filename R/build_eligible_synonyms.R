#' This function takes in a dataframe of species with assigned taxon_ids and outputs a list of potential synonyms from the GBIF Backbone taxonomy.  If more than one species has a taxon_id assigned to it it will only returns synonyms for one species.

build_eligible_synonyms <- function(x) {
  t_ids <- x |>
    distinct(taxon_id) |>
    pull(taxon_id)
  lapply(t_ids, function(x) rgbif::name_usage(key = x, data = "synonyms")$data) |>
    bind_rows() |>
    mutate(taxon_id = acceptedKey)
}
