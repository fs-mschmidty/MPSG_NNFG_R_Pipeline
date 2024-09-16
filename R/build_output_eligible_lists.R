build_output_eligible_lists <- function(x, output_path, transient_birds, n_n_check) {
  file_path_last_editable <- list.files(species_list_sp, pattern = "OPEN_TO_EDITING", full.names = TRUE)
  if (length(file_path_last_editable) > 1) {
    file_path_last_editable <- file_path_last_editable[grepl(date_string, file_path_last_editable)]
  }
  dropdowns <- read_excel(file_path_last_editable, sheet = "Drop down categories")


  wb_fixes <- createWorkbook()

eligible_taxon_problems <- x$eligible_taxon_problems |>
      mutate(
        final_scientific_name = NA,
        rationale_for_classification = NA,
        needs_overview = NA
      )



  addWorksheet(wb_fixes, "Eligible_Need_Taxon_Review")
  writeDataTable(wb_fixes, "Eligible_Need_Taxon_Review", eligible_taxon_problems, tableStyle = "TableStyleLight1")

  species_to_add <- tibble(
    scientific_name = NA,
    common_name = NA,
    reason_for_addition = NA,
    source_for_native_and_known_to_occur = NA,
    taxon_id_from_comprehensiv_list = NA
  )

  addWorksheet(wb_fixes, "Species_to_Add")
  writeData(wb_fixes, "Species_to_Add", species_to_add)

  tb <- transient_birds |>
    distinct() |>
    rowwise() |>
    mutate(should_remain_eligible = if_any(.cols = c("breeding_on_unit", "wintering_on_unit", "resident_on_unit"), isTRUE)) |>
    ungroup() |>
    mutate(
      should_remain_eligible = ifelse(is.na(species_code), TRUE, should_remain_eligible),
      specialist_overide = NA,
      specialist_justification_for_overide = NA
    )


  addWorksheet(wb_fixes, "Transient_Bird_Analysis")
  writeDataTable(wb_fixes, "Transient_Bird_Analysis", tb, tableStyle = "TableStyleLight1")

  addWorksheet(wb_fixes, "Drop down categories")
  writeData(wb_fixes, "Drop down categories", dropdowns)

  addWorksheet(wb_fixes, "Native_Known_Verify")
  writeDataTable(wb_fixes, "Native_Known_Verify", n_n_check, tableStyle = "TableStyleLight1")

  saveWorkbook(wb_fixes, file.path(output_path, paste("OPEN_TO_EDITING", output_need_edits, sep = "_")), overwrite = T)
  saveWorkbook(wb_fixes, file.path(t_drive_path, paste("OPEN_TO_EDITING", output_need_edits, sep = "_")), overwrite = T)
  saveWorkbook(wb_fixes, file.path(species_list_sp, paste("OPEN_TO_EDITING", output_need_edits, sep = "_")), overwrite = T)

  output_eligible_list
}
