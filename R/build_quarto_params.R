build_quarto_params <- function(x, output_path) {
  x |>
    group_by(taxon_id) |>
    mutate(n = n()) |>
    filter(n == 1) |>
    ungroup() |>
    filter(`Is the Species Native and Known to Occur` %in% c("Yes", "?")) |>
    mutate(
      output_folder = output_path,
      subfolder = case_when(
        kingdom == "Plantae" ~ "Plants",
        class == "Aves" ~ "Birds",
        class %in% "Amphibia" ~ "Reptiles_and_Amphibians",
        class == "Mammalia" ~ "Mammals",
        phylum == "Arthropoda" ~ "Invertebrates",
        is.na(class) ~ "Fish",
        is.na(order) ~ "Fish"
      ),
      sn_base = str_replace_all(scientific_name, "var\\. |ssp\\.", ""),
      sn_base = str_replace_all(sn_base, " ", "_"),
      cn = str_replace_all(common_name, " ", "_"),
      output_file = glue("{output_folder}/{subfolder}/AUTO_GENERATED_DO_NOT_EDIT__{sn_base}__{cn}.docx")
    ) |>
    select(taxon_id, output_file)
}

# tar_read(output_dne_eligible_lists) |>
#     group_by(taxon_id) |>
#     mutate(n = n()) |>
#     filter(n == 1) |>
#     ungroup() |>
#     filter(`Is the Species Native and Known to Occur` %in% c("Yes", "?", "")) |>
#     mutate(
#     subfolder = case_when(
#       kingdom=="Plantae"~"Plants",
#       class=="Aves"~"Birds",
#       class %in% "Amphibia"~ "Reptiles_and_Amphibians",
#       class=="Mammalia"~"Mammals",
#       phylum=="Arthropoda"~"Invertebrates",
#       is.na(class)~"Fish",
#       is.na(order)~"Fish"
#     )
#   ) |>
#   count(subfolder)
