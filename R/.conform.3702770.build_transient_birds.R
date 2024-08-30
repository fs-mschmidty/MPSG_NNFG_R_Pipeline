build_transient_birds <- function(x) {
  eligible_birds <- x |>
    filter(class == "Aves") |>
    select(taxon_id, scientific_name) |>
    left_join(ebirdst_runs, by = "scientific_name")

  eligible_birds_w_dist <- eligible_birds |>
    filter(!is.na(species_code))

  eligible_birds_wo_dist <- eligible_birds |>
    filter(is.na(species_code))

  eligible_birds_sci_names <- eligible_birds_w_dist |>
    pull(scientific_name)

  ## this downloads all of the bird distribution models from cornel. These were performed and coppied to the T:Drive.
  # lapply(eligible_birds_sci_names, ebirdst_download_status, download_ranges = T, pattern = "range_smooth_27km|range_smooth_9km")
}
