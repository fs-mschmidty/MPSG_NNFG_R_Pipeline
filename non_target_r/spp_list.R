#' ---
#' title: "External Species Occurrence Data Pull"
#' author:
#'   - name: "Matthew Van Scoyoc" 
#'     affiliation: |
#'       | Mountain Planning Service Group, Regions 1-4
#'       | Forest Service, USDA
#' date: 26 October, 2023
#' 
#' This script submits a records request to Global Biodiversity Information 
#'    Facility (GBIF) and iDigBio using the 1 km sf_buffered administrative 
#'    forest or grassland boundary to spatially query species observation 
#'    records.
#' The data are downloaded and read in to R once the requests are available.
#' This script creates a sub-directory for forest/grassland to save:
#'    -   a copy of the sppPullReport.Rmd,
#'    -   the zipped data from GBIF, 
#'    -   the R objects produced from this script in an *.RData file, and
#'    -   *.csv files of the GBIF and iDigBio data.
#' Open the sppPullReport.Rmd in the sub-directory and edit the title and 
#'    `params` in the YAML header to generate custom report for these data upon 
#'    execution of this script.
#' See the accompanying sppPullReport.Rmd for details and data use limitations.
#' -----------------------------------------------------------------------------

# Setup ----
#-- Global settings
t0 <- lubridate::now()

#-- Project variables
# Forest names
unit_code <- "NNFG"
unit_full <- "Nebraska National Forests and Grasslands"
states <- c("NE", "SD")
# T-drive folder
t_path <- file.path("T:/FS/NFS/PSO/MPSG/2024_NebraskaNFG/1_PreAssessment", 
                    "Projects/SpeciesList_NNFG")


#-- Packages
# R packages used in this script
pkgs <- c("dplyr",       # data management
          "ggplot2",     # plotting/graphing
          "here",        # navigating directories
          "lubridate",   # dating
          "natserv",     # NatureServe taxonomic status
          "plyr",        # data management
          "rgbif",       # retrieve data from GBIF
          "spocc",       # retrieve data from iDigBio
          "sf",          # spatial functions
          "taxize",      # species name verification
          "tibble",      # data structures
          "tidyr",       # data management
          "tmap",        # mapping
          "stringr")     # text string editing

# Install packages if they aren't in your library
inst_pkgs <- pkgs %in% rownames(installed.packages())
if (any(inst_pkgs == FALSE)) {
  install.packages(pkgs[!inst_pkgs], 
                   lib =  .libPaths()[1], 
                   repos = "https://cloud.r-project.org",
                   type = 'source', 
                   dependencies = TRUE, 
                   quiet = TRUE)
  }

# Load packages
# invisible(lapply(pkgs, library, character.only = TRUE))

#-- Functions
# The functions.R script holds functions for reading and clipping feature 
#    classes from geodatabases
source("functions.R")
# source(file.path("C:/Users/matthewvanscoyoc/Documents/R/mpsgSO/R", 
#                  "get_taxonomies.R"))
source(file.path("C:/Users/matthewvanscoyoc/Documents/R/mpsgSO/R", 
                 "ns_ranks.R"))

# Spatial Data ----
source("aoa_maps.R")

# State Heritage Program ----
nhp_rdat <- file.path(t_path, 'reproduce', "state_nhp.RData")
if (file.exists(nhp_rdat)){
  message("Loading *.RData")
  load(nhp_rdat)
  } else ({
    message("Edit and run `state_nhp.R` to generate NPH data.")
    file.edit(file.path(t_path, 'reproduce', 'state_nhp.R'))
    })

#-- Visualize data
base_map +
  tmap::tm_shape(sf_nenhp_buff) +
  tmap::tm_polygons(col = 'cyan', border.col = 'cyan') +
  tmap::tm_shape(sf_sdnhp_unit) + 
  tmap::tm_polygons(col = 'cyan', border.col = 'cyan') + 
  tmap::tm_shape(sf_nenhp_unit) + 
  tmap::tm_polygons(col = 'blue', border.col = 'blue') +
  tmap::tm_shape(sf_sdnhp_unit) + 
  tmap::tm_polygons(col = 'blue', border.col = 'blue') + 
  tmap::tm_add_legend(type = "fill", title = "Species EOs",
                      labels = c("EOs on FS", "EOs in Buffer"),
                      col = c("blue", "cyan")) +
  base_legend +
  tmap::tm_layout(main.title = "State NHP Data")

