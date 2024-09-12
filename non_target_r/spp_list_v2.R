library(mpsgSO)
library(readxl)
library(tidyverse)
library(targets)
library(lubridate)
library(taxize)
library(sf)

# state_data <- tar_read(naturserve_state_data)$unit_nature_serve_list

state_data <- read_csv("T:\\FS\\NFS\\PSO\\MPSG\\Data\\ExternalData\\NatureServe\\NNFG_natureserve_state_data.csv")


ns_state_eligible <- state_data |>
  rename(rounded_gRank = nature_serve_rounded_global_rank) |>
  filter(
    str_detect(rounded_gRank, "[GT][123]") |
      str_detect(NE_sRank, "[ST][12]")
  ) |>
  distinct(scientific_name, taxon_id, .keep_all = T)

ns_state_eligible_cl <- ns_state_eligible |>
  select(taxon_id, scientific_name, common_name, rounded_gRank, NE_sRank, SD_sRank, usfws_status = u_s_endangered_species_act_status, kingdom:form) |>
  mutate(taxon_id = as.character(taxon_id)) |>
  distinct(taxon_id, scientific_name, rounded_gRank, NE_sRank, SD_sRank)

## These are the species that are problematic from the state NatureServe Lists.
find_problems <- ns_state_eligible_cl |>
  group_by(taxon_id) |>
  mutate(n = n()) |>
  ungroup() |>
  mutate(taxon_id = as.character(taxon_id))

taxon_problems <- find_problems |>
  filter(n > 1) |>
  arrange(scientific_name) |>
  select(-n)

no_taxon_problems <- find_problems |>
  filter(n == 1) |>
  select(-n)

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
t_path <- file.path(
  "T:/FS/NFS/PSO/MPSG/2024_NebraskaNFG/1_PreAssessment",
  "Projects/SpeciesList_NNFG"
)

## NHP Data

nhp_rdat <- file.path(t_path, "reproduce", "state_nhp.RData")
attach(nhp_rdat)

# test_list<-sf_nenhp_unit |>
#   as_tibble() |>
#   mutate(
#       f_year = year(first_date),
#       l_year = year(last_date)
#     ) |>
#   group_by(SNAME) |>
#   summarize(
#     SDNHP_nObs = n(),
#     f_year = min(f_year),
#     l_year = max(f_year)
#   ) |>
#   ungroup() |>
#   rename(scientific_name = SNAME) |>
#   get_taxonomies()
#


# test_list |>
#   ## This filters out all ecosystems unser scientific_name may want to move this up stream.
#   filter(!is.na(taxon_id)) |>
#   group_by(taxon_id) |>
#   mutate(n=n()) |>
#   filter(n>1) |>
#   arrange(taxon_id) |>
#   select(scientific_name, taxon_id) |>
#   View()
#

# test_list  |>
#   head(10) |>
#   pull(SNAME) |>
#   classification(sci_id, db ="gbif")

## Clean the NENHP List.  Had to combine species into one due to duplicates (may need to fix upstream).
nenhp_list_cl <- nenhp_list |>
  select(taxon_id, scientific_name, NENHP_nObs:NENHP_lastYear) |>
  rename(NENHP_maxYear = NENHP_lastYear) |>
  filter(!is.na(taxon_id)) |>
  distinct() |>
  group_by(taxon_id) |>
  mutate(
    NENHP_nObs = max(NENHP_nObs),
    NENHP_minYear = min(NENHP_firstYear),
    NENHP_maxYear = max(NENHP_maxYear)
  ) |>
  ungroup() |>
  select(taxon_id, scientific_name, NENHP_nObs, NENHP_minYear, NENHP_maxYear) |>
  distinct()

nenhp_list_cl |>
  group_by(taxon_id) |>
  mutate(n = n()) |>
  filter(n > 1) |>
  ungroup() |>
  arrange(taxon_id) |>
  View()

sdnhp_list_cl <- sdnhp_list |>
  select(taxon_id, scientific_name, SDNHP_nObs:SDNHP_lastYear) |>
  rename(SDNHP_maxYear = SDNHP_lastYear) |>
  filter(!is.na(taxon_id)) |>
  distinct() |>
  group_by(taxon_id) |>
  mutate(
    SDNHP_nObs = max(SDNHP_nObs),
    SDNHP_minYear = min(SDNHP_firstYear),
    SDNHP_maxYear = max(SDNHP_maxYear)
  ) |>
  ungroup() |>
  select(taxon_id, scientific_name, SDNHP_nObs, SDNHP_minYear, SDNHP_maxYear) |>
  distinct() |>
  ## In the NHP data there two synonyms for Argynnis idalia.  This removes the one that is not used.
  filter(scientific_name != "Speyeria idalia")

