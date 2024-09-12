# rfCreated by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c(
    "taxize",
    "tidyverse",
    "quarto",
    "sf",
    "readxl",
    "mpsgSO",
    "janitor",
    "httr2",
    "natserv",
    "openxlsx",
    "glue",
    "ebirdst",
    "fs"
  )
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

t_path_sp_list <- file.path("T:/FS/NFS/PSO/MPSG/2024_NebraskaNFG", "1_PreAssessment/Projects/SpeciesList_NNFG")
t_path_sp_list_rp <- file.path(t_path_sp_list, "reproduce")

# Replace the target list below with your own:
list(
  tar_target(sp_fp, "C:\\Users\\MichaelSchmidt2\\USDA\\Mountain Planning Service Group - SCC Library\\03_Nebraska NFG"),
  tar_target(natureserve_state_data, get_natureserve_state_data()),
  tar_target(external_data_folder, "T:\\FS\\NFS\\PSO\\MPSG\\Data\\ExternalData"),
  tar_target(output_natureserve_state_data, build_output_natureserve_state_data(natureserve_state_data, "T:\\FS\\NFS\\PSO\\MPSG\\Data\\ExternalData\\NatureServe", "NNFG_natureserve_state_data")),
  tar_target(nnfg_gdb, "T:/FS/NFS/PSO/MPSG/2024_NebraskaNFG/1_PreAssessment/Data/NNFG_BaseData.gdb"),
  tar_target(nnfg_bd, st_read(nnfg_gdb, "NNFG_AdminBdy")),
  tar_target(nnfg_crs, st_crs(nnfg_bd)),
  tar_target(nnfg_aoa, st_read(nnfg_gdb, "NNFG_AOA")),
  tar_target(nnfg_ownership, st_read(nnfg_gdb, "NNFG_BasicOwnership")),
  tar_target(nnfg_fs_ownership, nnfg_ownership |> filter(OWNERCLASSIFICATION == "USDA FOREST SERVICE")),

  ## Build Occurrence Lists for eligible list
  tar_target(t_drive_lists, build_t_drive_lists(file.path("T:/FS/NFS/PSO/MPSG/2024_NebraskaNFG/1_PreAssessment", "Projects/SpeciesList_NNFG", "reproduce"))),
  tar_target(sd_nhp_data, build_nhp_data("T:/FS/NFS/PSO/MPSG/Data/ExternalData/SD_NHP/20240123_SD_Natural_HeritagePrgm.gdb", "Natural_Heritage_Data_Restricted_Region2_FS_2024_01", nnfg_crs, nnfg_fs_ownership)),
  tar_target(ne_state_list, build_ne_state_list("T:\\FS\\NFS\\PSO\\MPSG\\2024_NebraskaNFG\\1_PreAssessment\\Projects\\SpeciesList_NNFG\\data\\state_lists\\nebraska\\Tier 1 and Tier 2 Species by Taxa plus Ranks_recieved_08262024.xlsx")),
  tar_target(sd_state_list, build_sd_state_list("T:\\FS\\NFS\\PSO\\MPSG\\2024_NebraskaNFG\\1_PreAssessment\\Projects\\SpeciesList_NNFG\\data\\state_lists\\south_dakota\\draft_SGCN_list_for_comment_July_2024.xlsx")),
  tar_target(r2_ss_list, build_r2_ss_list("data/fs/2023_R2_RegionalForestersSensitiveSppList.xlsx")),
  tar_target(eligible_lists, build_eligible_list(natureserve_state_data, t_drive_lists, ne_state_list, sd_state_list, r2_ss_list)),
  tar_target(transient_birds, build_transient_birds(eligible_lists, nnfg_aoa)),
  tar_target(native_known_need_check, build_native_known_need_check(eligible_lists))
  # tar_target(output_eligible_lists, build_output_eligible_lists(eligible_lists, "output", transient_birds, native_known_need_check)),

  ## Spatial data
  ### Occurrence Lists
  # tar_target(nhp_spatial_data, build_nhp_spatial_data(t_path_sp_list_rp, "state_nhp.RData")),
  # tar_target(sd_nhp_spatial_eligible, build_spatial_eligible_and_unit(nhp_spatial_data$sdnhp, nnfg_fs_ownership, eligible_lists$current_eligible_list)),
  # tar_target(ne_nhp_spatial_eligible, build_spatial_eligible_and_unit(nhp_spatial_data$nenhp, nnfg_fs_ownership, eligible_lists$current_eligible_list)),
  # tar_target(idb_spatial_data, build_idb_spatial_data(t_path_sp_list_rp, "idigbio.RData")),
  # tar_target(idb_spatial_eligible, build_spatial_eligible_and_unit(idb_spatial_data, nnfg_fs_ownership, eligible_lists$current_eligible_list)),
  # tar_target(seinet_spatial_data, build_seinet_spatial_data(t_path_sp_list_rp, "seinet.RData")),
  # tar_target(seinet_spatial_eligible, build_spatial_eligible_and_unit(seinet_spatial_data, nnfg_fs_ownership, eligible_lists$current_eligible_list)),
  # tar_target(gbif_spatial_data, build_gbif_spatial_data(t_path_sp_list_rp, "gbif.RData", eligible_lists$current_eligible_list)),
  # tar_target(gbif_spatial_eligible, build_spatial_eligible_and_unit(gbif_spatial_data, nnfg_fs_ownership, eligible_lists$current_eligible_list)),
  # tar_target(imbcr_spatial_data, build_imbcr_spatial_data(t_path_sp_list_rp, "imbcr.RData")),
  # tar_target(imbcr_spatial_eligible, build_spatial_eligible_and_unit(imbcr_spatial_data, nnfg_fs_ownership, eligible_lists$current_eligible_list)),
  # tar_target(output_eligible_idb_spatial_data, output_eligible_spatial_data(idb_spatial_eligible, file.path(t_path_sp_list, "shapefiles"), "idb")),
  # tar_target(output_eligible_seinet_spatial_data, output_eligible_spatial_data(seinet_spatial_eligible, file.path(t_path_sp_list, "shapefiles"), "seinet")),
  # tar_target(output_eligible_gbif_spatial_data, output_eligible_spatial_data(gbif_spatial_eligible, file.path(t_path_sp_list, "shapefiles"), "gbif")),
  # tar_target(output_eligible_imbcr_spatial_data, output_eligible_spatial_data(imbcr_spatial_eligible, file.path(t_path_sp_list, "shapefiles"), "imbcr")),
  #
  # ### IUCN available spatial data analysis and make internal shapes
  # tar_target(mammal_iucn_map_list, build_iucn_available_maps(file.path(external_data_folder, "IUCN", "MAMMALS.shp"), eligible_lists, nnfg_bd)),
  # tar_target(amphibian1_iucn_map_list, build_iucn_available_maps(file.path(external_data_folder, "IUCN", "AMPHIBIANS_PART1.shp"), eligible_lists, nnfg_bd)),
  # tar_target(amphibian2_iucn_map_list, build_iucn_available_maps(file.path(external_data_folder, "IUCN", "AMPHIBIANS_PART2.shp"), eligible_lists, nnfg_bd)),
  # tar_target(reptiles1_iucn_map_list, build_iucn_available_maps(file.path(external_data_folder, "IUCN", "REPTILES_PART1.shp"), eligible_lists, nnfg_bd)),
  # tar_target(reptiles2_iucn_map_list, build_iucn_available_maps(file.path(external_data_folder, "IUCN", "REPTILES_PART2.shp"), eligible_lists, nnfg_bd)),
  # tar_target(all_iucn_map, build_all_iucn_map(mammal_iucn_map_list, amphibian2_iucn_map_list, amphibian1_iucn_map_list, reptiles1_iucn_map_list, reptiles2_iucn_map_list)),
  # # tar_target(summary_sheet, build_summary_sheet(summary_sheet_file))
  #
  # ## Imbcr data cleaning and build narratives
  # tar_target(imbcr_trend, read_excel("T:\\FS\\NFS\\PSO\\MPSG\\Data\\ExternalData\\2023_IMBCR_USFSdata\\Reg 2 grasslands estimates_8-8-24.xlsx", sheet = "trend") |> clean_names()),
  # tar_target(imbcr_trend_bcr18, read_excel("T:\\FS\\NFS\\PSO\\MPSG\\Data\\ExternalData\\2023_IMBCR_USFSdata\\IMBCR BCR18 trends.xlsx") |> clean_names()),
  # tar_target(imbcr_trend_narratives, build_imbcr_trend_narratives(imbcr_trend, imbcr_trend_bcr18)),
  # tar_target(imbcr_trend_narratives_w_taxonomy, build_imbcr_taxonomy(imbcr_trend_narratives)),
  #
  # tar_quarto(reports, "qmd/")
)
