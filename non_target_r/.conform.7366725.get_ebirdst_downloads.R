library(ebirdst)
library(tidyverse)
library(targets)
library(MetBrewer)
library(glue)
library(extrafont)
library(rnaturalearth)
library(sf)
library(ggtext)
loadfonts()

eligible_birds <- tar_read(eligible_lists)$current_eligible_list |>
  filter(class == "Aves") |>
  select(taxon_id, scientific_name) |>
  left_join(ebirdst_runs, by = "scientific_name")

eligible_birds_w_dist <- eligible_birds |>
  filter(!is.na(species_code))

eligible_birds_wo_dist <- eligible_birds |>
  filter(is.na(species_code))

eligible_birds_sci_names <- eligible_birds_w_dist |>
  pull(scientific_name)

## this downloads all of the bird distribution models from cornel.
lapply(eligible_birds_sci_names, ebirdst_download_status, download_ranges = T, pattern = "range_smooth_27km|range_smooth_9km")

test <- load_ranges(eligible_birds_sci_names[5], resolution = "9k") |>
  mutate(
    season = case_when(
      season == "breeding" ~ "Breeding",
      season == "nonbreeding" ~ "Nonbreeding",
      TRUE ~ "Migration"
    ),
    order = case_when(
      season == "Breeding" ~ 1,
      season == "Nonbreeding" ~ 2,
      TRUE ~ 3
    )
  ) |>
  arrange(desc(order))

title <- test |>
  head(1) |>
  mutate(title = glue("Non Migratory Ranges of *{scientific_name}* ({common_name}) in North America")) |>
  pull(title)

states <- ne_states(country = c("United States of America", "Canada", "Mexico")) |>
  st_as_sf() |>
  filter(name != "Hawaii") |>
  st_transform(crs = 5070)

test_cr <- test |>
  st_transform(crs = st_crs(states)) |>
  st_intersection(states)

admin_body <- tar_read(nnfg_bd) |>
  st_transform(crs = st_crs(states))


## Map for birds
ggplot() +
  theme_void(base_family = "Roboto Condensed") +
  geom_sf(data = states) +
  geom_sf(data = test_cr, aes(fill = season), color = "transparent") +
  geom_sf(data = admin_body, fill = "transparent", color = "black") +
  scale_fill_manual(values = met.brewer("Lakota", 3)) +
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

## Transient determination functions

aoa <- tar_read(nnfg_aoa) |>
  st_transform(4326)

bird <- load_ranges(eligible_birds_sci_names[5], resolution = "27k")

v_ranges_overlap <- bird |>
  st_intersection(aoa) |>
  count(season) |>
  pull(season)

breeding_status <- ("breeding" %in% v_ranges_overlap)
wintering_status <- ("nonbreeding" %in% v_ranges_overlap)
