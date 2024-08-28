build_eligible_list <- function(state_lists, occ_lists, ne_state_list, sd_state_list, r2_ss_list) {
  ne_swap_eligible <- ne_state_list |>
    mutate(
      nebraska_swap = status_r
    ) |>
    select(taxon_id, nebraska_swap)

  sd_te_eligible <- sd_state_list |>
    mutate(sd_te = status_r) |>
    select(taxon_id, sd_te)

  rfss_ss <- r2_ss_list |>
    mutate(r2_ss_list = status_a) |>
    select(taxon_id, r2_ss_list)

  ns_state_eligible <- state_lists$unit_nature_serve_list |>
    left_join(ne_swap_eligible, by = "taxon_id") |>
    left_join(sd_te_eligible, by = "taxon_id") |>
    left_join(rfss_ss, by = "taxon_id") |>
    rename(rounded_gRank = nature_serve_rounded_global_rank) |>
    filter(
      str_detect(rounded_gRank, "[GT][123]") |
        str_detect(NE_sRank, "[ST][12]") |
        !is.na(sd_te) |
        str_detect(nebraska_swap, "Tier 1") |
        !is.na(r2_ss_list)
    ) |>
    distinct(scientific_name, taxon_id, .keep_all = T)

  ns_state_eligible_cl <- ns_state_eligible |>
    select(taxon_id, scientific_name, common_name, rounded_gRank, NE_sRank, SD_sRank, usfws_status = u_s_endangered_species_act_status, r2_ss_list, sd_te, nebraska_swap, kingdom:form) |>
    mutate(taxon_id = as.character(taxon_id)) |>
    distinct(taxon_id, scientific_name, rounded_gRank, NE_sRank, SD_sRank, .keep_all = T)

  ## These are the species that are problematic from the state NatureServe Lists.
  find_problems <- ns_state_eligible_cl |>
    group_by(taxon_id) |>
    mutate(n = n()) |>
    ungroup() |>
    mutate(taxon_id = as.character(taxon_id))

  taxon_problems <- find_problems |>
    filter(n > 1) |>
    arrange(scientific_name) |>
    select(-n)

  no_taxon_problems <- find_problems |>
    filter(n == 1) |>
    select(-n)

  joined_lists <- no_taxon_problems |>
    left_join(select(occ_lists$nenhp_list, -scientific_name), by = "taxon_id") |>
    left_join(select(occ_lists$sdnhp_list, -scientific_name), by = "taxon_id") |>
    left_join(select(occ_lists$seinet_list, -scientific_name), by = "taxon_id") |>
    left_join(select(occ_lists$gbif_list, -scientific_name), by = "taxon_id") |>
    left_join(select(occ_lists$idb_list, -scientific_name), by = "taxon_id")


  curr_eligible_list <- joined_lists |>
    mutate_at(vars(matches("nObs")), .funs = ~ replace_na(.x, 0)) |>
    mutate(sum_nObs = SDNHP_nObs + NENHP_nObs + SEI_nObs + GBIF_nObs + iDB_nObs) |>
    filter(sum_nObs > 0) |>
    select(taxon_id:nebraska_swap, NENHP_nObs:sum_nObs, kingdom:form)

  eligible_lists <- list()

  eligible_lists[["ns_state_eligible"]] <- ns_state_eligible_cl
  eligible_lists[["eligible_taxon_problems"]] <- taxon_problems
  eligible_lists[["eligible_no_taxon_problems"]] <- no_taxon_problems
  eligible_lists[["all_occ_data_joined"]] <- joined_lists
  eligible_lists[["current_eligible_list"]] <- curr_eligible_list

  eligible_lists
}


# eligible_lists