dplyr::glimpse(state_list)

# GBIF ----
gbif_rdat <- file.path(t_path, 'reproduce', "gbif.RData")
if(file.exists(gbif_rdat)){
  message("Loading *.RData")
  load(gbif_rdat)
  } else(source("gbif.R"))

#-- Visualize data
pch_shape <- 21
pch_size <- 0.1
base_map +
  tmap::tm_shape(sf_gbif_buff) + 
  tmap::tm_dots(col = 'cyan', shape = pch_shape, size = pch_size) +
  tmap::tm_shape(sf_gbif_unit) + 
  tmap::tm_dots(col = 'blue', shape = pch_shape, size = pch_size) + 
  tmap::tm_add_legend(type = "symbol", title = "Species Obs",
                      labels = c("On FS Land", "In 1km sf_buffer"), 
                      col = c("blue", "cyan"), shape = pch_shape) +
  base_legend +
  tmap::tm_layout(main.title = "GBIF Data")

dplyr::glimpse(gbif_list)

# iDigBio ----
idb_rdat <- file.path(t_path, 'reproduce', "idigbio.RData")
if(file.exists(idb_rdat)){
  message("Loading *.RData")
  load(idb_rdat)
  } else(source("idigbio.R"))

#-- Visualize data
base_map +
  tmap::tm_shape(sf_idb_buff) + 
  tmap::tm_dots(col = 'cyan', shape = pch_shape, size = pch_size) +
  tmap::tm_shape(sf_idb_unit) + 
  tmap::tm_dots(col = 'blue', shape = pch_shape, size = pch_size) + 
  tmap::tm_add_legend(type = "symbol", title = "Species Obs",
                      labels = c("On FS Land", "In 1km sf_buffer"), 
                      col = c("blue", "cyan"), shape = pch_shape) +
  base_legend +
  tmap::tm_layout(main.title = "iDigBio Data")

dplyr::glimpse(idb_list)

# SEINet ----
seinet_rdat <- file.path(t_path, 'reproduce', "seinet.RData")
if(file.exists(seinet_rdat)){
  message("Loading *.RData")
  load(seinet_rdat)
} else(source("seinet.R"))

# Visualize Data
base_map  +
  tmap::tm_shape(sf_seinet_buff) +
  tmap::tm_dots(col = 'cyan', shape = pch_shape, size = pch_size) +
  tmap::tm_shape(sf_seinet_unit) +
  tmap::tm_dots(col = 'blue', shape = pch_shape, size = pch_size) +
  tmap::tm_add_legend(type = "symbol", title = "Species Obs",
                      labels = c("On FS Land", "In 1km sf_buffer"),
                      col = c("blue", "cyan"), shape = pch_shape) +
  base_legend +
  tmap::tm_layout(main.title = "SEINet Data")

dplyr::glimpse(seinet_list)

# #-- Clean invalid names (non-UTF8 special characters)
# fix_spp <- c("Buchloe dactyloides", 
#              "Callirhoe involucrata var. lineariloba", 
#              "Cheilanthes feei", 
#              "Helianthus petiolaris var. petiolaris",
#              "Helianthus petiolaris var. petiolaris", 
#              "Oonopsis engelmannii", 
#              "Oonopsis foliosa var. foliosa", 
#              "Populus x acuminata", 
#              "Quercus x undulata", 
#              "Salix amygdaloides x Salix nigra", 
#              "Salix amygdaloides x Salix nigra")
# seinet_list$scientific_name[!validUTF8(seinet_list$scientific_name)] <- fix_spp

# IMBCR ----
imbcr_rdat <- file.path(t_path, 'reproduce', "imbcr.RData")
if(file.exists(imbcr_rdat)){
  message("Loading *.RData")
  load(imbcr_rdat)
} else(source("imbcr.R"))

