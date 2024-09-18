build_eligible_synonyms <- function(x) {
  t_ids <- x |>
    distinct(taxon_id) |>
    pull(taxon_id)
  lapply(t_ids, function(x) rgbif::name_usage(key = x, data = "synonyms")$data) |>
    bind_rows() |>
    mutate(taxon_id = acceptedKey)
}
