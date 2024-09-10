library(sf)
library(tidyverse)
library(targets)

t_path_sp_list <- file.path("T:/FS/NFS/PSO/MPSG/2024_NebraskaNFG", "1_PreAssessment/Projects/SpeciesList_NNFG")
t_path_sp_list_rp <- file.path(t_path_sp_list, "reproduce")


attach(file.path(t_path_sp_list_rp, "gbif.RData"))

eligible_list <- tar_read(eligible_lists)$current_eligible_list

t_ids <- eligible_list |>
  pull(taxon_id)

eligible_gbif <- sf_gbif |>
  mutate(taxon_id = acceptedTaxonKey) |>
  filter(taxon_id %in% t_ids) |>
  mutate(gbif_id = as.character(gbifID / 1)) |>
  mutate(gbif_occ_url = paste("https://www.gbif.org/occurrence", gbif_id, sep = "/"))

gbif_short <- c(
  "occurrenceID", "scientificName",
  "acceptedScientificName", "verbatimScientificName",
  "vernacularName", "kingdom", "phylum", "class", "order",
  "family", "genus", "specificEpithet", "infraspecificEpithet",
  "taxonRank", "basisOfRecord", "eventDate", "countryCode",
  "stateProvince", "county", "locality", "verticalDatum",
  "coordinateUncertaintyInMeters", "coordinatePrecision",
  "georeferencedBy", "georeferencedDate", "georeferenceProtocol",
  "georeferenceSources", "georeferenceRemarks", "publisher",
  "institutionCode", "collectionCode", "datasetName", "gbif_occ_url"
)

gbif_cl_all <- eligible_gbif |>
  select(all_of(gbif_short))
