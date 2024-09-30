#' This function joins the crosswalk input that connects the ecology groups ecological groups to natureserve habitat bins.
#' @param sp_and_hab the habitats from Naturserve joined to taxon_id from the get_ns_habitat step.
#' @param crosswalk_fp is a filepath to a manual crosswalk completed by the species group.  The crosswalk was generated in a non_target.
build_species_habitats <- function(sp_and_habs, crosswalk_fp) {
  bins <- readxl::read_excel(crosswalk_fp, sheet = 1) |>
    filter(mpsg_habitat_bin != "NA")

  sp_and_habs |>
    left_join(bins, by = c("hab_cat", "ns_hab")) |>
    select(hab_cat, ns_hab, taxon_id, mpsg_habitat_bin)
}
