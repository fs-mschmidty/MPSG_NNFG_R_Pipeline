# Setup ----
#-- Global settings
t0 <- lubridate::now()

#-- Project variables
# Forest names
unit_code <- "NNFG"
unit_full <- "Nebraska National Grasslands and Forests"
t_drive <- TRUE # Are data going to be saved on the T-drive?
t_path <- file.path(
  "T:/FS/NFS/PSO/MPSG/2024_NebraskaNFG",
  "1_PreAssessment/Projects/SpeciesList_NNFG"
)
# Geodatabase
pre_gdb <- file.path(
  "T:/FS/NFS/PSO/MPSG/2024_NebraskaNFG",
  "1_PreAssessment/Data/NNFG_PreAssessmentData.gdb"
)


#-- Packages
# R packages used in this script
pkgs <- c(
  "arcgisbinding", # Interface with ArcGIS
  "dplyr", # data management
  "sf", # spatial functions
  "tibble", # data structures
  "tidyr"
) # data management

# Install packages if they aren't in your library
inst_pkgs <- pkgs %in% rownames(installed.packages())
if (any(inst_pkgs == FALSE)) {
  install.packages(pkgs[!inst_pkgs],
    lib = .libPaths()[1],
    repos = "https://cloud.r-project.org",
    type = "source",
    dependencies = TRUE,
    quiet = TRUE
  )
}

#-- Functions
# The functions.R script holds functions for reading and clipping feature
#    classes from geodatabases and pulling G-ranks from NatureServe.
source("functions.R")

#-- Activate ArcGIS License
arcgisbinding::arc.check_product()

#-- Spatial Data
gdb_path <- file.path(
  "T:/FS/NFS/PSO/MPSG/2024_CimarronComancheNG",
  "1_PreAssessment/Data/CCNG_BaseData.gdb"
)
lyr_fsland <- "CCNG_ProcBdy"
lyr_planarea <- "CCNG_AdminBdy"
lyr_buffer <- "CCNG_ProcBdy_1kmBorder"

sf_fsland <- sf::read_sf(layer = lyr_fsland, dsn = gdb_path)
if (!all(sf::st_is_valid(sf_fsland))) sf_fsland <- sf::st_make_valid(sf_fsland)

crs <- sf::st_crs(sf_fsland)

sf_buffer <- read_lyr(lyr = lyr_buffer)
if (!sf::st_crs(sf_buffer) == crs) {
  sf_buffer <- sf::st_transform(sf_buffer, crs = crs)
}

# Load Species List Data
load(file.path(t_path, "reproduce", "spp_list.RData"))



# State Heritage Program ----
load(file.path(t_path, "reproduce", "state_nhp.RData"))

sf_nenhp_unit

arcgisbinding::arc.write(
  path = file.path(pre_gdb, "species", "SDNHP_all"),
  data = sf_cnhp,
  overwrite = TRUE
)
arcgisbinding::arc.write(
  path = file.path(pre_gdb, "species", "CONHP_FS"),
  data = sf_cnhp_unit,
  overwrite = TRUE
)
arcgisbinding::arc.write(
  path = file.path(pre_gdb, "species", "KSNHI_all"),
  data = sf_ksnhp,
  overwrite = TRUE
)
arcgisbinding::arc.write(
  path = file.path(pre_gdb, "species", "KSNHI_FS"),
  data = sf_ksnhp_unit,
  overwrite = TRUE
)


# GBIF ----
load(file.path(t_path, "reproduce", "gbif.RData"))

sf_gbif_unit |>
  as_tibble() |>
  head(100) |>
  View()

#-- Prep data
ovrvw_gbif_ids <- id_vec(spp_ovrvws$GBIF_taxonID)
buff_gbif_ids <- id_vec(buff_list$GBIF_taxonID)
gbif_short <- c(
  "occurrenceID", "taxonID", "scientificName",
  "acceptedScientificName", "verbatimScientificName",
  "vernacularName", "kingdom", "phylum", "class", "order",
  "family", "genus", "specificEpithet", "infraspecificEpithet",
  "taxonRank", "basisOfRecord", "eventDate", "countryCode",
  "stateProvince", "county", "locality", "verticalDatum",
  "coordinateUncertaintyInMeters", "coordinatePrecision",
  "georeferencedBy", "georeferencedDate", "georeferenceProtocol",
  "georeferenceSources", "georeferenceRemarks", "publisher",
  "institutionCode", "collectionCode", "datasetName"
)

#-- Write Data
arcgisbinding::arc.write(
  path = file.path(
    pre_gdb, "species",
    "OverviewSpp_GBIF_all"
  ),
  data = dplyr::filter(
    sf_gbif,
    taxonKey %in% ovrvw_gbif_ids
  ) |>
    dplyr::select(dplyr::all_of(gbif_short)),
  overwrite = TRUE
)

arcgisbinding::arc.write(
  path = file.path(
    pre_gdb, "species",
    "OverviewSpp_GBIF_FS"
  ),
  data = dplyr::filter(
    sf_gbif_unit,
    taxonKey %in% ovrvw_gbif_ids
  ) |>
    dplyr::select(dplyr::all_of(gbif_short)),
  overwrite = TRUE
)

