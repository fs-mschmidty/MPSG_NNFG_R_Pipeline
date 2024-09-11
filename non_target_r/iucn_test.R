library(tidyverse)
library(rnaturalearth)
library(sf)
library(targets)
library(mpsgSO)
library(glue)
library(MetBrewer)
library(ggtext)
library(extrafont)
loadfonts()
sf_use_s2(FALSE)

t_path <- file.path("T:/FS/NFS/PSO/MPSG/Data/ExternalData/IUCN")


t_mammals <- mammals |>
  st_drop_geometry() |>
  as_tibble()

t_mammals |>
  head(1000) |>
  View()


iucn_taxon_id <- iucn_mammals_pot_with_taxoinomies |>
  select(sci_name, taxon_id)

el_taxon_ids <- tar_read(eligible_lists)$current_eligible_list |>
  filter(class == "Mammalia") |>
  select(taxon_id, scientific_name, common_name)

ter_mammal_maps <- el_taxon_ids |>
  left_join(iucn_taxon_id, by = "taxon_id") |>
  filter(!is.na(sci_name)) |>
  rename(query_name = sci_name)

map <- ter_mammal_maps |>
  sample_n(1) |>
  pull(query_name)

st_layers(file.path(t_path, "MAMMALS.shp"))

ad_bd<-tar_read(nnfg_aoa)

wkt<-ad_bd |>
  st_transform(4326) |> 
  st_geometry() |>
  st_as_text()

test <- st_read(file.path(t_path, "MAMMALS.shp"), query = glue("SELECT * FROM MAMMALS WHERE sci_name =  '{map}'"))
Sys.time()
test2 <-st_read(file.path(t_path, "MAMMALS.shp"), wkt_filter=wkt)
Sys.time()

states <- ne_states(country = c("United States of America", "Canada", "Mexico")) |>
  st_as_sf() |>
  filter(name != "Hawaii") |>
  st_transform(crs = 5070)

test_cr <- test |>
  st_transform(crs = st_crs(states)) |>
  st_intersection(st_union(states))

admin_body <- tar_read(nnfg_bd) |>
  st_transform(crs = st_crs(states))

title <- glue("North American Distribution of {map} ()")

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
