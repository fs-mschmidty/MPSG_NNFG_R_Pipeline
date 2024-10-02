#' This function cleans the regional fores sensitive species list and returns it in long format.
#' @param x file_path to an excel spreadsheet with the Region 2 Sensitive Species List.
build_r2_ss_list <- function(x) {
  read_excel(x) |>
    select(common_name, scientific_name) |>
    mutate(
      status_s = "US Forest Service",
      status_a = "USFS R2 Sensitive Species",
      status_c = "US Forest Service",
      status_r = "USFS Sensitive Species"
    ) |>
    get_taxonomies()
}
