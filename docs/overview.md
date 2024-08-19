---
title: Documentation for Species Overviews
---

The following document documents the procedures that were followed while automating species overviews for the MPSG. 

## Species Lists 
The root of automating the species overview process is identifying a potentially eligible species list. How the MPSG accomplishes this is well documented in the "XXXXXXX Matts DocumentXXXXXXXX". 

One important part of that process is determining the taxonomy of each species and identifying that species by a number.  This is so important because automation by its nature requires that many data sources be connected.  For the species group, a taxonomy and a taxon ID are allow us to cross reference a variety of sources.  

To accomplish a consistent taxonomy across data sets, we have developed an R package with a function `get_taxonomies()`.  This function takes a data.frame or object that can be coerced into a data.frame (ie simple feature) with a scientific name field and returns the taxonomy of that species added to the data frame and adds a taxon_id.  This function uses the GBIF taxonomy backbone to classify species to an accepted classification and to provide the taxon_id field. It was recommended that we use NatureServe for this step.  But after testing, NatureServe's classification process was too inconsistant and returned incorrect classification. 
