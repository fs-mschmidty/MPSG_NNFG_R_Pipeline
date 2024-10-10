build_output_dne_eligible_lists <- function(x, output_path, t_drive_path, species_list_sp, inputs_round1) {
  wb <- createWorkbook()
  date_string <- str_replace_all(Sys.Date(), "-", "")
  output_eligible_list <- paste(date_string, "NNFG_Eligible_Species_Lists.xlsx", sep = "_")


  native_and_known_cl <- inputs_round1$native_known_review |>
    mutate(max_overall_year = ifelse(is.na(specialist_verified_max_year), max_overall_year, specialist_verified_max_year)) |>
    select(taxon_id, max_overall_year, `Is the Species Native and Known to Occur`, `What is the rationale and supporting BASI for recommending that an observation does not meet the requirements of native to, and known to occur in the plan area?`)


  taxon_review_cl <- inputs_round1$taxon_review |>
    filter(needs_overview) |>
    select(-final_scientific_name, -rationale_for_classification, -needs_overview)

  transient_bird_ids <- inputs_round1$transient_bird_review |>
    mutate(
      final_determination = ifelse(specialist_overide == "No Change", should_remain_eligible, specialist_overide),
      final_determination = as.logical(final_determination),
      taxon_id = as.character(taxon_id)
    ) |>
    filter(!final_determination) |>
    filter(!str_detect(scientific_name, "^Grus") | !str_detect(common_name, "^Piping")) |>
    pull(taxon_id)

  eligible_joined <- x$current_eligible_list |>
    left_join(native_and_known_cl, by = "taxon_id") |>
    mutate(
      `Is the Species Native and Known to Occur` = case_when(
        taxon_id %in% transient_bird_ids ~ "No",
        is.na(`Is the Species Native and Known to Occur`) ~ "Yes",
        TRUE ~ `Is the Species Native and Known to Occur`
      ),
      `What is the rationale and supporting BASI for recommending that an observation does not meet the requirements of native to, and known to occur in the plan area?` = case_when(
        taxon_id %in% transient_bird_ids ~ paste("Bird has been determined to be transient based on ebird range maps.", `What is the rationale and supporting BASI for recommending that an observation does not meet the requirements of native to, and known to occur in the plan area?`, sep = "; "),
        TRUE ~ `What is the rationale and supporting BASI for recommending that an observation does not meet the requirements of native to, and known to occur in the plan area?`
      )
    ) |>
    bind_rows(taxon_review_cl)


  addWorksheet(wb, "Species_Overviews_Eligible_List")
  writeDataTable(wb, "Species_Overviews_Eligible_List", eligible_joined, tableStyle = "TableStyleLight1")


  addWorksheet(wb, "Comp_NatServe_SD&NE")
  writeDataTable(wb, "Comp_NatServe_SD&NE", x$ns_state_eligible, tableStyle = "TableStyleLight1")

  saveWorkbook(wb, file.path(output_path, paste("DO_NOT_EDIT", output_eligible_list, sep = "_")), overwrite = T)
  saveWorkbook(wb, file.path(t_drive_path, paste("DO_NOT_EDIT", output_eligible_list, sep = "_")), overwrite = T)
  saveWorkbook(wb, file.path(species_list_sp, paste("DO_NOT_EDIT", output_eligible_list, sep = "_")), overwrite = T)

  eligible_joined
}

# team_inputs_round1$transient_bird_review |>
#     mutate(
#       final_determination = ifelse(specialist_overide == "No Change", should_remain_eligible, specialist_overide),
#       final_determination = as.logical(final_determination),
#       taxon_id = as.character(taxon_id)
#     ) |>
#     filter(!final_determination) |>
#     filter(!str_detect(scientific_name, "^Grus") | !str_detect(common_name, "^Piping")) |>
#     pull(taxon_id)
#
