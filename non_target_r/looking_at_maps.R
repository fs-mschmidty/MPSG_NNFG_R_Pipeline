library(sf)
library(tidyverse)
library(targets)

sp <- gbif_spatial_eligible$eligible %>% filter(taxon_id == "6065773")
a_bd <- tar_read(nnfg_fs_ownership)

ggplot() +
  geom_sf(data = a_bd) +
  geom_sf(data = sp)

mapview(list(a_bd, sp))