# Visualize data
base_map +
  tmap::tm_shape(sf_imbcr) + 
  tmap::tm_dots(col = 'cyan', shape = pch_shape, size = pch_size) +
  tmap::tm_shape(sf_imbcr_unit) + 
  tmap::tm_dots(col = 'blue', shape = pch_shape, size = pch_size) +
  tmap::tm_add_legend(type = "symbol", title = "Species Obs",
                      labels = c("On FS Land", 
                                 "On Non-FS Land"), 
                      col = c("blue", "cyan"), shape = pch_shape) +
  base_legend +
  tmap::tm_layout(main.title = "IMBCR Data")

dplyr::glimpse(imbcr_list)


# Species Lists ----

## Conservation Lists ----
cons_list_path <- file.path(t_path, "reproduce", 
                            "all_state_and_fed_lists_CCNG.csv")
cons_list <- read.csv(cons_list_path)
status <- cons_list |> 
  dplyr::select(taxon_id, scientific_name, status_c, status_r) |> 
  dplyr::group_by(taxon_id, scientific_name, status_c) |> 
  dplyr::summarise(status_r = stringr::str_c(unique(status_r), 
                                             collapse = ", "), 
                   .groups = 'drop') |> 
  tidyr::pivot_wider(names_from = status_c, values_from = status_r, 
                     values_fill = NA) |> 
  dplyr::mutate(taxon_id = as.character(taxon_id))

## Taxonomy ----
# vars to select
tax_vars <- c("taxon_id", "kingdom", "phylum", "class", "order", "family", 
              "genus", "species", "scientific_name")
taxonomy_all <- dplyr::select(nenhp_list, tax_vars, "subspecies", "variety") |> 
  dplyr::mutate(form = NA, source = "CONHP") |> 
  rbind(dplyr::select(sdnhp_list, tax_vars, "subspecies", "variety") |> 
          dplyr::mutate(form = NA, source = "KSNHI")) |> 
  rbind(dplyr::select(gbif_list, tax_vars, "subspecies", "variety", "form") |> 
          dplyr::mutate(source = "GBIF")) |> 
  rbind(dplyr::select(idb_list, tax_vars, "subspecies", "variety", "form") |> 
          dplyr::mutate(source = "iDigBio")) |> 
  rbind(dplyr::select(seinet_list, tax_vars, "subspecies", "variety", "form") |> 
          dplyr::mutate(source = "SEINet")) |> 
  rbind(dplyr::select(imbcr_list, tax_vars) |> 
          dplyr::mutate(subspecies = NA, variety = NA, form = NA, 
                        source = "IMBCR")) |> 
  dplyr::distinct()

taxonomy <- dplyr::select(taxonomy_all, tax_vars, "subspecies", 
                          "variety", "form") |> 
  dplyr::distinct() |> 
  dplyr::left_join(taxonomy_all |> 
                     dplyr::group_by(taxon_id, scientific_name) |> 
                     dplyr::summarise(source = stringr::str_c(unique(source), 
                                                              collapse = ", "), 
                                      .groups = "drop"), 
                   by = c("taxon_id", "scientific_name")) |> 
  dplyr::mutate(
    accepted_scientific_name = ifelse(!is.na(form), form, NA), 
    accepted_scientific_name = ifelse(is.na(accepted_scientific_name), 
                                      variety, accepted_scientific_name), 
    accepted_scientific_name = ifelse(is.na(accepted_scientific_name), 
                                      subspecies, accepted_scientific_name), 
    accepted_scientific_name = ifelse(is.na(accepted_scientific_name), 
                                      species, accepted_scientific_name)
  ) |> 
  dplyr::select(taxon_id, accepted_scientific_name, kingdom:species, 
                subspecies:form, source,scientific_name)


## NatureServe Conservation Status ----
# query NatureServe using accepted scientific name
ns_list <- ns_ranks(taxonomy$accepted_scientific_name, states = states) |> 
  dplyr::select(input_name, scientific_name:KS_native_NS) |> 
  get_taxonomies(query_field = "input_name") |> 
  dplyr::distinct()

