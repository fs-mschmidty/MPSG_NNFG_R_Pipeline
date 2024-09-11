build_nhp_spatial_data <- function(fp, x) {
  attach(file.path(fp, x))

  ne_sname <- sf_nenhp |>
    as_tibble() |>
    count(SNAME) |>
    select(-n) |>
    filter(SNAME != "", !is.na(SNAME)) |>
    get_taxonomies(query_field = "SNAME")

  nenhp <- sf_nenhp |>
    left_join(ne_sname, by = "SNAME")

  sd_sname <- sf_sdnhp |>
    as_tibble() |>
    count(SNAME) |>
    select(-n) |>
    filter(SNAME != "", SNAME != " ", !is.na(SNAME)) |>
    get_taxonomies(query_field = "SNAME")

  sdnhp <- sf_sdnhp |>
    left_join(sd_sname, by = "SNAME")

  detach()

  lst(nenhp, sdnhp)
}
