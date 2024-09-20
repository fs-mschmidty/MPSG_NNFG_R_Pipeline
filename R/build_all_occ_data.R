build_all_occ_data<-function(x){
  lapply(x, function(x){
    x$eligible_unit |>
      select(taxon_id) |>
      mutate(taxon_id = as.character(taxon_id))
  })  |>
    bind_rows()
}
