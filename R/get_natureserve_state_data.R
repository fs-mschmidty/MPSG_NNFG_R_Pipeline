get_natureserve_state_data <- function() {

  get_state_rank<-function(x, state_code) {
    regex <- paste0(state_code," \\(([^)]+)\\)")

    x |>
      str_split_1("\\\n") |> 
      str_subset("^United States")   |> 
      str_extract(regex) |>
      str_extract("\\(([^)]+)\\)") |>
      str_replace_all("\\(|\\)", "")
  }

  ne_export <- ns_export(location = list(nation = "US", subnation = "NE"), format = "xlsx")
  sd_export <- ns_export(location = list(nation = "US", subnation = "SD"), format = "xlsx")

  ne_res <- ns_export_status(ne_export)
  sd_res <- ns_export_status(sd_export)

  while(sd_res$state!="Finished" | ne_res$state!="Finished"){
    ne_res <- ns_export_status(ne_export)
    sd_res <- ns_export_status(sd_export)
  }

  request(ne_res$data$url) |>
    req_perform(ne_tmpf <- tempfile(fileext = ".xlsx"))

  request(sd_res$data$url) |>
    req_perform(sd_tmpf <- tempfile(fileext = ".xlsx"))


  sd_sss <- read_excel(sd_tmpf, skip = 1) |>
    janitor::clean_names() |>
    filter(!is.na(nature_serve_global_rank))

  ne_sss <- read_excel(ne_tmpf, skip = 1) |>
    janitor::clean_names() |>
    filter(!is.na(nature_serve_global_rank))

  combined<-sd_sss |>
    bind_rows(ne_sss) |>
    distinct(scientific_name, .keep_all = TRUE) |>
    rowwise() |> 
    mutate(
      NE_sRank = get_state_rank(distribution, state_code = "NE"),
      SD_sRank = get_state_rank(distribution, state_code = "SD")
    ) |>
    ungroup() |> 
    get_taxonomies()

  final_list <- list()

  final_list[["export_id_south_dakota"]] <- sd_export
  final_list[["export_id_nebrasaka"]] <- ne_export
  final_list[["response_south_dakota"]] <- sd_res
  final_list[["response_nebraska"]] <- ne_res
  final_list[["list_of_species_south_dakota"]] <- sd_sss
  final_list[["list_of_species_nebraska"]] <- ne_sss
  final_list[["unit_nature_serve_list"]] <- combined
  final_list
}


