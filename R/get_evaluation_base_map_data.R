get_evaluation_base_map_data <- function() {
  north_america_c <- ne_countries(scale = "medium", continent = "North America", returnclass = "sf") |>
    select(name) |>
    filter(name!="United States of America")
  north_america_s<-ne_states(country=c("United States of America", "Canada", "Mexico"), returnclass="sf") |>
    filter(name!="Hawaii") |> 
    select(name=name_en)

  north_america <-bind_rows(
    north_america_c,
    north_america_s
  ) |>
    st_transform(crs=5070)

  l_48 <- ne_states(country = c("United States of America")) |>
    st_as_sf() |>
    filter(name != "Hawaii", name != "Alaska") |>
    st_transform(crs = 5070)

  americas <- ne_countries(scale = "medium", continent = c("North America", "South America"), returnclass = "sf") |>
    filter(name != "Hawaii") |>
    st_transform(crs = 5070)

  lst(
    north_america,
    l_48,
    americas
  )
}
