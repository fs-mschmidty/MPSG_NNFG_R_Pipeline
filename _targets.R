# Created by use_targets().
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
    "glue"
  )
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
list(
  tar_target(natureserve_state_data, get_natureserve_state_data()),
  tar_target(output_natureserve_state_data, build_output_natureserve_state_data(natureserve_state_data, "T:\\FS\\NFS\\PSO\\MPSG\\Data\\ExternalData\\NatureServe", "NNFG_natureserve_state_data")),
  tar_target(nnfg_gdb, "T:/FS/NFS/PSO/MPSG/2024_NebraskaNFG/1_PreAssessment/Data/NNFG_BaseData.gdb"),
  tar_target(nnfg_bd, st_read(nnfg_gdb, "NNFG_AdminBdy")),
  tar_target(nnfg_crs, st_crs(nnfg_bd)),
  tar_target(nnfg_aoa, st_read(nnfg_gdb, "NNFG_AOA")),
  tar_target(nnfg_ownership, st_read(nnfg_gdb, "NNFG_BasicOwnership")),
  tar_target(nnfg_fs_ownership, nnfg_ownership |> filter(OWNERCLASSIFICATION == "USDA FOREST SERVICE")),

  ## Imbcr data cleaning and build narratives
  tar_target(imbcr_trend, read_excel("T:\\FS\\NFS\\PSO\\MPSG\\Data\\ExternalData\\2023_IMBCR_USFSdata\\Reg 2 grasslands estimates_8-8-24.xlsx", sheet = "trend") |> clean_names()),
  tar_target(imbcr_trend_bcr18, read_excel("T:\\FS\\NFS\\PSO\\MPSG\\Data\\ExternalData\\2023_IMBCR_USFSdata\\IMBCR BCR18 trends.xlsx") |> clean_names()),
  tar_target(imbcr_trend_narratives, build_imbcr_trend_narratives(imbcr_trend, imbcr_trend_bcr18)),
  tar_target(imbcr_trend_narratives_w_taxonomy, build_imbcr_taxonomy(imbcr_trend_narratives)),

  ## Build Occurrence Lists for eligible list
  tar_target(t_drive_lists, build_t_drive_lists(file.path("T:/FS/NFS/PSO/MPSG/2024_NebraskaNFG/1_PreAssessment", "Projects/SpeciesList_NNFG", "reproduce"))),
  tar_target(sd_nhp_data, build_nhp_data("T:/FS/NFS/PSO/MPSG/Data/ExternalData/SD_NHP/20240123_SD_Natural_HeritagePrgm.gdb", "Natural_Heritage_Data_Restricted_Region2_FS_2024_01", nnfg_crs, nnfg_fs_ownership)),
  tar_target(ne_state_list, build_ne_state_list("T:\\FS\\NFS\\PSO\\MPSG\\2024_NebraskaNFG\\1_PreAssessment\\Projects\\SpeciesList_NNFG\\data\\state_lists\\nebraska\\Tier 1 and Tier 2 Species by Taxa plus Ranks_recieved_08262024.xlsx")),
  tar_target(sd_state_list, build_sd_state_list("T:\\FS\\NFS\\PSO\\MPSG\\2024_NebraskaNFG\\1_PreAssessment\\Projects\\SpeciesList_NNFG\\data\\state_lists\\south_dakota\\draft_SGCN_list_for_comment_July_2024.xlsx")),
  tar_target(r2_ss_list, build_r2_ss_list("data/fs/2023_R2_RegionalForestersSensitiveSppList.xlsx")),
  tar_target(eligible_lists, build_eligible_list(natureserve_state_data, t_drive_lists, ne_state_list, sd_state_list, r2_ss_list)),
  tar_target(output_eligible_lists, build_output_eligible_lists(eligible_lists, "output"))
  # tar_target(summary_sheet, build_summary_sheet(summary_sheet_file))

  # tar_quarto(reports, "qmd/")
)
