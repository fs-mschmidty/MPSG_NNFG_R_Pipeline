build_sd_state_list<-function(x){
  read_excel(x, skip=1) |>
    clean_names() |>
    filter(!is.na(scientific_name), is.na(federal_statusa)) |>
    select(scientific_name, common_name, state_statusb, sgcn_criterione) |>
    filter(sgcn_criterione %in% c("1")) |>
    mutate(
      status_r = case_when(
        state_statusb == "E" ~ "Endangered",
        TRUE ~ "Threatened"
      ),
      status_s = "South Dakota",
      status_c = "State List",
      status_a = paste(status_s, status_c, status_r, sep=" "),
      scientific_name = str_replace(scientific_name, "\\\r\\\n", " ")
    ) |>
    select(scientific_name, common_name, status_r:status_a)  |> 
    get_taxonomies()
}

# sd_state_list 