# query NatureServe for species that didn't get taxonomy using the original 
#    scientific name
ns_list_no_tax <- ns_ranks(taxonomy[is.na(taxonomy$accepted_scientific_name), 
                                    'scientific_name'], 
                           states = states) |> 
  dplyr::select(input_name, scientific_name:KS_native_NS) |> 
  get_taxonomies(query_field = "scientific_name") |> 
  dplyr::distinct() |> 
  dplyr::mutate(
    accepted_scientific_name = ifelse(!is.na(variety), variety, NA), 
    accepted_scientific_name = ifelse(is.na(accepted_scientific_name), 
                                      species, accepted_scientific_name)
  ) |> 
  dplyr::left_join(taxonomy[is.na(taxonomy$accepted_scientific_name), 
                            c('scientific_name', 'source')], 
                   by = dplyr::join_by("input_name" == "scientific_name"))

# update NatureServe list
ns_list <- rbind(ns_list, 
                 ns_list_no_tax |>
                   dplyr::mutate(subspecies = NA, form = NA) |>
                   dplyr::select(colnames(ns_list))) |> 
  dplyr::distinct()

## Update taxonomy ----
taxonomy <- rbind(taxonomy, 
                  ns_list_no_tax |> 
                    dplyr::mutate(subspecies = NA, form = NA) |> 
                    dplyr::select(colnames(taxonomy))) |> 
  dplyr::distinct() |> 
  dplyr::arrange(kingdom, phylum, class, order, family, genus, 
                 accepted_scientific_name)

#-- Accepted Scientific Name Data Frame
accepted_taxonomy <- taxonomy |> 
  dplyr::distinct(taxon_id, .keep_all = TRUE)

## Compiles Species Data ----
spp_dat <- accepted_taxonomy |> 
  dplyr::select(taxon_id) |> 
  dplyr::left_join(
    dplyr::select(state_list, taxon_id, NENHP_nObs:NENHP_locale, 
                  SDNHP_nObs:SDNHP_locale) |>
      dplyr::distinct(), 
    by = "taxon_id") |> 
  dplyr::left_join(
    dplyr::select(gbif_list, taxon_id, GBIF_nObs:GBIF_locale) |>
      dplyr::distinct(),
    by ="taxon_id", relationship = "many-to-many"
    ) |> 
  dplyr::left_join(
    dplyr::select(idb_list, taxon_id, iDB_nObs:iDB_locale) |>
      dplyr::distinct(), 
    by =c("taxon_id"), relationship = "many-to-many"
  ) |> 
  dplyr::left_join(
    dplyr::select(seinet_list, taxon_id, SEI_nObs:SEI_locale) |>
      dplyr::distinct(),
    by =c("taxon_id"), relationship = "many-to-many"
  ) |> 
  dplyr::left_join(
    dplyr::select(imbcr_list, taxon_id, IMBCR_nObs:IMBCR_recID, IMBCR_locale) |>
      dplyr::distinct(),
    by =c("taxon_id"), relationship = "many-to-many"
  ) |> 
  # dplyr::distinct() |> 
  dplyr::left_join(status, by = "taxon_id", relationship = "many-to-many") |> 
  dplyr::distinct(taxon_id, .keep_all = TRUE) |> 
  dplyr::select(taxon_id, "State Rank - Colorado", 
                "State List Status - Colorado", "State Rank - Kansas", 
                "State List Status - Kansas", "US Forest Service", "BLM", 
                CONHP_nObs:CPW_maxYear)
spp_dat[spp_dat == ""] <-  NA

# Calculate Nativity
native <- ns_list |> 
  dplyr::select(taxon_id, dplyr::contains("native")) 
native$planArea_native <- apply(native[, 2:ncol(native)], 1, function(x)(any(x)))

# Calculate Known to Occur
locale_vars <- dplyr::select(spp_list, dplyr::contains("locale")) |> colnames()
occur <- spp_list |> 
  dplyr::select(taxon_id, dplyr::any_of(locale_vars)) |> 
  dplyr::mutate_at(.vars = locale_vars, function(x) ifelse(x == unit_code, 
                                                                 TRUE, FALSE)) |> 
  dplyr::mutate_all(function(x)ifelse(is.na(x), FALSE, x))
