library("BIEN")
library(ggtext)
library("tidyverse")
library("sf")
library(targets)
library(glue)
library(rnaturalearth)
library(extrafont)
library(MetBrewer)

curr_list <- tar_read(eligible_lists)$current_eligible_list

plants_eligible <- curr_list |>
  filter(kingdom == "Plantae")


test_plant <- plants_eligible |>
  sample_n(1) |>
  pull(scientific_name)

test_range <- BIEN_ranges_species(test_plant, directory = "output/bien_test")

t_sf<-st_read(glue("output/bien_test/{str_replace(test_plant, ' ', '_')}.shp"))

states <- ne_states(country = c("United States of America", "Canada", "Mexico")) |>
  st_as_sf() |>
  filter(name != "Hawaii") |>
  st_transform(crs = 5070)

test_cr <- t_sf |>
  st_transform(crs = st_crs(states)) |>
  st_intersection(st_union(states))

admin_body <- tar_read(nnfg_bd) |>
  st_transform(crs = st_crs(states))

title <- glue("North American Distribution of {test_plant}")

## Map for birds
ggplot() +
  theme_void(base_family = "Roboto Condensed") +
  geom_sf(data = states) +
  geom_sf(data = test_cr, color = "transparent", fill = met.brewer("Lakota", 1)) +
  geom_sf(data = admin_body, fill = "transparent", color = "black") +
  labs(
    title = title,
    fill = "**Legend**"
  ) +
  theme(
    plot.title = element_markdown(face = "bold", hjust = 0, margin = margin(0, 0, 5, 0, "pt")),
    plot.margin = margin(t = 20, r = 20, b = 20, l = 20, "pt"),
    legend.title = element_markdown(),
    legend.position = "inside",
    legend.position.inside = c(0.15, 0.1)
  )

plants_all<-plants_eligible |>
  pull(scientific_name)

plants_all_check<-BIEN_ranges_species_bulk(plants_all, directory = "output/bien_test")

maps_test_available<-list.files("output/bien_test/1", pattern=".shp") |>
  str_replace(".shp", "") |>
  str_replace("_", " ")

has_maps_tb<-tibble(scientific_name = maps_test_available) |>
  mutate(has_maps = TRUE)

map_results<-plants_eligible |>
  left_join(has_maps_tb, by="scientific_name") |>
  mutate(has_maps = ifelse(is.na(has_maps), FALSE, has_maps)) |> 
  select(scientific_name, has_maps) 

still_need_maps<-map_results |>
  filter(!has_maps) |>
  pull(scientific_name) |>
  str_replace_all("ssp. |var. ", "")

still_need_maps_return<-BIEN_ranges_species_bulk(still_need_maps, directory="output/bien_test", return_directory=FALSE)

check_rest_of_species<-lapply(still_need_maps, BIEN_ranges_species, match_names_only=T)
