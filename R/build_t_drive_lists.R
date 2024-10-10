#' This function manually cleans the the occurrence records
build_t_drive_lists <- function(x) {
  nhp_rdat <- file.path(x, "state_nhp.RData")

  attach(nhp_rdat)

  ## Clean the NENHP List.  Had to combine species into one due to duplicates (may need to fix upstream).
  nenhp_list <- nenhp_list |>
    filter(NENHP_locale == "NNFG") |>
    select(taxon_id, scientific_name, NENHP_nObs:NENHP_lastYear) |>
    rename(NENHP_maxYear = NENHP_lastYear) |>
    filter(!is.na(taxon_id)) |>
    distinct() |>
    group_by(taxon_id) |>
    mutate(
      NENHP_nObs = max(NENHP_nObs),
      NENHP_minYear = min(NENHP_firstYear),
      NENHP_maxYear = max(NENHP_maxYear)
    ) |>
    ungroup() |>
    select(taxon_id, scientific_name, NENHP_nObs, NENHP_minYear, NENHP_maxYear) |>
    distinct()

  sdnhp_list <- sdnhp_list |>
    filter(SDNHP_locale == "NNFG") |>
    select(taxon_id, scientific_name, SDNHP_nObs:SDNHP_lastYear) |>
    rename(SDNHP_maxYear = SDNHP_lastYear) |>
    filter(!is.na(taxon_id)) |>
    distinct() |>
    group_by(taxon_id) |>
    mutate(
      SDNHP_nObs = max(SDNHP_nObs),
      SDNHP_minYear = min(SDNHP_firstYear),
      SDNHP_maxYear = max(SDNHP_maxYear)
    ) |>
    ungroup() |>
    select(taxon_id, scientific_name, SDNHP_nObs, SDNHP_minYear, SDNHP_maxYear) |>
    distinct() |>
    ## In the NHP data there two synonyms for Argynnis idalia.  This removes the one that is not used.
    filter(scientific_name != "Speyeria idalia")

  detach()

  ## GBIF
  gbif_rdat <- file.path(x, "gbif.RData")
  attach(gbif_rdat)

  gbif_list <- gbif_list |>
    filter(GBIF_locale == "NNFG") |>
    select(taxon_id, scientific_name, GBIF_nObs:GBIF_maxYear) |>
    group_by(taxon_id) |>
    mutate(
      GBIF_nObs = max(GBIF_nObs, na.rm = T),
      GBIF_minYear = min(GBIF_minYear, na.rm = T),
      GBIF_maxYear = max(GBIF_maxYear, na.rm = T)
    ) |>
    distinct() |>
    filter(scientific_name != "Aeorestes cinereus")

  detach()

  ## iDigBio
  idb_rdat <- file.path(x, "idigbio.RData")
  attach(idb_rdat)

  idb_list <- idb_list |>
    filter(iDB_locale == "NNFG") |>
    select(taxon_id, scientific_name, iDB_nObs:iDB_maxYear) |>
    ## Removing synonym, could be decreasing nObs by 2
    filter(scientific_name != "Atriplex suckleyi")

  detach()

  ## Seinet

  seinet_rdat <- file.path(x, "seinet.RData")
  attach(seinet_rdat)

  seinet_list <- seinet_list |>
    filter(SEI_locale == "NNFG") |>
    select(taxon_id, scientific_name, SEI_nObs:SEI_maxYear) |>
    group_by(taxon_id) |>
    mutate(
      SEI_nObs = sum(SEI_nObs),
      SEI_minYear = min(SEI_minYear),
      SEI_maxYear = max(SEI_maxYear)
    ) |>
    distinct(taxon_id, SEI_nObs, SEI_minYear, SEI_maxYear, .keep_all = T)

  detach()

  ## IMBCR
  imbcr_rdat <- file.path(x, "imbcr.RData")
  attach(imbcr_rdat)

  imbcr_list <- imbcr_list |>
    filter(IMBCR_locale == "NNFG") |>
    select(taxon_id, scientific_name, IMBCR_nObs:IMBCR_maxYear)

  detach()

  lst(
    sdnhp_list,
    nenhp_list,
    gbif_list,
    idb_list,
    seinet_list,
    imbcr_list
  )
}
