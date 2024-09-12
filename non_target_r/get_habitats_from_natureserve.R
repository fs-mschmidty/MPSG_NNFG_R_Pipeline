library(tidyverse)
library(glue)
library(targets)
library(httr2)

tar_read(natureserve_state_data)$unit_nature_serve_list |>
  head(20) |>
  pull(view_on_nature_serve_explorer) |>
  str_extract("ELEMENT_GLOBAL\\.\\d+\\.\\d+")


ns_element_code_ex <- tar_read(natureserve_state_data)$unit_nature_serve_list |>
  mutate(ns_element_code = str_extract(view_on_nature_serve_explorer, "ELEMENT_GLOBAL\\.\\d+\\.\\d+")) |>
  select(scientific_name, ns_element_code)

eligible <- tar_read(eligible_lists)$current_eligible_list |>
  select(taxon_id, scientific_name) |>
  left_join(ns_element_code_ex, by = "scientific_name") |>
  distinct() |>
  mutate(ns_taxon_api_url = glue("https://explorer.natureserve.org/api/data/taxon/{ns_element_code}"))

x <- sample_n(eligible, 1)
x_ec <- x |>
  pull(ns_taxon_api_url)


req <- request(x_ec)

resp <- req_perform(req) |>
  resp_body_json()

resp$speciesCharacteristics$speciesTerrestrialHabitats |>
  lapply(function(x) print(x$terrestrialHabitat$terrestrialHabitatDescEn))

root_of_chars <- resp$speciesCharacteristics

all_hab_names <- c(
  "terrestrial",
  "marine",
  "riverine",
  "palustrine",
  "lacustrine",
  "subterrainean",
  "estuarine"
)

ter_habs <- root_of_chars[glue("species{str_to_title(all_hab_names[1])}Habitats")]

ter_habs[[1]] |>
  lapply(function(x) print(x[2][[1]][[2]]))


test <- ter_habs[[1]][[1]][glue("{all_hab_names[1]}Habitat")]

test$terrestrialHabitat$terrestrialHabitatDescEn
test[[1]][[2]]

lapply(ter_habs, function(x) print(x))

lapply(ter_habs, function(x) print(x[glue("{all_hab_names[1]}Habitat")][glue("{all_hab_names[1]}HabitatDescEn")]))
