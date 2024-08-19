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
    "janitor"
  )
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
list(
  tar_target(summary_sheet_file, "T:\\FS\\NFS\\PSO\\MPSG\\2024_NebraskaNFG\\1_PreAssessment\\Projects\\SpeciesList_NNFG\\20240429_NNFG_SpeciesList.xlsx"),
  tar_target(summary_sheet, build_summary_sheet(summary_sheet_file)),
  tar_target(nnfg_bd, st_read("T:\\FS\\NFS\\PSO\\MPSG\\2024_NebraskaNFG\\1_PreAssessment\\Data\\Shapefiles\\NebraskaGrasslands_Bdy.shp")),
  tar_target(imbcr_trend, build_imbcr_trend("data\\2022 IMBCR.Trend.Estimates--all.states.csv"))
  # tar_quarto(reports, "qmd/")
)
