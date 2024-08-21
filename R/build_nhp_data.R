build_nhp_data <- function(gdb, act_lyr, lyr_crs, unit) {
  st_read(gdb, act_lyr) |>
    st_transform(crs = lyr_crs) |>
    st_intersection(unit) |>
    st_make_valid()
}
