#' Calculate dyadic population overlap between 2 levels of geography; updated
#' 
#' This function takes the raw output of the three way intersection between 2 levels of geography and census tabulation units in order 
#' to calculate the population overlap between the 2 levels of geography. 
#' @param filename1a The DBF file name or object of the raw intersectional geographic shapefile 
#' @param id1 The ID field of the first shapefile of interest 
#' @param id2 The ID field of the second shapefile of interest 
#' @param pop_field The field with the population data 
#' @param merge_table An optional command to merge on additional census data for sociodemographic information
#' @param merge_id1 Given the choice to merge on additional data, the name of the field from the first dbf by which to merge 
#' @param merge_id2 Given the choice to merge on additional data, the name of the field from the second dbf by which to merge
#' @param census_fields The option to provide 2 or more census fields to calculate the demographics of from Census data 
#' @return The data frame with the dyadic population overlap between the first and second shapefiles. The following are the values:
#'    \itemize{
#'    \item id2 = The specified ID of the second shapefile set by the user. 
#'    \item id1 = The specified ID of the first shapefile set by the user. 
#'    \item DYAD_ID = The pasted and underscored dyadic ID of the two shapefiles 
#'    \item pop_wt = The Calculated population within the dyad 
#'    \item first_shp_pop = The calculated total population of the first shapefile
#'    \item second_shp_pop = The calculated total population of the second shapefile 
#'    \item overlap1 = A score between 0 and 1 of the population overlap between the first and second shapefiles. Score of 1 = complete nesting
#'    \item overlap2 = A score between 0 and 1 of the proportion of the second shapefile's population present within the first shapefile. 
#'    \item optional returns: (census_field)_i_wt = The calculated weighted census field population within the dyad
#'    \item shp1_(census_field)_i_wt = The calculated weighted census field population within the first level of geography
#'    \item shp2_(census_field)_i_wt = The calculated weighted census field population within the second level of geography
#'    \item (census_field)_i_pct_dyad = The calculated weighted census field percent of population within the dyad
#'    \item (census_field)_i_pct_shp1 = The calculated weighted census field percent of population within the first level of geography
#'    \item (census_field)_i_pct_shp2 = The calculated weighted census field percent of population within the second level of geography 
#' }
#' @export
#' @examples
#' setwd(wd_zip)
#' zip_cd115V<-read.dbf("all_merge3.dbf") #481946 obs, 76 vars 
#' zip_cd115V <- subset(zip_cd115V, POP2010 >= 0)
#' overlap115 <- overlapfunction(zip_cd115V, id1 =  "ZCTA5CE10", id2="GEOID", pop_field = "POP2010")
#' overlap115b <- overlapfunction(zip_cd115V, id1 =  "ZCTA5CE10", id2="GEOID", pop_field = "POP2010", census_fields = c("WHITE","HISPANIC") )

weight_overlap_new <- function (shp1, shp_atom, shp2, 
                             crs1 = "+proj=laea +lat_0=10 +lon_0=-81 +ellps=WGS84 +units=m +no_defs", 
                             crs2 = "+init=epsg:2163", pop_field) 
{
  t1 <- Sys.time()
  #list.of.packages <- c("sf", "areal",  "raster", "tidyverse")
  #new.packages <- list.of.packages[!(list.of.packages %in% 
  #                                     installed.packages()[, "Package"])]
  #if (length(new.packages)) 
  #  install.packages(new.packages)
  #invisible(lapply(list.of.packages, library, character.only = TRUE))
  #shp1 <- spTransform(shp1, CRS(crs1)) %>% gBuffer(byid = T, 
  #                                                 width = 0)
  #shp_atom <- spTransform(shp_atom, CRS(crs1)) %>% gBuffer(byid = T, 
  #                                                         width = 0)
  #shp2 <- spTransform(shp2, CRS(crs1)) %>% gBuffer(byid = T, 
  #                                                 width = 0)
  shp1 <- st_as_sf(shp1)
  shp1 <- st_transform(shp1, crs2)
  shp_atom <- st_as_sf(shp_atom)
  shp_atom <- st_transform(shp_atom, crs2)
  shp2 <- st_as_sf(shp2)
  shp2 <- st_transform(shp2, crs2)
  shp_atom$area_cb <- st_area(shp_atom)
  shp1_int <- aw_intersect(shp1, shp_atom, "shp1_atom_area")
  shp_all_int <- aw_intersect(shp1_int, shp2, "atomic_area")
  shp_all_int$areal_weight <- shp_all_int$atomic_area/shp_all_int$area_cb
  shp_all_int <- as.data.frame(shp_all_int)
  pop_position <- match(pop_field, names(shp_all_int))
  shp_all_int$pop_field <- shp_all_int[, pop_position]
  shp_all_int$pop_wt <- shp_all_int$pop_field * shp_all_int$areal_weight
  t2 <- Sys.time()
  print(t2 - t1)
  return(shp_all_int)
}