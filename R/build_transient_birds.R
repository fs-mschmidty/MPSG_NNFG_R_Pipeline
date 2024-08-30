build_transient_birds <- function(x, nnfg_aoa) {
  eligible_birds <- x$current_eligible_list |>
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

    if (!is_empty(v_ranges_overlap)) {
      breeding_status <- ("breeding" %in% v_ranges_overlap)
      wintering_status <- ("nonbreeding" %in% v_ranges_overlap)
      migration_status <- (TRUE %in% str_detect(v_ranges_overlap, "migration"))
      resident_status <- ("resident" %in% v_ranges_overlap)

      tibble(
        scientific_name = sci_name,
        breeding_on_unit = breeding_status,
        wintering_on_unit = wintering_status,
        migration_on_unit = migration_status,
        resident_on_unit = resident_status
      )
    } else {
      tibble(
        scientific_name = sci_name,
        breeding_on_unit = FALSE,
        wintering_on_unit = FALSE,
        migration_on_unit = FALSE,
        resident_on_unit = FALSE
      )
    }
  }

  transient_analysis <- lapply(eligible_birds_sci_names, get_transients, aoa) |>
    bind_rows()

  transient_analysis <- eligible_birds_w_dist |>
    left_join(transient_analysis, by = "scientific_name") |>
    bind_rows(eligible_birds_wo_dist) |>
    select(taxon_id:common_name, breeding_on_unit:resident_on_unit, breeding_quality, nonbreeding_quality, resident_quality)

  transient_analysis
}
