library(taxize)
library(tidyverse)
library(targets)
library(rgbif)

el_list <- tar_read(eligible_lists)$current_eligible_list

scientific_names <- el_list |>
  pull(scientific_name)

sci_name <- str_replace(scientific_names[230], "ssp.", "")

t_id <- el_list |>
  filter(scientific_name == sci_name) |>
  pull(taxon_id)

synonyms <- name_lookup(sci_name)$data

x <- name_backbone(name = sci_name)
syns <- name_usage(key = t_id, data = "synonyms")
names <- syns$data |>
  pull(canonicalName)

names <- synonyms |>
  select(canonicalName, rank) |>
  filter(taxonomicStatus == "SYNONYM") |>
  filter(rank %in% c("SUBSPEPCIES", "VARIETY", "SPECIES", "FORM")) |>
  count(canonicalName) |>
  pull(canonicalName)

tibble(synonyms = names) |>
  mutate(scientific_name = sci_name, taxon_id = t_id)
s2 <- synonyms(sci_name, db = "pow")
