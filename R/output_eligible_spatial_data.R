output_eligible_spatial_data <- function(x, fp, data_name) {
  st_write(x$eligible, file.path(fp, paste(data_name, "eligible.shp", sep = "_")), append = FALSE)
  st_write(x$eligible_unit, file.path(fp, paste(data_name, "eligible_unit.shp", sep = "_")), append = FALSE)

  data_name
}
