build_summary_sheet <- function(x) {
  read_excel(x, sheet = 1) |>
    select(scientific_name:IMBCR_recID) |>
    get_taxonomies()
}
