load_bird_maps <- function(x) {
  bird_names <- x |>
    filter(class == "Aves", scientific_name != "Grus americana") |>
    pull(taxon_id)

  get_bird_map <- function(y) {
    bird_data <- x |>
      filter(taxon_id == y)

    sci_name <- bird_data |>
      pull(scientific_name)

    load_ranges(sci_name, resolution = "27k") |>
      mutate(
        season = case_when(
          season == "breeding" ~ "Breeding",
          season == "nonbreeding" ~ "Nonbreeding",
          TRUE ~ "Migration"
        ),
        order = case_when(
          season == "Breeding" ~ 1,
          season == "Nonbreeding" ~ 2,
          TRUE ~ 3
        ),
        scientific_name = sci_name,
        taxon_id = y
      ) |>
      arrange(desc(order))
  }

  lapply(bird_names, get_bird_map) |>
    bind_rows()
}