arcgisbinding::arc.write(
  path = file.path(
    pre_gdb, "species",
    "BufferSpecies_GBIF_all"
  ),
  data = dplyr::filter(
    sf_gbif,
    taxonKey %in% buff_gbif_ids
  ) |>
    dplyr::select(dplyr::all_of(gbif_short)),
  overwrite = TRUE
)

# iDigBio ----
load(file.path(t_path, "reproduce", "idigbio.RData"))

sf_idb |>
  head(40) |>
  select(uuid)
View()
as_tibble() |>
  count(canonicalname)

#-- Prep data
ovrvw_idb_ids <- id_vec(spp_ovrvws$iDB_taxonID)
buff_idb_ids <- id_vec(buff_list$iDB_taxonID)
idb_short <- c(
  "uuid", "taxonid", "canonicalname", "commonname",
  "taxonrank", "kingdom", "phylum", "class", "order", "family",
  "genus", "specificepithet", "infraspecificepithet", "eventdate",
  "coordinateuncertainty", "country", "stateprovince", "county",
  "locality", "verbatimlocality", "basisofrecord",
  "institutioncode", "institutionid", "institutionname",
  "collectioncode", "collectionid", "collectionname", "datasetid"
)

sf_idb |>
  select(all_of(idb_short))

#-- Write Data
arcgisbinding::arc.write(
  path = file.path(
    pre_gdb, "species",
    "OverviewSpp_iDigBio_all"
  ),
  data = dplyr::filter(
    sf_idb,
    taxonid %in% ovrvw_idb_ids
  ) |>
    dplyr::select(dplyr::all_of(idb_short)),
  overwrite = TRUE
)

arcgisbinding::arc.write(
  path = file.path(
    pre_gdb, "species",
    "OverviewSpp_iDigBio_FS"
  ),
  data = dplyr::filter(
    sf_idb_unit,
    taxonid %in% ovrvw_idb_ids
  ) |>
    dplyr::select(dplyr::all_of(idb_short)),
  overwrite = TRUE
)

arcgisbinding::arc.write(
  path = file.path(
    pre_gdb, "species",
    "BufferSpecies_iDigBio_all"
  ),
  data = dplyr::filter(
    sf_idb,
    taxonid %in% buff_idb_ids
  ) |>
    dplyr::select(dplyr::all_of(idb_short)),
  overwrite = TRUE
)


# SEINet ----
attach(file.path(t_path, "reproduce", "seinet.RData"))

sf_seinet |>
  as_tibble() |>
  count(scientificName)
head(100) |>
  View()

#-- Prep data
ovrvw_sei_ids <- id_vec(spp_ovrvws$SEI_taxonID)
buff_sei_ids <- id_vec(buff_list$SEI_taxonID)
sei_short <- c(
  "occurrenceID", "taxonID", "scientificName",
  "scientificNameAuthorship", "taxonRank", "kingdom", "phylum",
  "class", "order", "family", "genus", "specificEpithet",
  "infraspecificEpithet", "eventDate",
  "coordinateUncertaintyInMeters", "country", "stateProvince",
  "county", "locality", "basisOfRecord", "institutionCode",
  "collectionCode", "collectionID", "catalogNumber",
  "otherCatalogNumbers"
)

#-- Write Data
arcgisbinding::arc.write(
  path = file.path(
    pre_gdb, "species",
    "OverviewSpp_SEINet_all"
  ),
  data = dplyr::filter(
    sf_seinet,
    taxonID %in% ovrvw_sei_ids
  ) |>
    dplyr::select(dplyr::all_of(sei_short)),
  overwrite = TRUE
)

arcgisbinding::arc.write(
  path = file.path(
    pre_gdb, "species",
    "OverviewSpp_SEINet_FS"
  ),
  data = dplyr::filter(
    sf_seinet_unit,
    taxonID %in% ovrvw_sei_ids
  ) |>
    dplyr::select(dplyr::all_of(sei_short)),
  overwrite = TRUE
)

arcgisbinding::arc.write(
  path = file.path(
    pre_gdb, "species",
    "BufferSpecies_SEINet_all"
  ),
  data = dplyr::filter(
    sf_seinet,
    taxonID %in% buff_sei_ids
  ) |>
    dplyr::select(dplyr::all_of(sei_short)),
  overwrite = TRUE
)


# IMBCR ----
load(file.path(t_path, "reproduce", "imbcr.RData"))

arcgisbinding::arc.write(
  path = file.path(pre_gdb, "species", "IMBCR_all"),
  data = sf_imbcr,
  overwrite = TRUE
)

arcgisbinding::arc.write(
  path = file.path(pre_gdb, "species", "IMBCR_FS"),
  data = sf_imbcr_unit,
  overwrite = TRUE
)

# CPW Bats ----
load(file.path(t_path, "reproduce", "cpw_bats.RData"))

arcgisbinding::arc.write(
  path = file.path(pre_gdb, "species", "CPW_bats"),
  data = sf_cpwbats,
  overwrite = TRUE
)
