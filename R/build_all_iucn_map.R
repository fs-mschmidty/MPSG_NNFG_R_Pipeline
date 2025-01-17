#' This function takes in all of the iucn maps lists that include all of the species from the eligible list that occur in individual dataset. It then takes all of the lists, combines them and then makes an SQL query to pull all of the layers from each respective shapefile.  How this works probably needs to be rethought. For example we could input a list of objects instead of all of them individually....

build_all_iucn_map <- function(
    mammals,
    amphibians2,
    reptiles1,
    reptiles2,
    fwfish1,
    fwfish2) {
  all_maps <- bind_rows(
    mammals,
    amphibians2,
    reptiles1,
    reptiles2,
    fwfish1,
    fwfish2
  )

  t_ids <- all_maps |>
    select(taxon_id, query_name)

  grouped_data <- all_maps |>
    group_by(file_path) |>
    summarize(where_in = paste(sprintf("'%s'", query_name), collapse = ", ")) |>
    ungroup() |>
    mutate(layer_n = case_when(
      str_detect(file_path, "AMPHIBIANS") ~ "AMPHIBIANS_PART2",
      str_detect(file_path, "MAMMALS") ~ "MAMMALS",
      str_detect(file_path, "REPTILES_PART1") ~ "REPTILES_PART1",
      str_detect(file_path, "REPTILES_PART2") ~ "REPTILES_PART2",
      str_detect(file_path, "FW_FISH_PART1") ~ "FW_FISH_PART1",
      str_detect(file_path, "FW_FISH_PART2") ~ "FW_FISH_PART2",
    ))

  test_f <- function(file_path, where_in, layer_n) {
    query_string <- sprintf("SELECT * FROM %s WHERE sci_name IN (%s)", layer_n, where_in)
    st_read(file_path, query = query_string)
  }

  pmap(grouped_data, test_f) |>
    bind_rows() |>
    left_join(t_ids, by = c("sci_name" = "query_name"))
}
