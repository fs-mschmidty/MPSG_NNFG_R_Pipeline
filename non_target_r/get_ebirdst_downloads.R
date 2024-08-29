library(ebirdst)
library(tidyverse)
library(targets)
library(MetBrewer)
library(extrafont)
library(rnaturalearth)
library(sf)
loadfonts()
# set_ebirdst_access_key("ki29n9mqdfvp")

eligible_birds <- tar_read(eligible_lists)$current_eligible_list |>
  filter(class == "Aves") |>
  select(taxon_id, scientific_name) |>
  left_join(ebirdst_runs, by = "scientific_name") |>
  filter(!is.na(species_code))

eligible_birds_sci_names <- eligible_birds |>
  pull(scientific_name)

ebird_data_loc <- "T:\\FS\\NFS\\PSO\\MPSG\\Data\\ExternalData\\eBird"

ebirdst_data_dir()

ebirdst_download_status(eligible_birds_sci_names[3], download_ranges = T, pattern = "range_smooth_27km|range_smooth_9km")

lapply(eligible_birds_sci_names, ebirdst_download_status, download_ranges = T, pattern = "range_smooth_27km|range_smooth_9km")

test <- load_ranges(eligible_birds_sci_names[4]) |>
  filter(season %in% c("breeding", "nonbreeding")) |>
  mutate(
    season = ifelse(season == "breeding", "Breeding", "Nonbreeding")
  )

states <- ne_states(country = c("United States of America", "Canada", "Mexico"))

ggplot() +
  theme_void(base_family = "Roboto Condensed") +
  geom_sf(data = test, aes(fill = season), color = "transparent") +
  scale_fill_manual(values = met.brewer("Renoir", 2)) +
  labs(
    title = "Some species that is good",
    fill = "Legend"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0, margin = margin(0, 0, 5, 0, "pt")),
    plot.margin = margin(t = 20, r = 20, b = 20, l = 20, "pt"),
    legend.position = "inside",
    legend.position.inside = c(0.15, 0.1)
  )
