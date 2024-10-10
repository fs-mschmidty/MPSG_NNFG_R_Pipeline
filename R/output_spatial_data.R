#' This function outputs spatial data to a shapefile.  It renames the taxon_id as mpsgID becuase stup ESRI trunkates taxon_id.
#' @param x the input spatial_data
#' @param fp the output foulder location sans name of shapefile
#' @param data_name the name of the dataset as it is output.
output_spatial_data <- function(x, fp, data_name) {
  shape <- x |>
    rename(mpsgID = taxon_id)

  st_write(shape, file.path(fp, paste0(data_name, ".shp")), append = FALSE)

  data_name
}
