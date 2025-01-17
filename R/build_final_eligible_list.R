build_final_eligible_list <- function(x, local_concern, local_concern_file, local_concern_sheet) {
  local_concern_raw <- read_excel(local_concern_file, skip = 1, sheet = local_concern_sheet) |>
    clean_names() |>
    filter(add_to_list_for_a_species_evaluation == "Yes") |>
    select(scientific_name, add_to_list_for_a_species_evaluation)

  l_t_ids <- local_concern |>
    left_join(local_concern_raw, by = "scientific_name") |>
    filter(add_to_list_for_a_species_evaluation == "Yes") |>
    pull(taxon_id)


  x |>
    mutate(
      local_concern = case_when(
        taxon_id %in% l_t_ids ~ "Yes",
        Local_Concern == "Yes" ~ "Yes, but does not warrent evaluation.",
        TRUE ~ NA
      ),
      `Is the Species Native and Known to Occur` = case_when(
        local_concern == "Yes" ~ "Yes",
        local_concern == "Yes, but does not warrent evaluation." ~ "No",
        TRUE ~ `Is the Species Native and Known to Occur`
      )
    ) |>
    select(-Local_Concern)
}
