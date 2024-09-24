get_evaluation_base_map_data <- function(nnfg_aoa) {
  north_america_c <- ne_countries(scale = "medium", continent = "North America", returnclass = "sf") |>
    select(name) |>
    filter(name != "United States of America")
  north_america_s <- ne_states(country = c("United States of America", "Canada", "Mexico"), returnclass = "sf") |>
    filter(name != "Hawaii") |>
    select(name = name_en)

  north_america <- bind_rows(
    north_america_c,
    north_america_s
  ) |>
    st_transform(crs = 5070)

  l_48 <- ne_states(country = c("United States of America")) |>
    st_as_sf() |>
    filter(name != "Hawaii", name != "Alaska") |>
    st_transform(crs = 5070)

  americas <- ne_countries(scale = "medium", continent = c("North America", "South America"), returnclass = "sf") |>
    filter(name != "Hawaii") |>
    st_transform(crs = 5070)

  nnfg_a <- nnfg_aoa |>
    st_buffer(100000) |>
    st_bbox()


  sd <- getbb("South Dakota")
  ne <- getbb("Nebraska")
  wy <- getbb("Wyoming")

  osm_query_sd <- opq(sd) |>
    add_osm_feature("highway", value = c("motorway", "trunk", "primary")) |>
    osmdata_sf()

  osm_query_ne <- opq(ne) |>
    add_osm_feature("highway", value = c("motorway", "trunk", "primary")) |>
    osmdata_sf()

  osm_query_wy <- opq(wy) |>
    add_osm_feature("highway", value = c("motorway", "trunk", "primary")) |>
    osmdata_sf()

  nnfg_roads <- osm_query_ne$osm_lines |>
    bind_rows(osm_query_sd$osm_lines) |>
    bind_rows(osm_query_wy$osm_lines) |>
    st_transform(st_crs(nnfg_a)) |>
    st_crop(nnfg_a)

  nnfg_dist_open <- arc_open("https://apps.fs.usda.gov/arcx/rest/services/EDW/EDW_RangerDistricts_03/MapServer/1")

  nnfg_dist <- arc_select(nnfg_dist_open, where = "REGION = '02' AND FORESTNUMBER = '07'", fields = c("OBJECTID", "DISTRICTNAME")) |>
    st_transform(st_crs(nnfg_a))

  lst(
    north_america,
    l_48,
    americas,
    nnfg_roads,
    nnfg_dist
  )
}
