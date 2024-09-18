get_ns_habitat <- function(ns_state_list, el_list) {
  t_ids <- el_list |>
    filter(`Is the Species Native and Known to Occur` %in% c("Yes", "?")) |>
    pull(taxon_id)

  ns_el_data <- ns_state_list |>
    filter(taxon_id %in% t_ids) |>
    mutate(api_shortcode = str_extract(view_on_nature_serve_explorer, "ELEMENT_GLOBAL\\.\\d+\\.\\d+")) |>
    mutate(ns_taxon_api_url = glue("https://explorer.natureserve.org/api/data/taxon/{api_shortcode}")) |>
    distinct() |>
    group_by(taxon_id) |>
    mutate(n = n()) |>
    ungroup() |>
    filter(n == 1)


  natureserv_get_hab_data <- function(x) {
    req <- request(x)

    resp <- req_perform(req) |>
      resp_body_json()

    all_hab_names <- c(
      "terrestrial",
      "marine",
      "riverine",
      "palustrine",
      "lacustrine",
      "subterrainean",
      "estuarine"
    )

    root_of_chars <- resp$speciesCharacteristics

    habitatComments <- root_of_chars$habitatComments

    hab_df <- tibble(
      hab_cat = c("comments"),
      ns_hab = habitatComments
    )

    return_habs_from_hab_cat <- function(x,h_t) {
      tibble(
        hab_cat = h_t,
        ns_hab = x[2][[1]][[2]]
      )
    }


    get_all_habs <- function(x, ls_json) {
      hab_type <- x
      hab_list <- ls_json[glue("species{str_to_title(hab_type)}Habitats")]

      hab_list[[1]] |>
        lapply(return_habs_from_hab_cat,hab_type) |>
        bind_rows()
    }

    lapply(all_hab_names, get_all_habs, root_of_chars) |>
      bind_rows() |>
      bind_rows(hab_df)
  }
  get_all_ns_data <- function(t_id, list) {
    sp_data <- list |>
      filter(taxon_id == t_id)
    print(sp_data$scientific_name)

    natureserv_get_hab_data(as.character(sp_data$ns_taxon_api_url)) |>
      mutate(taxon_id = t_id)
  }

  ns_el_data |>
    pull(taxon_id) |>
    lapply(get_all_ns_data, ns_el_data) |>
    bind_rows()
}
