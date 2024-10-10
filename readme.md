This project is a data pipeline produced by the USDA Forest Service, Mountain States Planning Group. It gathers data for and produces automated species evaluations for the Nebraska National Forests and Grasslands' (NNFG) as part of the Pre Assessment Forest planning process. It uses the `{targets}` R package to handle the workflow and quarto parameterized reporting to output the reports. The result is a base template with maps and general information for all species that are eligible for SCC status on the NNFG.

## How to Run

This project uses the targets package as an R pipeline. To run all the targets, call `tar_make()`. To load the targets run `tar_load(target_name)` changing target_name to the name of the target. You can also run `tar_load_everything()` to load all the targets at once.

