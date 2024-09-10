build_idb_spatial_data <- function(fp, x) {
  attach(file.path(fp, x))

  idb_short <- c(
    "uuid", "canonicalname", "commonname",
    "taxonrank", "kingdom", "phylum", "class", "order", "family",
    "genus", "specificepithet", "infraspecificepithet", "eventdate",
    "coordinateuncertainty", "country", "stateprovince", "county",
    "locality", "verbatimlocality", "basisofrecord",
    "institutioncode", "institutionid", "institutionname",
    "collectioncode", "collectionid", "collectionname", "datasetid"
  )

  sf_idb_cl <- sf_idb |>
    select(all_of(idb_short)) |>
    filter(canonicalname != "", !is.na(canonicalname))

  df_names <- sf_idb_cl |>
    st_drop_geometry() |>
    count(canonicalname) |>
    filter(canonicalname != "", !is.na(canonicalname))

  taxonomies <- df_names |>
    get_taxonomies(query_field = "canonicalname")

  sf_idb_cl |>
    left_join(taxonomies, by = "canonicalname") |>
    mutate(idb_occ_url = glue("https://www.idigbio.org/portal/records/{uuid}"))
}
