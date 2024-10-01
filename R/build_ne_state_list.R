#' This cleans the state list provided by the State of Nebraska and outputs the data in a long format.
build_ne_state_list <- function(x) {
  read_excel(x, sheet = 1) |>
    clean_names() |>
    select(
      scientific_name = sname,
      common_name = s_primary_common_name,
      status_r = lgcy_stat
    ) |>
    mutate(
      status_s = "Nebraska",
      status_c = "State SWAP",
      status_a = paste(status_s, status_c, status_r, sep = " ")
    ) |>
    get_taxonomies()
}
