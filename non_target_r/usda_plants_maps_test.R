library(httr2)
library(tidyverse)

base_url <- "https://plantsservices.sc.egov.usda.gov/api/CharacteristicsSearch"

req <- request(base_url) |>
  req_body_form(
    Type = "Characteristics",
    `TaxonSearchCriteria[Text]` = "Artemisia tridentata",
    `TaxonSearchCriteria[Field]` = "Scientific Name",
    SortBy = "sortSciName",
    Offset = "-1"
  )


response <- req |>
  req_perform()
json <- response |>
  resp_body_json()

json$PlantResults[[1]]$ScientificName

plants_api_base <- "https://plantsservices.sc.egov.usda.gov/api/PlantProfile?symbol="
current_plant_symbol <- json$PlantResults[[1]]$Symbol
api_artr2 <- paste0(plants_api_base, current_plant_symbol)

req2 <- request(api_artr2)

t <- req2 |>
  req_perform() |>
  resp_body_json()
t$Synonyms

dist_url <- "https://plantsservice.sc.egov.usda.gov/api/PlantProfile/getDownloadDistributionDocumentation"

r3 <- request(dist_url) |>
  req_body_form(
    Text = "Artr2",
    Field = "Symbol",
    SortBy = "sortSciName",
    MasterId = 32390,
    Offset = "-1"
  )

res3 <- req_perform(r3)
