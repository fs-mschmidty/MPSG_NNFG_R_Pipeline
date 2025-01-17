# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) # This package is where tar_quarto is found.

# Set target options:
tar_option_set(
  packages = c(
    "taxize",
    "tidyverse",
    "quarto",
    "sf",
    "readxl",
    "mpsgSE",
    "janitor",
    "httr2",
    "natserv",
    "openxlsx",
    "glue",
    "ebirdst",
    "fs",
    "rnaturalearth",
    "rgbif",
    "osmdata",
    "arcgislayers",
    # "sjnftools", ## Updated to mpsgSE package but need to get it loaded first.
    "scales"
  )
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

t_path_sp_list <- file.path("T:/FS/NFS/PSO/MPSG/2024_NebraskaNFG", "1_PreAssessment/Projects/SpeciesList_NNFG")
t_path_sp_list_rp <- file.path(t_path_sp_list, "reproduce_NNFG")
species_list_sp <- file.path(Sys.getenv("USERPROFILE"), "USDA", "Mountain Planning Service Group - SCC Library", "03_Nebraska NFG", "Species List", fsep = "\\")
iucn_path <- file.path("D:/MPSG/IUCN")

# Replace the target list below with your own:
list(
  ## Unit Spatial Data
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
  ## I think the sd_nhp_data target is unused.
  tar_target(sd_nhp_data, build_nhp_data("T:/FS/NFS/PSO/MPSG/Data/ExternalData/SD_NHP/20240123_SD_Natural_HeritagePrgm.gdb", "Natural_Heritage_Data_Restricted_Region2_FS_2024_01", nnfg_crs, nnfg_fs_ownership)),
  tar_target(ne_state_list, build_ne_state_list("T:\\FS\\NFS\\PSO\\MPSG\\2024_NebraskaNFG\\1_PreAssessment\\Projects\\SpeciesList_NNFG\\data\\state_lists\\nebraska\\Tier 1 and Tier 2 Species by Taxa plus Ranks_recieved_08262024.xlsx")),
  tar_target(sd_state_list, build_sd_state_list("T:\\FS\\NFS\\PSO\\MPSG\\2024_NebraskaNFG\\1_PreAssessment\\Projects\\SpeciesList_NNFG\\data\\state_lists\\south_dakota\\draft_SGCN_list_for_comment_July_2024.xlsx")),
  tar_target(r2_ss_list, build_r2_ss_list("data/fs/2023_R2_RegionalForestersSensitiveSppList.xlsx")),
  tar_target(sp_unit_concern, build_sp_unit_concern(file.path(species_list_sp, "20240916_NNFG_SCC_Evaluation_Matrix.xlsx"), "Species to Add as Local Concern")),

  ### Build Eligible list
  tar_target(eligible_lists, build_eligible_list(natureserve_state_data, t_drive_lists, ne_state_list, sd_state_list, r2_ss_list)),
  tar_target(transient_birds, build_transient_birds(eligible_lists, nnfg_aoa)),
  tar_target(native_known_need_check, build_native_known_need_check(eligible_lists)),
  tar_target(input_round1_file, file.path(species_list_sp, "OPEN_TO_EDITING_20240909_NNFG_Species_List_Edit_Tables.xlsx"), format = "file"),
  tar_target(team_inputs_round1, build_team_inputs_nn_and_tax(input_round1_file)),
  # tar_target(output_eligible_lists, build_output_eligible_lists(eligible_lists, "output", transient_birds, native_known_need_check)),
  tar_target(output_dne_eligible_lists, build_output_dne_eligible_lists(eligible_lists, "output", t_path_sp_list, species_list_sp, team_inputs_round1, sp_unit_concern)),
  ## ADD STEP TO IMPORT SPECIES OF LOCAL CONCERN
  tar_target(eligible_synonyms, build_eligible_synonyms(output_dne_eligible_lists)),
  ## tar_target(taxonomy_itis_verify, build_taxonomy_itis_verify(output_dne_eligible_lists)),

  # Spatial data
  ## Occurrence Lists
  # UPDATE ALL eligible_lists$current_eligible to output_dne_eligible_lists
  tar_target(nhp_spatial_data, build_nhp_spatial_data(t_path_sp_list_rp, "state_nhp.RData")),
  tar_target(sd_nhp_spatial_eligible, build_spatial_eligible_and_unit(nhp_spatial_data$sdnhp, nnfg_fs_ownership, output_dne_eligible_lists)),
  tar_target(ne_nhp_spatial_eligible, build_spatial_eligible_and_unit(nhp_spatial_data$nenhp, nnfg_fs_ownership, output_dne_eligible_lists)),
  tar_target(idb_spatial_data, build_idb_spatial_data(t_path_sp_list_rp, "idigbio.RData")),
  tar_target(idb_spatial_eligible, build_spatial_eligible_and_unit(idb_spatial_data, nnfg_fs_ownership, output_dne_eligible_lists)),
  tar_target(seinet_spatial_data, build_seinet_spatial_data(t_path_sp_list_rp, "seinet.RData")),
  tar_target(seinet_spatial_eligible, build_spatial_eligible_and_unit(seinet_spatial_data, nnfg_fs_ownership, output_dne_eligible_lists)),
  tar_target(gbif_spatial_data, build_gbif_spatial_data(t_path_sp_list_rp, "gbif.RData", output_dne_eligible_lists)),
  tar_target(gbif_spatial_eligible, build_spatial_eligible_and_unit(gbif_spatial_data, nnfg_fs_ownership, output_dne_eligible_lists)),
  tar_target(imbcr_spatial_data, build_imbcr_spatial_data(t_path_sp_list_rp, "imbcr.RData")),
  tar_target(imbcr_spatial_eligible, build_spatial_eligible_and_unit(imbcr_spatial_data, nnfg_fs_ownership, output_dne_eligible_lists)),
  tar_target(output_eligible_idb_spatial_data, output_eligible_spatial_data(idb_spatial_eligible, file.path(t_path_sp_list, "shapefiles"), "idb")),
  tar_target(output_eligible_seinet_spatial_data, output_eligible_spatial_data(seinet_spatial_eligible, file.path(t_path_sp_list, "shapefiles"), "seinet")),
  tar_target(output_eligible_gbif_spatial_data, output_eligible_spatial_data(gbif_spatial_eligible, file.path(t_path_sp_list, "shapefiles"), "gbif")),
  tar_target(output_eligible_imbcr_spatial_data, output_eligible_spatial_data(imbcr_spatial_eligible, file.path(t_path_sp_list, "shapefiles"), "imbcr")),
  tar_target(output_eligible_sd_nhp_spatial_data, output_eligible_spatial_data(sd_nhp_spatial_eligible, file.path(t_path_sp_list, "shapefiles"), "sd_nhp")),
  tar_target(output_eligible_ne_nhp_spatial_data, output_eligible_spatial_data(ne_nhp_spatial_eligible, file.path(t_path_sp_list, "shapefiles"), "ne_nhp")),
  tar_target(all_eligible_spatial_data_poly, build_all_occ_data(list(sd_nhp_spatial_eligible, ne_nhp_spatial_eligible)) |> buffer_small_polygons(min_size = 10000000)),
  tar_target(all_eligible_spatial_data_point, build_all_occ_data(list(idb_spatial_eligible, seinet_spatial_eligible, gbif_spatial_eligible, imbcr_spatial_eligible))),

  ### IUCN available spatial data analysis and make internal shapes (THIS SUCKS)
  # Move these files off TDrvie
  tar_target(mammal_iucn_map_list, build_iucn_available_maps(file.path(iucn_path, "MAMMALS.shp"), output_dne_eligible_lists, nnfg_bd)),
  tar_target(amphibian1_iucn_map_list, build_iucn_available_maps(file.path(iucn_path, "AMPHIBIANS_PART1.shp"), output_dne_eligible_lists, nnfg_bd)),
  tar_target(amphibian2_iucn_map_list, build_iucn_available_maps(file.path(iucn_path, "AMPHIBIANS_PART2.shp"), output_dne_eligible_lists, nnfg_bd)),
  tar_target(reptiles1_iucn_map_list, build_iucn_available_maps(file.path(iucn_path, "REPTILES_PART1.shp"), output_dne_eligible_lists, nnfg_bd)),
  tar_target(reptiles2_iucn_map_list, build_iucn_available_maps(file.path(iucn_path, "REPTILES_PART2.shp"), output_dne_eligible_lists, nnfg_bd)),
  tar_target(fwfish1_iucn_map_list, build_iucn_available_maps(file.path(iucn_path, "FW_FISH_PART1.shp"), output_dne_eligible_lists, nnfg_bd)),
  tar_target(fwfish2_iucn_map_list, build_iucn_available_maps(file.path(iucn_path, "FW_FISH_PART2.shp"), output_dne_eligible_lists, nnfg_bd)),
  tar_target(molluscs_iucn_map_list, build_iucn_available_maps(file.path(iucn_path, "FW_MOLLUSCS.shp"), output_dne_eligible_lists, nnfg_bd)),
  tar_target(odonata_iucn_map_list, build_iucn_available_maps(file.path(iucn_path, "FW_ODONATA.shp"), output_dne_eligible_lists, nnfg_bd)),
  tar_target(crayfish_iucn_map_list, build_iucn_available_maps(file.path(iucn_path, "FW_CRAYFISH.shp"), output_dne_eligible_lists, nnfg_bd)),
  tar_target(all_iucn_map, build_all_iucn_map(
    mammal_iucn_map_list,
    amphibian2_iucn_map_list,
    reptiles1_iucn_map_list,
    reptiles2_iucn_map_list,
    fwfish1_iucn_map_list,
    fwfish2_iucn_map_list
  )),

  ### Bien (see non_target_r/test_rbien.R) maps and bird_maps (see non_target_r/ebirdst_download.R) were retrieved with a non_target process!!
  # UPDATE ALL eligible_lists$current_eligible to output_dne_eligible_lists
  tar_target(bien_plant_maps, load_bien_plant_maps("output/bien_test/1", output_dne_eligible_lists)),
  tar_target(bird_maps, load_bird_maps(output_dne_eligible_lists, path = "output/ebirdst")),
  tar_target(map_source, build_map_source(output_dne_eligible_lists, all_iucn_map, bien_plant_maps, bird_maps)),
  # tar_target(gbif_occ_data, get_gbif_occ_data(output_dne_eligible_lists, map_source)), ## This takes a long long time so if anything upstream changes this will run and take forever.
  # tar_target(write_iucn_maps, output_spatial_data(all_iucn_map, file.path(t_path_sp_list, "shapefiles"), "nnfg_iucn_range_maps")),
  # tar_target(write_bien_maps, output_spatial_data(bien_plant_maps, file.path(t_path_sp_list, "shapefiles"), "nnfg_bien_range_maps")),
  # tar_target(write_ebird_maps, output_spatial_data(bird_maps, file.path(t_path_sp_list, "shapefiles"), "nnfg_bird_range_maps")),
  # tar_target(write_gbif_maps, output_spatial_data(select(gbif_occ_data, scientificName, taxon_id), file.path(t_path_sp_list, "shapefiles"), "nnfg_gbif_range_maps")),


  ## Get map background data for species evaluations
  tar_target(evaluation_base_mfp_data, get_evaluation_base_map_data(nnfg_aoa)),

  ## Habitat Association Work
  tar_target(ns_habitats, get_ns_habitat(natureserve_state_data$unit_nature_serve_list, output_dne_eligible_lists)),
  tar_target(crosswalk_habitats_to_species, build_species_habitats(ns_habitats, "data/habitat_binning_mpsg_bins.xlsx")),

  # ## Imbcr data cleaning and build narratives
  ## Change Citation Brakets from {} to []
  tar_target(imbcr_trend, readxl::read_excel("data/imbcr/Reg_2_grasslands_estimates_9-17-24.xlsx", sheet = "trend") |> clean_names()),
  tar_target(imbcr_trend_narratives, build_imbcr_trend_narratives(imbcr_trend)),
  tar_target(bbs_trend_narratives, build_bbs_trend_narratives()),

  ## Range Determinations
  tar_target(range_edge_xlsx, file.path("output", "manual_range_edge_binning.xlsx"), format = "file"),
  tar_target(range_edge, read_excel(range_edge_xlsx, sheet = "bins")),

  ### Add in species of local concern to output_dne_eligible_lists and feed to build_quarto_params.  Need to both add column for species of local concern and make native and known == "Yes"

  ## Quarto Paramaterized reporting.
  tar_target(qmd_params, build_quarto_params(output_dne_eligible_lists, "output/species_evaluations"))
  # tar_quarto(test, "qmd/species_evaluation.qmd", debug = T, quiet = F)
  # tar_quarto(test, "qmd/species_evaluation.qmd")
  # tar_quarto_rep(param_reports, "qmd/species_evaluation.qmd", rep_workers = 4, execute_params = qmd_params)
  # tar_quarto_rep(param_reports, "qmd/species_evaluation.qmd", rep_workers = 4, execute_params = qmd_params, debug = T, quiet = F)
  # tar_quarto_rep(param_reports, "qmd/species_evaluation.qmd", rep_workers = 4, execute_params = sample_n(qmd_params, 15), debug = T, quiet = F),
  # tar_quarto_rep(param_reports, "qmd/species_evaluation.qmd", rep_workers = 4, execute_params = slice(qmd_params, c(70:n())), debug = T)
)