occur$known_occur <- apply(occur[, 2:ncol(occur)], 1, function(x)(any(x)))

# Compile Lists
full_list <- accepted_taxonomy |> 
  dplyr::select(-scientific_name)|> 
  dplyr::left_join(dplyr::select(ns_list, taxon_id, common_name:KS_native_NS), 
                   by = "taxon_id", relationship = "many-to-many") |> 
  dplyr::left_join(dplyr::select(native, taxon_id, planArea_native), 
                   by = "taxon_id", relationship = "many-to-many") |> 
  dplyr::left_join(dplyr::select(occur, taxon_id, known_occur), 
                   by = "taxon_id", relationship = "many-to-many") |> 
  dplyr::left_join(spp_dat, by = "taxon_id", relationship = "many-to-many") |> 
  dplyr::select(taxon_id, accepted_scientific_name, common_name, planArea_native, 
                CO_native_NS, KS_native_NS, known_occur, usfws_esa, 
                rounded_gRank:KS_sRank, `State Rank - Colorado`:BLM, 
                CONHP_nObs:CPW_maxYear, kingdom:form, source) |> 
  dplyr::distinct(taxon_id, .keep_all = TRUE) |> 
  dplyr::arrange(kingdom, phylum, class, order, family, genus, 
                 accepted_scientific_name)


# Potential Overviews ----
g_ranks <- c(unique(full_list$gRank), unique(full_list$gRank))
g_ranks <- g_ranks[grepl("G1|G2|G3", g_ranks)]

s_ranks <- c(unique(full_list$CO_sRank), unique(full_list$KS_sRank))
s_ranks <- s_ranks[grepl("S1|S2", s_ranks)]

tier <- c(unique(full_list$`State List Status - Colorado`), 
          unique(full_list$`State List Status - Kansas`))
tiers <- tier[grepl('Tier 1|Tier I|SE|ST|SC|Endangered|Threatened|Candidate', tier)]
tiers <- tier[!tier == "Tier II"]
tiers <- tier[!tier == "Tier II, SH"]


spp_ovrvws <- full_list |> 
  # Filter native
  dplyr::filter(planArea_native == TRUE)  |> 
  # Filtering for Known to Occur
  dplyr::filter(known_occur == TRUE) |> 
  dplyr::filter(
    # Filter G1, G2, or G3
    gRank %in% g_ranks | 
      # Filter S1, S2, or S3
      CO_sRank %in% s_ranks | KS_sRank %in% s_ranks |  
      # stringr::str_detect(`State Rank - Colorado`, s_ranks) |
      # stringr::str_detect(`State Rank - Kansas`, s_ranks) |
      # Filter SWAP spp
      `State List Status - Colorado` %in% tiers |
      `State List Status - Kansas` %in% tiers |
      # Filter spp on the RFSS list
      grepl('USFS Sensitive', `US Forest Service`)
  ) |> 
  dplyr::distinct(taxon_id, .keep_all = TRUE)


# Previous List Comparison ----
old_list_path <- file.path(Sys.getenv("USERPROFILE"), "USDA", 
                           "Mountain Planning Service Group - SCC Library", 
                           "Cimarron Comanche NG/Species List")
old_list_name <- "CURRENT 20240605_CCNG_SpeciesList.xlsx"
old_list <- readxl::read_xlsx(path = old_list_name, 
                              sheet = "Eligible Overviews") |> 
  dplyr::select(Assignment:common_name) |> 
  get_taxonomies(query_field = "scientific_name")
old_list$rowid <- row.names(old_list)

spp_ovrvws <- spp_ovrvws |> 
  dplyr::mutate(NEW_SPP = ifelse(!taxon_id %in% old_list$taxon_id, 
                                 TRUE, FALSE)) |> 
  dplyr::select(taxon_id:common_name, NEW_SPP, planArea_native:source)

