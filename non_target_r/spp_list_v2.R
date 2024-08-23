library(mpsgSO)
library(tidyverse)
library(targets)
library(lubridate)
library(taxize)
library(sf)

# state_data <- tar_read(naturserve_state_data)$unit_nature_serve_list

state_data <- read_csv("T:\\FS\\NFS\\PSO\\MPSG\\Data\\ExternalData\\NatureServe\\NNFG_natureserve_state_data.csv")


ns_state_eligible<-state_data |>
  rename(rounded_gRank = nature_serve_rounded_global_rank) |>
  filter(
    str_detect(rounded_gRank, "[GT][123]") |
    str_detect(NE_sRank, "[ST][12]")
  ) |>
  distinct(scientific_name, taxon_id, .keep_all=T)

View(ns_state_eligible)

ns_state_eligible_cl<-ns_state_eligible |>
  select(taxon_id, scientific_name, common_name, rounded_gRank, NE_sRank, SD_sRank, usfws_status = u_s_endangered_species_act_status, kingdom:form) |>
  mutate(taxon_id = as.character(taxon_id)) |>
  distinct(taxon_id, scientific_name, rounded_gRank, NE_sRank, SD_sRank)

## These are the species that are problematic from the state NatureServe Lists.
problems<-ns_state_eligible |>
  group_by(taxon_id) |>
  mutate(n=n()) |>
  ungroup() |> 
  filter(n>1)  |>
  arrange(scientific_name)


# problems |>
#   pull(scientific_name) |>
#   classification(db = "gbif")
#
## File Paths
t0 <- lubridate::now()

#-- Project variables
# Forest names
unit_code <- "NNFG"
unit_full <- "Nebraska National Forests and Grasslands"
states <- c("NE", "SD")
# T-drive folder
t_path <- file.path("T:/FS/NFS/PSO/MPSG/2024_NebraskaNFG/1_PreAssessment", 
                    "Projects/SpeciesList_NNFG")

## NHP Data

nhp_rdat <- file.path(t_path, 'reproduce', "state_nhp.RData")
attach(nhp_rdat)

test_list<-sf_nenhp_unit |>
  as_tibble() |>
  mutate(
      f_year = year(first_date),
      l_year = year(last_date)
    ) |> 
  group_by(SNAME) |>
  summarize(
    SDNHP_nObs = n(),
    f_year = min(f_year),
    l_year = max(f_year)
  ) |>
  ungroup() |>
  rename(scientific_name = SNAME) |>
  get_taxonomies()



test_list |>
  ## This filters out all ecosystems unser scientific_name may want to move this up stream. 
  filter(!is.na(taxon_id)) |> 
  group_by(taxon_id) |>
  mutate(n=n()) |>
  filter(n>1) |>
  arrange(taxon_id) |>
  select(scientific_name, taxon_id) |>
  View()


test_list  |>
  head(10) |> 
  pull(SNAME) |>
  classification(sci_id, db ="gbif")


nenhp_list_cl<-nenhp_list |>
  select(taxon_id, scientific_name, NENHP_nObs:NENHP_lastYear) |>
  rename(NENHP_maxYear = NENHP_lastYear) 
  # filter(taxon_id == "6438733")
  # count(taxon_id, sort=T)

sdnhp_list_cl<-sdnhp_list |>
  select(taxon_id, scientific_name, SDNHP_nObs:SDNHP_lastYear) |> 
  rename(SDNHP_maxYear = SDNHP_lastYear)
detach()

## GBIF
gbif_rdat <- file.path(t_path, 'reproduce', "gbif.RData")
attach(gbif_rdat)

gbif_list_cl<-gbif_list |>
  select(taxon_id, scientific_name, GBIF_nObs:GBIF_maxYear)

detach()

## iDigBio
idb_rdat <- file.path(t_path, 'reproduce', "idigbio.RData")
attach(idb_rdat)

idb_list_cl<-idb_list |> 
  select(taxon_id, scientific_name, iDB_nObs:iDB_maxYear)

detach()

## Seinet

seinet_rdat <- file.path(t_path, 'reproduce', "seinet.RData")
attach(seinet_rdat)

seinet_list_cl<-seinet_list  |> 
  select(taxon_id, scientific_name, SEI_nObs:SEI_maxYear)

detach()

## IMBCR 
imbcr_rdat <- file.path(t_path, 'reproduce', "imbcr.RData")
attach(imbcr_rdat)

imbcr_list_cl<-imbcr_list |>
  select(taxon_id, scientific_name, IMBCR_nObs:IMBCR_maxYear)
detach()

##  Combine All Layers
### - 6 species that have NAs for taxon_id in the species list. 

ns_state_eligible_cl |>
  filter(!is.na(taxon_id)) |> 
  left_join(select(nenhp_list_cl, -scientific_name), by="taxon_id")  |>
  filter(taxon_id=="1905301")
  count(taxon_id, sort=T) |>
  count(n)


state_data |>
  select(taxon_id)

