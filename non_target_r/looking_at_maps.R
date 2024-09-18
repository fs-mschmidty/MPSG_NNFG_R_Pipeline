library(sf)
library(tidyverse)
library(targets)

sp <- gbif_spatial_eligible$eligible %>% filter(taxon_id == "6065773")
a_bd <- tar_read(nnfg_fs_ownership)

ggplot() +
  geom_sf(data = a_bd) +
  geom_sf(data = sp)

mapview(list(a_bd, sp))

## check all maps to see how many species that are native a known have maps.
bien_maps <- tar_read(bien_plant_maps) |>
  as_tibble() |>
  count(taxon_id) |>
  select(taxon_id) |>
  mutate(source = "BIEN Maps")

iucn_maps <- tar_read(all_iucn_map) |>
  as_tibble() |>
  count(taxon_id) |>
  select(taxon_id) |>
  mutate(source = "IUCN Maps")

ebird_maps <- tar_read(bird_maps) |>
  as_tibble() |>
  count(taxon_id) |>
  select(taxon_id) |>
  mutate(source = "eBird Maps")

all_maps <- bind_rows(
  bien_maps,
  iucn_maps,
  ebird_maps
)

tar_read(output_dne_eligible_lists) |>
  filter(`Is the Species Native and Known to Occur` %in% c("?", "Yes")) |>
  left_join(all_maps, by = "taxon_id") |>
  filter(kingdom == "Plantae") |>
  View()
count(kingdom, phylum, class, source) |>
  group_by(class) |>
  mutate(prop = n / sum(n))
