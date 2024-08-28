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
