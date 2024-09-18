library(tidyverse)
library(glue)
library(targets)
library(httr2)

tar_read(output_dne_eligible_lists)

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

habitatComments <- root_of_chars$habitatComments

all_hab_names <- c(
  "terrestrial",
  "marine",
  "riverine",
  "palustrine",
  "lacustrine",
  "subterrainean",
  "estuarine"
)


hab_list <- root_of_chars[glue("species{str_to_title(all_hab_names[1])}Habitats")]

hab_list[[1]] |>
  lapply(function(x) print(x[2][[1]][[2]]))


el_list <- tar_read(output_dne_eligible_lists)

el_t_ids <- el_list |>
  filter(`Is the Species Native and Known to Occur` %in% c("Yes", "?")) |>
  pull(scientific_name)



ns_el_data <- tar_read(natureserve_state_data)$unit_nature_serve_list |>
  filter(scientific_name %in% el_t_ids) |>
  mutate(api_shortcode = str_extract(view_on_nature_serve_explorer, "ELEMENT_GLOBAL\\.\\d+\\.\\d+")) |>
  mutate(ns_taxon_api_url = glue("https://explorer.natureserve.org/api/data/taxon/{api_shortcode}")) |>
  distinct() |>
  group_by(taxon_id) |>
  mutate(n = n()) |>
  ungroup() |>
  filter(n == 1)

t_id <- ns_el_data |>
  sample_n(1) |>
  pull(taxon_id)

sp_data <- ns_el_data |>
  filter(taxon_id == t_id)

test_url <- sp_data$ns_taxon_api_url

root_of_chars <- resp$speciesCharacteristics

habitatComments <- root_of_chars$habitatComments

all_hab_names <- c(
  "terrestrial",
  "marine",
  "riverine",
  "palustrine",
  "lacustrine",
  "subterrainean",
  "estuarine"
)

hab_type <- all_hab_names[1]


ns_hab_type <- hab_list[[1]][[1]][2][[1]][[2]]

tibble(
  taxon_id = t_id,
  hab_cat = hab_type,
  ns_hab = ns_hab_type
)



natureserv_get_hab_data <- function(x) {
  req <- request(x)

  resp <- req_perform(req) |>
    resp_body_json()

  all_hab_names <- c(
    "terrestrial",
    "marine",
    "riverine",
    "palustrine",
    "lacustrine",
    "subterrainean",
    "estuarine"
  )

  root_of_chars <- resp$speciesCharacteristics

  habitatComments <- root_of_chars$habitatComments

  hab_df <- tibble(
    hab_cat = c("comments"),
    ns_hab = habitatComments
  )

  return_habs_from_hab_cat <- function(x) {
    tibble(
      hab_cat = hab_type,
      ns_hab = x[2][[1]][[2]]
    )
  }


  get_all_habs <- function(x, ls_json) {
    hab_type <- x
    hab_list <- ls_json[glue("species{str_to_title(hab_type)}Habitats")]

    hab_list[[1]] |>
      lapply(return_habs_from_hab_cat) |>
      bind_rows()
  }

  lapply(all_hab_names, get_all_habs, root_of_chars) |>
    bind_rows() |>
    bind_rows(hab_df)
}


natureserv_get_hab_data(sp_data$ns_taxon_api_url)

get_all_ns_data <- function(t_id, list) {
  sp_data <- list |>
    filter(taxon_id == t_id)
  print(sp_data$scientific_name)

  natureserv_get_hab_data(as.character(sp_data$ns_taxon_api_url)) |>
    mutate(taxon_id = t_id)
}

test <- ns_el_data |>
  pull(taxon_id) |>
  lapply(get_all_ns_data, ns_el_data) |>
  bind_rows()

test |>
  filter(hab_cat != "comments") |>
  count(hab_cat)

taxon_ids_with_hab_data <- test |>
  filter(hab_cat != "comments") |>
  count(taxon_id) |>
  mutate(has_habitat_data_ns = "Yes")

ns_el_data |>
  left_join(taxon_ids_with_hab_data, by = "taxon_id") |>
  count(kingdom, has_habitat_data_ns) |>
  group_by(kingdom) |>
  mutate(prop = n / sum(n))

ns_el_data |>
  filter(is.vector(as.character(ns_taxon_api_url)))
pull(ns_taxon_api_url) |>
  View()

tar_read(ns_habitats) |>
  filter(hab_cat != "comments") |>
  count(hab_cat, ns_hab) |>
  rename(number_of_species_in_cat = n) |>
  mutate(mpsg_habitat_bin = "") |>
  write_csv("output/habitat_binning.csv")


library(httr2)
library(glue)
library(tidyverse)

ns_api_url <- "https://explorer.natureserve.org/api/data/taxon/ELEMENT_GLOBAL.2.103684"

natureserv_get_hab_data <- function(x) {
  req <- request(x)

  resp <- req_perform(req) |>
    resp_body_json()

  all_hab_names <- c(
    "terrestrial",
    "marine",
    "riverine",
    "palustrine",
    "lacustrine",
    "subterrainean",
    "estuarine"
  )

  root_of_chars <- resp$speciesCharacteristics

  habitatComments <- root_of_chars$habitatComments

  hab_df <- tibble(
    hab_cat = c("comments"),
    ns_hab = habitatComments
  )

  return_habs_from_hab_cat <- function(x, h_t) {
    tibble(
      hab_cat = h_t,
      ns_hab = x[2][[1]][[2]]
    )
  }


  get_all_habs <- function(x, ls_json) {
    hab_type <- x
    hab_list <- ls_json[glue("species{str_to_title(hab_type)}Habitats")]

    hab_list[[1]] |>
      lapply(return_habs_from_hab_cat, hab_type) |>
      bind_rows()
  }

  lapply(all_hab_names, get_all_habs, root_of_chars) |>
    bind_rows() |>
    bind_rows(hab_df)
}

natureserv_get_hab_data(ns_api_url)
