build_sp_unit_concern <- function(file_path, sheet) {
  read_excel(file_path, sheet = sheet, skip = 1) |>
    clean_names() |>
    select(
      scientific_name,
      common_name,
      rounded_gRank = nature_serve_global_rank,
      NE_sRank = ne_state_rank,
      SD_sRank = sd_state_rank
    ) |>
    mutate(
      Local_Concern = "Yes"
    ) |>
    get_taxonomies()
}
