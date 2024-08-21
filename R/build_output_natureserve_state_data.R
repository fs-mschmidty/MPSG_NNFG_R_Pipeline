build_output_natureserve_state_data <- function(x, output_path, output_name) {
  x |>
    saveRDS(file.path(output_path, paste0(output_name, "_metadata_and_original_pulls.rds"), fsep = "\\"))

  x$unit_nature_serve_list |>
    write_csv(file.path(output_path, paste0(output_name, ".csv"), fsep = "\\"))

  output_name
}
