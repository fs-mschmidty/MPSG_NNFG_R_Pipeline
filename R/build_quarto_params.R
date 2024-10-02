#' This function builds the parameters for parameterized reporting.  It returns just two fields, taxon_id which is used to select everything and output_file, which designates where the report is to be output.
#' @param x eligible species list.
#' @param output_path the base directory of where you want all of this output.

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
        is.na(order) ~ "Reptiles_and_Amphibians"
      ),
      sn_base = str_replace_all(scientific_name, "var\\. |ssp\\.", ""),
      sn_base = str_replace_all(scientific_name, "'", ""),
      sn_base = str_replace_all(sn_base, " ", "_"),
      cn = str_replace_all(common_name, " ", "_"),
      output_file = glue("{output_folder}/{subfolder}/AUTO_GENERATED_DO_NOT_EDIT__{cn}__{sn_base}.docx")
    ) |>
    select(taxon_id, output_file)
}

# tar_read(output_dne_eligible_lists) |>
#   group_by(taxon_id) |>
#   mutate(n = n()) |>
#   filter(n == 1) |>
#   ungroup() |>
#   filter(`Is the Species Native and Known to Occur` %in% c("Yes", "?", "")) |>
#   filter(is.na(class) | is.na(order)) |>
#   View()
# mutate(
#   subfolder = case_when(
#     kingdom == "Plantae" ~ "Plants",
#     class == "Aves" ~ "Birds",
#     class %in% "Amphibia" ~ "Reptiles_and_Amphibians",
#     class == "Mammalia" ~ "Mammals",
#     phylum == "Arthropoda" ~ "Invertebrates",
#     is.na(class) ~ "Fish",
#     is.na(order) ~ "Reptiles_and_Amphibians"
#   )
# ) |>
#   count(subfolder)
