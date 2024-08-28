build_imbcr_trend <- function(x) {
  imbcr_for_ks_ne <- read_csv(x) |>
    clean_names() |>
    filter(str_detect(stratum, "^NE|^SD")) |>
    filter(stratum %in% c("NE-BCR18", "NE-BCR18-GG", "SD-BCR17", "SD-BCR17-BG", "SD-BCR17-FP")) |>
    rename(common_name = species)
  tempt <- "ready_test"
  common_names <- imbcr_for_ks_ne |>
    count(common_name) |>
    pull(common_name)

  resolve_common_name <- comm2sci(common_names, db = "itis", simplify = FALSE)

  sci_names <- imap(
    resolve_common_name,
    function(x, y) {
      if (nrow(x) != 0) {
        x |>
          mutate(common_name = y) |>
          filter(!is.na(unitname2)) |>
          head(1)
      }
    }
  ) |>
    bind_rows() |>
    select(scientific_name = combinedname, common_name) |>
    get_taxonomies()

  imbcr_for_ks_ne |>
    left_join(sci_names, by = "common_name")
}
# library(tidyverse)
# library(taxize)
# common_names <- imbcr_trend |>
#   count(species) |>
#   pull(species)
# resolve_common_name <- comm2sci(common_names, db = "itis", simplify = FALSE)


# sci_names <- imap(resolve_common_name, \(x, y) x |>
#   mutate(common_name = y) |>
#   head(1)) |>
#   bind_rows() |>
#   select(scientific_name = combinedname, common_name)

# sp <- imbcr_trend |>
#   count(common_name) |>
#   filter(common_name == "Canada Jay") |>
#   pull(common_name)

# res <- comm2sci(sp, db = "itis", simplify = FALSE)
