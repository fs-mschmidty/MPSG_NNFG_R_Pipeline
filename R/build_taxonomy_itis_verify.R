build_taxonomy_itis_verify <- function(x) {
  sci_names <- x |>
    distinct(scientific_name) |>
    pull(scientific_name)

  get_itis_class <- function(y, el_list) {
    c <- classification(sci_id = y, db = "itis")

    t_id <- el_list |>
      filter(scientific_name == y) |>
      distinct(taxon_id, .keep_all = T) |>
      pull(taxon_id)

    if (length(c[[1]]) == 1) {
      tibble(
        taxon_id = t_id,
        scientific_name = y,
        tsn_id = NA,
        tsn_scientific_name = NA,
        rank = NA
      )
    } else {
      c[[1]] |>
        tail(1) |>
        rename(tsn_id = id, tsn_scientific_name = name) |>
        mutate(taxon_id = t_id, scientific_name = y)
    }
  }

  lapply(sci_names, get_itis_class, x) |>
    bind_rows() |>
    as_tibble()
}
# t_id <- tar_read(output_dne_eligible_lists) |>
#   filter(scientific_name == "Lithobates blairi") |>
#   distinct(taxon_id, .keep_all = T) |>
#   pull(taxon_id)
#
#
# t <- tar_read(output_dne_eligible_lists) |>
#   sample_n(1) |>
#   pull(fcientific_name)
#
# c <- classification(sci_id = "Lithobates blairi", db = "itis")
# !is.na(c[[1]])
# c[[1]] |>
#   tail(1) |>
#   rename(tsn_id = id, tsn_scientific_name = name)
#
# tsn_n <- get_tsn("Euphorbia dentata")
#
# tsn_n[[1]]
