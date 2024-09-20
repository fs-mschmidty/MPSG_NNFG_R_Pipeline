build_quarto_params <- function(x) {
  x |>
    group_by(taxon_id) |>
    mutate(n = n()) |>
    filter(n == 1) |>
    filter(`Is the Species Native and Known to Occur` %in% c("Yes", "?")) |>
    mutate(
      sn_base = str_replace_all(scientific_name, "var\\. |ssp\\.", ""),
      sn_base = str_replace_all(sn_base, " ", "_"),
      cn = str_replace_all(common_name, " ", "_"),
      output_file = glue("{sn_base}__{cn}.docx")
    ) |>
    select(taxon_id, output_file)
}