sdnhp_list_cl |>
  group_by(taxon_id) |>
  mutate(n = n()) |>
  filter(n > 1) |>
  ungroup() |>
  arrange(taxon_id)
View()


detach()

## GBIF
gbif_rdat <- file.path(t_path, "reproduce", "gbif.RData")
attach(gbif_rdat)

gbif_list_cl <- gbif_list |>
  select(taxon_id, scientific_name, GBIF_nObs:GBIF_maxYear) |>
  group_by(taxon_id) |>
  mutate(
    GBIF_nObs = max(GBIF_nObs, na.rm = T),
    GBIF_minYear = min(GBIF_minYear, na.rm = T),
    GBIF_maxYear = max(GBIF_maxYear, na.rm = T)
  ) |>
  distinct() |>
  filter(scientific_name != "Aeorestes cinereus")

gbif_list_cl |>
  group_by(taxon_id) |>
  mutate(n = n()) |>
  filter(n > 1) |>
  arrange(scientific_name)
View()


detach()

## iDigBio
idb_rdat <- file.path(t_path, "reproduce", "idigbio.RData")
attach(idb_rdat)

idb_list_cl <- idb_list |>
  select(taxon_id, scientific_name, iDB_nObs:iDB_maxYear) |>
  ## Removing synonym, could be decreasing nObs by 2
  filter(scientific_name != "Atriplex suckleyi")

idb_list_cl |>
  filter(taxon_id == "7979948")
detach()

## Seinet

seinet_rdat <- file.path(t_path, "reproduce", "seinet.RData")
attach(seinet_rdat)

seinet_list_cl <- seinet_list |>
  select(taxon_id, scientific_name, SEI_nObs:SEI_maxYear) |>
  group_by(taxon_id) |>
  mutate(
    SEI_nObs = sum(SEI_nObs),
    SEI_minYear = min(SEI_minYear),
    SEI_maxYear = max(SEI_maxYear)
  ) |>
  distinct(taxon_id, SEI_nObs, SEI_minYear, SEI_maxYear, .keep_all = T)

head(seinet_list, 60) |>
  View()

seinet_list |>
  count(SEI_locale)

seinet_list_cl |>
  group_by(taxon_id) |>
  mutate(n = n()) |>
  filter(n > 1) |>
  arrange(taxon_id)

detach()

## IMBCR
imbcr_rdat <- file.path(t_path, "reproduce", "imbcr.RData")
attach(imbcr_rdat)

imbcr_list_cl <- imbcr_list |>
  select(taxon_id, scientific_name, IMBCR_nObs:IMBCR_maxYear)
detach()

##  Combine All Layers
### - 6 species that have NAs for taxon_id in the species list.

joined_lists <- no_taxon_problems |>
  left_join(select(nenhp_list_cl, -scientific_name), by = "taxon_id") |>
  left_join(select(sdnhp_list_cl, -scientific_name), by = "taxon_id") |>
  left_join(select(seinet_list_cl, -scientific_name), by = "taxon_id") |>
  left_join(select(gbif_list_cl, -scientific_name), by = "taxon_id") |>
  left_join(select(idb_list_cl, -scientific_name), by = "taxon_id")

joined_lists |>
  group_by(taxon_id) |>
  mutate(n = n()) |>
  filter(n > 1)
View()

joined_lists |>
  mutate_at(vars(matches("nObs")), .funs = ~ replace_na(.x, 0)) |>
  mutate(sum_nObs = SDNHP_nObs + NENHP_nObs + SEI_nObs + GBIF_nObs + iDB_nObs) |>
  filter(sum_nObs > 0)
View()


## Edit list scripts
fp <- list.files("output", pattern = "OPEN_TO_EDITING_20240909", full.names = T)
old_verify <- read_excel(fp, sheet = "Native_Known_Verify")

new_list <- tar_read(native_known_need_check)

anti_join(new_list, old_verify, by = "taxon_id") |>
  write_csv("output/add_native_and_known_needs_added_on_09122024.csv")
