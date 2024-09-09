library(taxize)
library(tidyverse)
library(targets)
library(rgbif)
library(sf)

options("scipen"=100, "digits"=4)

el_list <- tar_read(eligible_lists)$current_eligible_list
t_ids<-el_list |>
  pull(taxon_id)

scientific_names <- el_list |>
  pull(scientific_name)

sci_name <- str_replace(scientific_names[230], "ssp.", "")

t_id <- el_list |>
  filter(scientific_name == sci_name) |>
  pull(taxon_id)

synonyms <- name_lookup(sci_name)$data

x <- name_backbone(name = sci_name)
syns <- name_usage(key = t_id, data = "synonyms")
names <- syns$data |>
  pull(canonicalName)

names <- synonyms |>
  select(canonicalName, rank) |>
  filter(taxonomicStatus == "SYNONYM") |>
  filter(rank %in% c("SUBSPEPCIES", "VARIETY", "SPECIES", "FORM")) |>
  count(canonicalName) |>
  pull(canonicalName)

tibble(synonyms = names) |>
  mutate(scientific_name = sci_name, taxon_id = t_id)
s2 <- synonyms(sci_name, db = "pow")

t_path <- file.path("T:/FS/NFS/PSO/MPSG/2024_NebraskaNFG/1_PreAssessment", "Projects/SpeciesList_NNFG")
gbif_rdat <- file.path(t_path, "reproduce", "gbif.RData")
attach(gbif_rdat)

sf_gbif_unit |>
  mutate(taxon_id = acceptedTaxonKey) |>
  filter(taxon_id %in% t_ids)  |> 
  mutate(gbif_id = as.numeric(gbifID)) |> 
  mutate(gbif_occ_url = paste("https://www.gbif.org/occurrence", gbifID, sep="/")) |>
  select(gbif_id)

eligible_occ_gbif |>
  head(40) |> 
  select(gbif_occ_url)  


el_minimal <- el_list |>
  select(taxon_id, scientific_name)

gbif_ids <- gbif_list |>
  as_tibble() |>
  select(scientific_name, GBIF_taxonID, taxon_id) |>
  separate_rows(GBIF_taxonID, sep = ", ")

eligible_GBIF <- el_minimal |>
  left_join(gbif_ids, by = "taxon_id") |>
  filter(!is.na(GBIF_taxonID))

all_gbif <- sf_gbif_unit |>
  st_drop_geometry() |>
  mutate(taxonKey = as.character(taxonKey))

gbif_occ_synonyms <- eligible_GBIF |>
  left_join(unit_eligible, by = c("GBIF_taxonID" = "taxonKey")) |>
  count(taxon_id, scientific_name.x, scientific_name.y) |>
  group_by(taxon_id) |>
  mutate(n = n()) |>
  filter(n > 1) |>
  ungroup() |>
  mutate(matches = ifelse(scientific_name.x == scientific_name.y, TRUE, FALSE)) |>
  filter(!matches) |>
  select(taxon_id, synonym = scientific_name.y) |>
  mutate(source = "GBIF Observations Data Pull")


detach()

idb_rdat <- file.path(t_path, "reproduce", "idigbio.RData")
attach(idb_rdat)

idb_occ_synonyms <- idb_list |>
  left_join(el_minimal, by = "taxon_id") |>
  filter(!is.na(scientific_name.y)) |>
  group_by(taxon_id) |>
  mutate(n = n()) |>
  ungroup() |>
  filter(n > 1) |>
  select(scientific_name.x, scientific_name.y, iDB_taxonID, taxon_id) |>
  mutate(matches = ifelse(scientific_name.x == scientific_name.y, TRUE, FALSE)) |>
  filter(!matches) |>
  select(taxon_id, synonym = scientific_name.y) |>
  mutate(source = "iDigBio Observations Data Pull")

detach()


eligible_species<-eligible_GBIF |>
  # left_join(unit_eligible, by=c("GBIF_taxonID"="taxonKey")) |>
  mutate(gbif_occ_url = paste("https://www.gbif.org/occurrence", gbif_ID, sep="/"))
#
# eligible_species |>
#   group_by(taxon_id) |>
#
