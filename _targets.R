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
    "natserv"
  )
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
list(
  tar_target(naturserve_state_data, get_natureserve_state_data()),
  tar_target(output_natureserve_state_data, build_output_natureserve_state_data(naturserve_state_data, "T:\\FS\\NFS\\PSO\\MPSG\\Data\\ExternalData\\NatureServe", "NNFG_natureserve_state_data")),
  tar_target(nnfg_gdb, "T:/FS/NFS/PSO/MPSG/2024_NebraskaNFG/1_PreAssessment/Data/NNFG_BaseData.gdb"),
  tar_target(nnfg_bd, st_read(nnfg_gdb, "NNFG_AdminBdy")),
  tar_target(nnfg_crs, st_crs(nnfg_bd)),
  tar_target(nnfg_aoa, st_read(nnfg_gdb, "NNFG_AOA")),
  tar_target(nnfg_ownership, st_read(nnfg_gdb, "NNFG_BasicOwnership")),
  tar_target(nnfg_fs_ownership, nnfg_ownership |> filter(OWNERCLASSIFICATION == "USDA FOREST SERVICE")),
  tar_target(summary_sheet_file, "T:\\FS\\NFS\\PSO\\MPSG\\2024_NebraskaNFG\\1_PreAssessment\\Projects\\SpeciesList_NNFG\\20240429_NNFG_SpeciesList.xlsx"),
  tar_target(sd_nhp_data, build_nhp_data("T:/FS/NFS/PSO/MPSG/Data/ExternalData/SD_NHP/20240123_SD_Natural_HeritagePrgm.gdb", "Natural_Heritage_Data_Restricted_Region2_FS_2024_01", nnfg_crs, nnfg_fs_ownership)),
  tar_target(summary_sheet, build_summary_sheet(summary_sheet_file)),
  tar_target(imbcr_trend, build_imbcr_trend("data\\2022 IMBCR.Trend.Estimates--all.states.csv"))
  # tar_quarto(reports, "qmd/")
)
