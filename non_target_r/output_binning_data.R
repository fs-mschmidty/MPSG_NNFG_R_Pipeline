library(tidyverse)
library(sf)
library(targets)
library(openxlsx)

map_source <- tar_read(map_source) |>
  select(taxon_id, source) |>
  distinct()

eligible_range_species <- tar_read(output_dne_eligible_lists) |>
  left_join(map_source, by = "taxon_id") |>
  select(taxon_id:common_name, source, usfws_status, kingdom:family, `Is the Species Native and Known to Occur`) |>
  mutate(edge_of_range_bin = NA)

wb <- createWorkbook()

addWorksheet(wb = wb, "bins")
writeDataTable(x = eligible_range_species, wb = wb, sheet = "bins", tableStyle = "TableStyleLight1")

saveWorkbook(wb, file = "output/manual_range_edge_binning.xlsx", overwrite = T)
