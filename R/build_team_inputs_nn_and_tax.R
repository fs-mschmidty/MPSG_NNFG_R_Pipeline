build_team_inputs_nn_and_tax <- function(x) {
  taxon_review <- read_excel(x, sheet = "Eligible_Need_Taxon_Review")
  native_known_review <- read_excel(x, sheet = "Native_Known_Verify")
  transient_bird_review <- read_excel(x, sheet = "Transient_Bird_Analysis")

  lst(
    taxon_review,
    native_known_review,
    transient_bird_review
  )
}
