library(targets)
library(openxlsx)
library(tidyverse)
library(sf)
library(readxl)

fp <- file.path(tar_read(sp_fp), "Species List", fsep = "\\")
xl_fp <- list.files(fp, pattern = "OPEN_TO_EDITING", full.names = T)
xl_el_fp <- list.files(fp, pattern = "DO_NOT_EDIT", full.names = T)

el_list_raw <- tar_read(eligible_lists)$current_eligible_list
el_list_old_raw <- read_excel(xl_el_fp, sheet = 1)

el_list <- el_list_raw |>
  filter(!str_detect(usfws_status, "Threatened|Endangered") | is.na(usfws_status)) |>
  rowwise() |>
  mutate(
    max_overall_year = max(c_across(contains("maxYear")), na.rm = T)
  ) |>
  ungroup() |>
  select(
    taxon_id,
    scientific_name,
    common_name,
    kingdom:genus,
    "NatServ Global Rank" = rounded_gRank,
    "NE State Rank" = NE_sRank,
    "SD State Rank" = SD_sRank,
    "FWS ESA Status" = usfws_status,
    "Region 2 Sensitive Species Status" = r2_ss_list,
    "SD State Status" = sd_te,
    "NE State Status" = nebraska_swap,
    "Total Obs all Occurrence DBs" = sum_nObs,
    max_overall_year
  )

tb_df <- read_excel(xl_fp, sheet = "Transient_Bird_Analysis") |>
  mutate(
    final_determination = ifelse(specialist_overide == "No Change", should_remain_eligible, specialist_overide),
    at_det = ifelse(final_determination, "No", "Yes")
  ) |>
  select(taxon_id, "Is the species an accidental or transient bird species?" = at_det)

raw_nn_df <- read_excel(xl_fp, sheet = "Native_Known_Verify")

nn_df <- raw_nn_df |>
  mutate(max_overall_year_fixed = ifelse(is.na(specialist_verified_max_year), max_overall_year, specialist_verified_max_year)) |>
  select(taxon_id, specialist_verified_max_year, `Is the Species Native and Known to Occur`, basi_rat = 28)

rainbow_sheet <- el_list |>
  left_join(tb_df, by = "taxon_id") |>
  left_join(nn_df, by = "taxon_id") |>
  mutate(
    max_overall_year = ifelse(is.na(specialist_verified_max_year), max_overall_year, specialist_verified_max_year),
    `Is the Species Native and Known to Occur` = case_when(
      is.na(`Is the Species Native and Known to Occur`) ~ "Yes",
      TRUE ~ `Is the Species Native and Known to Occur`
    )
  ) |>
  select(
    -specialist_verified_max_year
  ) |>
  rename(
    "Most Recent Occurrence Record" = max_overall_year,
    "What is the rationale and supporting BASI for recommending that an observation does not meet the requirements of native to, and known to occur in the plan area?" = basi_rat
  )
el_t_ids <- el_list |>
  select(taxon_id)

within_buff <- el_list_old_raw |>
  filter(!str_detect(usfws_status, "Threatened|Endangered") | is.na(usfws_status)) |>
  rowwise() |>
  mutate(
    max_overall_year = max(c_across(contains("maxYear")), na.rm = T)
  ) |>
  ungroup() |>
  anti_join(el_t_ids, by = "taxon_id") |>
  select(
    taxon_id,
    scientific_name,
    common_name,
    kingdom:genus,
    "NatServ Global Rank" = rounded_gRank,
    "NE State Rank" = NE_sRank,
    "SD State Rank" = SD_sRank,
    "FWS ESA Status" = usfws_status,
    "Region 2 Sensitive Species Status" = r2_ss_list,
    "SD State Status" = sd_te,
    "NE State Status" = nebraska_swap
  )


wb <- createWorkbook()

addWorksheet(wb, "SCC Eligible Matrix")
writeDataTable(wb, "SCC Eligible Matrix", rainbow_sheet, tableStyle = "TableStyleLight1")

addWorksheet(wb, "Non Known - within 1km")
writeDataTable(wb, "Non Known - within 1km", within_buff, tableStyle = "TableStyleLight1")

saveWorkbook(wb, file.path(fp, paste(str_replace_all(Sys.Date(), "-", ""), "NNFG_SCC_Matrix.xlsx", sep = "_")), overwrite = T)
