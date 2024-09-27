library(tidyverse)
library(targets)
library(sf)
library(extrafont)
loadfonts()
library(ggspatial)
library(ggtext)
library(glue)
library(ggpattern)

t_id <- "2497295"
species_data <- tar_read(output_dne_eligible_lists) |>
  filter(taxon_id == t_id) |>
  mutate(
    min_overall_year = min(c_across(contains("minYear")), na.rm = T)
  )

sp_names <- glue("{species_data$common_name} (*{species_data$scientific_name}*)")

p_base <- ggplot() +
  theme_minimal(base_family = "Roboto Condensed") +
  ggspatial::annotation_north_arrow(
    location = "br",
    which_north = "true",
    height = unit(0.33, "in"),
    width = unit(0.33, "in"),
    style = north_arrow_fancy_orienteering()
  ) +
  theme(
    plot.background = element_rect(color = "black", linewidth = 1),
    plot.title = element_markdown(face = "bold", hjust = 0, margin = margin(0, 0, 5, 0, "pt")),
    plot.margin = margin(t = 10, r = 10, b = 10, l = 10, "pt"),
    plot.caption = element_markdown(),
    legend.title = element_markdown(),
    legend.position = "inside",
    legend.position.inside = c(0.15, 0.1),
    legend.box.background = element_rect(color = "black", linewidth = 0.5, fill = "white"),
    legend.box.margin = margin(0, 3, 0, 3, unit = "pt")
  )

base_map_data <- tar_read(evaluation_base_map_data)
base_area <- base_map_data$north_america

aoa <- tar_read(nnfg_aoa) |>
  st_transform(st_crs(base_area))

g_map_data <- tar_read(bird_maps) |>
  filter(taxon_id == t_id) |>
  st_transform(st_crs(base_area)) |>
  st_intersection(base_area |> st_union())

non_mig_orig <- g_map_data |>
  filter(season != "Migration") |>
  select(season)

mig_orig <- g_map_data |>
  filter(season == "Migration")

breed_orig <- g_map_data |>
  filter(season == "Breeding")

nonbreed <- g_map_data |>
  filter(season == "Nonbreeding")

breed_non_breed_overlap <- breed_orig |>
  st_intersection(nonbreed) |>
  st_intersection(mig_orig) |>
  mutate(
    season = "Year Round"
  ) |>
  select(season)

non_migratory_orig <- g_map_data |>
  filter(season != "Migration") |>
  select(season)


with_year_round <- g_map_data |>
  select(season) |>
  bind_rows(breed_non_breed_overlap)






p_base_a <- p_base +
  geom_sf(data = base_area, fill = "grey30", color = "white") +
  # geom_sf(data=mig_orig, aes(fill=season))+
  # geom_sf(data=breed_non_breed_overlap, aes(fill=season))+
  geom_sf(data = with_year_round, aes(fill = season), color = "transparent") +
  # geom_sf(data = g_map_data, aes(fill = season), color = "transparent") +
  scale_fill_brewer(palette = "Dark2") +
  facet_wrap(~season) +
  labs(
    title = sp_names,
    subtitle = "North American Range",
    fill = "**Season**",
    caption = "**Source:** eBird Status and Trends"
  )

p_base_a +
  geom_sf(data = base_area, fill = "transparent", color = "white") +
  geom_sf(data = aoa, fill = "yellow", color = "transparent") +
  theme(
    legend.position = "none"
  )
