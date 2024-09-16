library(targets)
library(tidyverse)
library(readxl)
library(writexlsx)

t_path_sp_list <- file.path("T:/FS/NFS/PSO/MPSG/2024_NebraskaNFG", "1_PreAssessment/Projects/SpeciesList_NNFG")
t_path_sp_list_rp <- file.path(t_path_sp_list, "reproduce")
species_list_sp <- file.path(Sys.getenv("USERPROFILE"), "USDA", "Mountain Planning Service Group - SCC Library", "03_Nebraska NFG", "Species List", fsep = "\\")


eligible<-tar_read(eligible_lists)$current_eligible_list

xl_fp<-list.files(species_list_sp, pattern="OPEN_TO_EDITING", full.names=T)

taxonomies<-read_excel(xl_fp, sheet=1) |>
  filter(needs_overview)

n_and_known<-read_excel(xl_fp, sheet = 5) |>
  select(taxon_id, `Is the Species Native and Known to Occur`,`What is the rationale and supporting BASI for recommending that an observation does not meet the requirements of native to, and known to occur in the plan area?`)

eligible |>
  
