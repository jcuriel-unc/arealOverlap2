################################################################################
############# OH Areal interpolation script  ############
################################################################################
############### Author: John Curiel, jcuriel.unc@gmail.com #####################
################################################################################
######################## Date: 06/30/2026 ######################################
################################################################################
### data sources ###
# elections results & Maps: https://redistrictingdatahub.org/state/texas/
# TX Census Block Group data: https://data.capitol.texas.gov/dataset/2020-census-geography
## pkgs 
rm(list=ls()); gc(); 

library(foreign)
library(haven)
library(MCMCglmm)
library(stringi)
library(stringr)
library(sp)
library(geojsonio)
# library(rgdal) # apparently not present? 
library(sf)
library(MASS)
library(ggplot2)
library(ggpubr)
library(devtools)
library(raster)
library(tidyverse)
library(geojsonsf)
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
library(ggthemes)
##install areal overlapR 
devtools::install_github("https://github.com/jcuriel-unc/arealOverlap2",subdir="arealOverlap")
library(areal)
library(arealOverlap)

#############
data_wd <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(data_wd)

zctas <- arealOverlap::zctas #shapefile 1

cbg_oh <- arealOverlap::cbg_oh#atomic level shapefile to act as grid

oh_sen <- arealOverlap::oh_sen#shapefile 2

test_overlap <-weight_overlap_new(shp1 = zctas, shp_atom = cbg_oh, shp2 = oh_sen, pop_field = "POP2010")
head(test_overlap)


test_output <- overlap_dyad_creatr(test_overlap, id1="ZCTA5CE10",id2="id", census_fields = c("WHITE","BLACK","MALES"))
head(test_output)









### read in the data
## CBG 
cbg_path <- list.files("data/blockgroups",full.names = T)
cbg_path <- cbg_path[grepl(".shp",cbg_path)]
cbg_tx <- st_read(cbg_path[1]) # 18638 polygons 

## get the txt file for the data 
cbg_pop <- read.table("data/blockgroups/blockgroups_pop.txt",sep=",",header = T)

## check if index unique 
length(unique(cbg_tx$CTBGKEY)) == nrow(cbg_pop) ## should be true 

### now merge the data 
cbg_tx <- merge(cbg_tx, cbg_pop, by="CTBGKEY")

## State Senate Districts  
sldu_path <- list.files("data/tx_sldu_2021", full.names = T)
sldu_path <- sldu_path[grepl(".shp",sldu_path)]
sldu_shp <- st_read(sldu_path) ## 31 polygons 

### VTDs 
vtd_path <- list.files("data/tx_20_vtd/tx_20_vtd",full.names = T)
vtd_path <- vtd_path[grepl("tx_20_st_vtd",vtd_path)] ## looks like this includes all of the cong and 
# state leg dists 
vtd_shp <- st_read("data/tx_20_vtd/tx_20_vtd/tx_20_st_vtd.shp") # 9160 polygons 

### check projections ; should be true 
crs(sldu_shp) == crs(cbg_tx)
crs(sldu_shp) == crs(vtd_shp)

#### now, here is where the areal overlap is found for the three layers; weighting based upon pop in atomic file

vtd_sldu_overlap <-weight_overlap_new(shp1 = vtd_shp , shp_atom = cbg_tx, 
                                     shp2 = sldu_shp, pop_field = "total")
class(vtd_sldu_overlap) # so this appears to be working...? Yup. 
### save data here 
saveRDS(vtd_sldu_overlap, "data/output/raw_overlap_output.rds")
vtd_sldu_overlap <- readRDS("data/output/raw_overlap_output.rds")
### should have a bunch of dyadic data here that's too long; let's collapse 
## check the readME file; 
#G20PREDBID                  Biden
# G20PRERTRU                  Trump
vtd_sldu_overlap_output <- overlapfunction(vtd_sldu_overlap, id1="UNIQUE_ID", pop_field = "pop_field",
                                           id2="District")
str(vtd_sldu_overlap_output)
vtd_sldu_overlap_output <- overlapfunction(vtd_sldu_overlap, id1="UNIQUE_ID", 
                                         id2="District", 
                                         census_fields=c("black","hisp","anglo"))

str(vtd_sldu_overlap_output)
## need to fix: first_shp_pop, second_shp_pop,  anything with dyad or shp as part 

### test out the other fxns 
herf_scores <- herfindahl(vtd_sldu_overlap_output, "UNIQUE_ID")
c_match = correctly_matched(vtd_sldu_overlap_output, "UNIQUE_ID","District" ) # gets us the 
# percent that are matched correctly at the level of the second ID 
b_match = best_match(vtd_sldu_overlap_output, "UNIQUE_ID") # reduces down to the highest overlap, reducing only
# to unique vals for first ID 

m_pop1 = matched_pop(vtd_sldu_overlap_output, "UNIQUE_ID")
# not all that helpful; just finds out the aggregated weighted pop v actual pop, it appears. 

# applied, I believe 

### the above now acts as a crosswalk. Next step: merge on the original data of interest 
vtd_slim <- subset.data.frame(vtd_shp, select=c(UNIQUE_ID,G20PREDBID,G20PRERTRU ))
colnames(vtd_sldu_overlap_output)[1:2] <- c("UNIQUE_ID", "sldu_dist")
### merge 
vtd_sldu_overlap_output_merge <- merge(vtd_sldu_overlap_output,vtd_slim, by="UNIQUE_ID" )

## now, weight and sum 

sldu2party_voteshare_potus <- vtd_sldu_overlap_output_merge %>% 
  group_by(sldu_dist) %>% 
  summarise( trump_wt=sum(overlap1*G20PRERTRU, na.rm = T), 
             biden_wt=sum(overlap1*G20PREDBID, na.rm=T) )

