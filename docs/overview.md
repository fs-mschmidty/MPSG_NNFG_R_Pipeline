---
title: Documentation for Species Overviews
---

The following document documents the procedures that were followed while automating species overviews for the MPSG.

## Species Lists

The root of automating the species overview process is identifying a potentially eligible species list. How the MPSG accomplishes this is well documented in the "XXXXXXX Matts DocumentXXXXXXXX". Here I will detail my part in that process only because it informs how automation will occur.

One important part of that process is determining the taxonomy of each species and identifying that species by a number. This is so important because automation by its nature requires that many data sources be connected. For the species group, a taxonomy and a taxon ID are allow us to cross reference a variety of sources.

To accomplish a consistent taxonomy across data sets, we have developed an R package with a function `get_taxonomies()`. This function takes a data.frame or object that can be coerced into a data.frame (ie simple feature) with a scientific name field and returns the taxonomy of that species added to the data frame and adds a taxon_id. This function uses the GBIF taxonomy backbone to classify species to an accepted classification and to provide the `taxon_id` field. It was recommended that we use Nature Serve for this step. But after testing, NatureServe's classification process it was found results were too inconsistent and returned incorrect classification.

We now run `get_taxonomies()` across all data sets for consistency.

### Species Occurrence

As part of the species list there are a variety of species occurrence databases that we use to determine which species are present across a give unit. The databases currently being used are:

- [Global Biodiversity Information Facility(GBIF)](https://gbif.org)
- [SEINet Plants Database](https://swbiodiversity.org/seinet/index.php)
- Natural Heritage EO polygons
