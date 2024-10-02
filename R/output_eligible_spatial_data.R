#' This function outputs spatial data to a shapefile.  It renames the taxon_id as mpsgID becuase stup ESRI trunkates taxon_id.
output_eligible_spatial_data <- function(x, fp, data_name) {
  eligible <- x$eligible |>
    rename(mpsgID = taxon_id)

  eligible_unit <- x$eligible_unit |>
    rename(mpsgID = taxon_id)

  st_write(eligible, file.path(fp, paste(data_name, "eligible.shp", sep = "_")), append = FALSE)
  st_write(eligible_unit, file.path(fp, paste(data_name, "eligible_unit.shp", sep = "_")), append = FALSE)

  data_name
}