spp_ovrvws_tracking <-dplyr::select(old_list,
                                    rowid, Assignment:Migratory, taxon_id) |> 
  dplyr::filter(taxon_id %in% spp_ovrvws$taxon_id) |> 
  dplyr::full_join(spp_ovrvws, by = "taxon_id") |> 
  dplyr::arrange(kingdom, phylum, class, order, family, genus, 
                 accepted_scientific_name)

dropped_spp <- dplyr::filter(old_list, !rowid %in% spp_ovrvws_tracking$rowid) |> 
  dplyr::select(Assignment:Migratory, taxon_id) |> 
  dplyr::left_join(full_list, by = "taxon_id") |> 
  dplyr::arrange(kingdom, phylum, class, order, family, genus, 
                 accepted_scientific_name)

spp_ovrvws_tracking <- dplyr::select(spp_ovrvws_tracking, -rowid)

# Species in 1km Buffer ----
# Full buffer list
buff_list <- dplyr::filter(full_list, known_occur == FALSE) 

# Buffer spp that meet overveiw critereia
buff_ovrvws <- buff_list |> 
  # Filter native
  dplyr::filter(planArea_native == TRUE)  |> 
  # Filtering for Known to Occur
  dplyr::filter(known_occur == TRUE) |> 
  dplyr::filter(
    # Filter G1, G2, or G3
    stringr::str_detect(rounded_gRank, 'G1|G2|G3') |
      # Filter S1, S2, or S3
      stringr::str_detect(CO_sRank, 'S1|S2|S3') |
      stringr::str_detect(KS_sRank, 'S1|S2|S3') |
      stringr::str_detect(`State Rank - Colorado`, 'S1|S2|S3') |
      stringr::str_detect(`State Rank - Kansas`, 'S1|S2|S3') |
      # Filter SWAP spp
      stringr::str_detect(`State List Status - Colorado`, 'Tier') |
      stringr::str_detect(`State List Status - Kansas`, 'Tier') |
      # Filter spp on the RFSS list
      stringr::str_detect(`US Forest Service`, 'USFS Sensitive')
  ) |> 
  dplyr::distinct(taxon_id, .keep_all = TRUE)  



# Conservation Lists ----
obs_vars <- dplyr::select(full_list, dplyr::contains("nObs")) |> colnames()
status_obs <- status |> 
  dplyr::left_join(dplyr::select(full_list, taxon_id, obs_vars), 
                   by = "taxon_id", relationship = "many-to-many") |> 
  dplyr::distinct(taxon_id, scientific_name, .keep_all = TRUE)

status_obs$total_nObs <- rowSums(status_obs[, obs_vars], na.rm = TRUE)


