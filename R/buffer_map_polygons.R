#' this is a helper function to buffer polygons to a size that is visible on a small map in the species evaluations.
#' @param x polygon simple feature
#' @param min_size minimum area in units that match the projection of x.

buffer_small_polygons <- function(x, min_size = 5000) {
  x_area <- x %>%
    mutate(area = as.numeric(st_area(.)))

  r <- sqrt(min_size / pi)

  x_buffered <- x_area |>
    dplyr::filter(area < min_size) |>
    sf::st_centroid() |>
    sf::st_buffer(r)

  x_area |>
    dplyr::filter(area >= min_size) |>
    dplyr::bind_rows(x_buffered)
}
