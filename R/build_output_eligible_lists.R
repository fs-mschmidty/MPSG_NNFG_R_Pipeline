build_output_eligible_lists <- function(x, output_path) {
  wb <- createWorkbook()

  output_name <- paste(str_replace_all(Sys.Date(), "-", ""), "NNFG_Eligible_Species_Lists.xlsx", sep = "_")

  addWorksheet(wb, "Species_Overviews_Eligible_List")
  writeDataTable(wb, "Species_Overviews_Eligible_List", x$current_eligible_list, tableStyle = "TableStyleLight1")

  eligible_taxon_problems <- x$eligible_taxon_problems |>
    mutate(
      final_scientific_name = NA,
      rationale_for_classification = NA,
      needs_overview = NA
    )

  addWorksheet(wb, "Eligible_Need_Taxon_Review")
  writeDataTable(wb, "Eligible_Need_Taxon_Review", eligible_taxon_problems, tableStyle = "TableStyleLight1")

  addWorksheet(wb, "Comp_NatServe_SD&NE")
  writeDataTable(wb, "Comp_NatServe_SD&NE", x$ns_state_eligible, tableStyle = "TableStyleLight1")

  species_to_add <- tibble(
    scientific_name = NA,
    common_name = NA,
    reason_for_addition = NA,
    source_for_native_and_known_to_occur = NA,
    taxon_id_from_comprehensiv_list = NA
  )
  addWorksheet(wb, "Species_to_Add")
  writeData(wb, "Species_to_Add", species_to_add)

  saveWorkbook(wb, file.path(output_path, output_name), overwrite = T)
  output_name
}
