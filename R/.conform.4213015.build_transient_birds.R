build_transient_birds <- function(x, nnfg_aoa) {
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

  aoa <- nnfg_aoa |>
    st_transform(4326)

  get_transients <- function(sci_name, unit_aoa) {
    bird <- load_ranges(sci_name, resolution = "27k")

    v_ranges_overlap <- bird |>
      st_intersection(unit_aoa) |>
      count(season) |>
      pull(season)

    if (nrow(v_ranges_overlap > 0)) {
      breeding_status <- ("breeding" %in% v_ranges_overlap)
      wintering_status <- ("nonbreeding" %in% v_ranges_overlap)

      tibble(
        scientific_name = sci_name,
        breeding_on_unit = breeding_status,
        wintering_on_unit = wintering_status
      )
    }
  }
}