# Column Definitions ----
## Data ----
data_defs <- tibble::tibble(
  column_name = colnames(spp_ovrvws_tracking), 
  definition = c(
    "Character. Biologist writing overview document.", 
    "Character. Notes.",
    "Character. Status of overview document.",
    "Character. Has overveiw document been reviewed by Tyler.",
    "Character. Does species have a restricted range.", 
    "Character. Is species also on NNFG. Yes/No",
    "Character. Is the species migratory.",
    
    # NatureServe Data
    "Numeric. Taxonomic ID number from GBIF.",
    "Character. Accepted scientific names from GBIF.",
    "Character. Common name used in NatureServe.",
    "Logical. Is taxon new to this version of the list. TRUE/FALSE",
    "Logical. Nativity to the planning area (if CO_native_NS is TRUE <OR> if 
    KS_native_NS is TRUE). TRUE/FALSE.", 
    "Logical. NatureServe nativity status for Colorado (CO). TRUE/FALSE.", 
    "Logical. NatureServe nativity status for Kansas (KS). TRUE/FALSE.", 
    "Logical. The species is present in the planning area. TRUE/FALSE.",

    "Character. US Fish & Wildlife (USFWS) Endangered Species Act (ESA) listing 
    code from NatureServe.",
    
    "Character. The rounded NatureServe global rank (G-rank).",
    "Character. NatureServe G-rank.",
    "Character. NatureServe state rank (S-rank) for CO.", 
    "Character. NatureServe S-rank for KS.", 
    
    "Character. CO S-rank from CO NHP.", 
    "Character. CO species status.", 
    "Character. KS S-rank from KS NHI.", 
    "Character. KS NHP species status.", 
    "Character. USFS Sensitive Species List status.", 
    "Character. BLM Sensitive Species List status.",

    # CNHP Data
    "Numeric. Count of observations in CO NHP data.",
    "Date. First year of occurence in CO NHP data.",
    "Date. Last year of occurence in CO NHP data.",
    "Character. List of EO ID's from CO NHP data separated by commas.",
    "Character. Location of CO NHP observation. CCNG, Buffer, or NA.",
    # KS NHI Data
    "Numeric. Count of observations in KS NHI data.",
    "Date. First year of occurence in KS NHI data.",
    "Date. Last year of occurence in KS NHI data.",
    "Character. List of EO ID's from KS NHI data separated by commas.",
    "Character. Location of KS NHI observation. CCNG, Buffer, or NA.",
    # GBIF Data
    "Numeric. Count of observations in GBIF data.",
    "Numeric. First year of GBIF observations.", 
    "Numeric. Last year of GBIF observations.",
    "Character. GBIF taxon ID. Some species will have multiple ID numbers if 
    they were originally classified as a subspecies and that subspecies was 
    dissolved into a higher taxon (i.e., species).",
    "Character. Occurrence IDs for records wher GBIF_nObs is less than or equal 
    to 6.", 
    "Character. Location of GBIF observation. CCNG, Buffer, or NA.",
    # iDigBio Data
    "Numeric. Count of observations in iDigBio (iDB) data.",
    "Numeric. First year of iDigBio (iDB) observations.", 
    "Numeric. Last year of iDigBio (iDB) observations.",
    "Character. iDigBio (iDB) taxon ID. Some species will have multiple ID 
    numbers if they were originally classified as a subspecies and that 
    subspecies was dissolved into a higher taxon (i.e., species).",
    "Character. Occurrence IDs for records wher iDB_nObs is less than or equal 
    to 6.", 
    "Character. Location of iDigBio observation. CCNG, Buffer, or NA.",
    # SEINet Data
    "Numeric. Count of observations in SEINet (SEI) data.",
    "Numeric. First year of SEINet (SEI) observations.", 
    "Numeric. Last year of SEINet (SEI) observations.",
    "Character. SEINet (SEI) taxon ID. Some species will have multiple ID 
    numbers if they were originally classified as a subspecies and that 
    subspecies was dissolved into a higher taxon (i.e., species).",
    "Character. Occurrence IDs for records wher SEI_nObs is less than or equal 
    to 6.", 
    "Character. Location of SEINet observation. CCNG, Buffer, or NA.",
    # IMBCR Data
    "Numeric. Count of observations in IMBCR data.",
    "Numeric. First year of IMBCR observations.", 
    "Numeric. Last year of IMBCR observations.",
    "Character. List of IMBCR record ID's.",
    "Character. Location of IMBCR observation. CCNG, Buffer, or NA.",
    # CPW Bat Data
    "Numeric. Count of observations in Colorado Parks and Wildlife (CPW) bat 
    data.",
    "Numeric. First year of CPW bat observations.", 
    "Numeric. Last year of CPW bat observations.",
    # Taxonomy
    "Character. Taxonomic Kingdom",
    "Character. Taxonomic Phylum",
    "Character. Taxonomic Class",
    "Character. Taxonomic Order",
    "Character. Taxonomic Family",
    "Character. Taxonomic Genus", 
    "Character. Taxonomic species name", 
    "Character. Taxonomic subspecies name", 
    "Character. Taxonomic variety name", 
    "Character. Taxonomic form name", 
    "Character. Data sources the species came from in comma delimited format."
  )
)

