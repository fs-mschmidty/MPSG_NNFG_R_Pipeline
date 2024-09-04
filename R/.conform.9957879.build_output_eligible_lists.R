build_output_eligible_lists <- function(x, output_path, transient_birds) {
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


  addWorksheet(wb, "Comp_NatServe_SD&NE")
  writeDataTable(wb, "Comp_NatServe_SD&NE", x$ns_state_eligible, tableStyle = "TableStyleLight1")


  tb <- transient_birds |>
    distinct() |>
    rowwise() |>
    mutate(should_remain_eligible = if_any(.cols = c("breeding_on_unit", "wintering_on_unit", "resident_on_unit"), isTRUE)) |>
    ungroup()


  addWorksheet(wb, "Transient_Bird_Analysis")
  writeDataTable(wb, "Transient_Bird_Analysis", tb, tableStyle = "TableStyleLight1")

  saveWorkbook(wb, file.path(output_path, output_name), overwrite = T)
  saveWorkbook(wb, file.path("T:\\FS\\NFS\\PSO\\MPSG\\2024_NebraskaNFG\\1_PreAssessment\\Projects\\SpeciesList_NNFG", output_name), overwrite = T)

  wb_fixes <- creeateWorkbook()

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

  output_name
}