## Taxonomy ----
taxa_defs <- tibble::tibble(
  column_name = colnames(taxonomy), 
  definition = c(
    "Character. Taxonomic ID number from GBIF.", 
    "Character. Accepted scientific name.",
    "Character. Taxonomic Kingdom",
    "Character. Taxonomic Phylum",
    "Character. Taxonomic Class",
    "Character. Taxonomic Order",
    "Character. Taxonomic Family",
    "Character. Taxonomic Genus", 
    "Character. Taxonomic species name", 
    "Character. Taxonomic subspecies name", 
    "Character. Taxonomic variety name", 
    "Character. Taxonomic form name", 
    "Character. Data sources the species came from in comma delimited format.", 
    "Character. Scientific name used in the source data."
    )
)


# Save ----
## Excel ----
# Create Excel workbook
my_wb <- openxlsx::createWorkbook()

# Eligible Species Overview list
openxlsx::addWorksheet(wb = my_wb, sheetName = "Eligible Overviews - Data")
openxlsx::writeData(wb = my_wb, sheet = "Eligible Overviews - Data",
                    x = spp_ovrvws_tracking, 
                    colNames = TRUE, rowNames = FALSE, keepNA = TRUE)
# Dropped Species
openxlsx::addWorksheet(wb = my_wb, sheetName = "Dropped Species")
openxlsx::writeData(wb = my_wb, sheet = "Dropped Species", 
                    x = dropped_spp,
                    colNames = TRUE, rowNames = FALSE, keepNA = TRUE)
# Comprehensive List
openxlsx::addWorksheet(wb = my_wb, sheetName = "Comprehensive List")
openxlsx::writeData(wb = my_wb, sheet = "Comprehensive List", 
                    x = dplyr::filter(full_list, known_occur == TRUE),
                    colNames = TRUE, rowNames = FALSE, keepNA = TRUE)
# Conservation Lists
openxlsx::addWorksheet(wb = my_wb, sheetName = "Conservation Lists")
openxlsx::writeData(wb = my_wb, sheet = "Conservation Lists", 
                    x = status_obs,
                    colNames = TRUE, rowNames = FALSE, keepNA = TRUE)
# Taxonomy
openxlsx::addWorksheet(wb = my_wb, sheetName = "Taxonomy")
openxlsx::writeData(wb = my_wb, sheet = "Taxonomy",
                    x = taxonomy, 
                    colNames = TRUE, rowNames = FALSE, keepNA = TRUE)
# Add Buffer Species data
openxlsx::addWorksheet(wb = my_wb, sheetName = "Buffer Species")
openxlsx::writeData(wb = my_wb, sheet = "Buffer Species",
                    x = buff_list,
                    colNames = TRUE, rowNames = FALSE, keepNA = TRUE)
# Metadata sheets
openxlsx::addWorksheet(wb = my_wb, sheetName = "Data Definitions")
openxlsx::writeData(wb = my_wb, sheet = "Data Definitions", x = data_defs,
                    colNames = TRUE, rowNames = FALSE, keepNA = TRUE)
openxlsx::addWorksheet(wb = my_wb, sheetName = "Taxonomy Definitions")
openxlsx::writeData(wb = my_wb, sheet = "Taxonomy Definitions", x = taxa_defs,
                    colNames = TRUE, rowNames = FALSE, keepNA = TRUE)
# Save workbook
excel_file <- paste0(gsub("-", "", lubridate::today()), "_", unit_code, 
                     "_SpeciesList.xlsx")
openxlsx::saveWorkbook(my_wb, file = file.path(t_path, excel_file),
                       overwrite = TRUE)

## RData ----
# Save ----
# save(gdb_path, shp_dir, lyr_fsland, lyr_planarea, lyr_aoa, lyr_buffer, 
#      sf_states, sf_freeways, sf_ushwys, sf_sthwys, sf_fsland, sf_planarea, 
#      sf_buffer, sf_aoa, crs, t_path, states,  
#      file = file.path(t_path, 'reproduce', "unit.RData"))

save(spp_list, ns_list, full_list, spp_ovrvws, buff_list, status_obs, 
     taxonomy_all, taxonomy, accepted_taxonomy,
     file = file.path(t_path, 'reproduce', "spp_list.RData"))


# Session ----
sessionInfo()

# Process Time ----
message(paste0("Total run time: ", 
               round(lubridate::time_length(lubridate::now()-t0, 'hour'), 1), 
               " hours"))
