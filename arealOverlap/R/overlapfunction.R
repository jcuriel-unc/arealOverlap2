#' Calculate dyadic population overlap between 2 levels of geography
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

overlapfunction <- function(filename1a, id1, id2, pop_field, merge_table,  merge_id1, merge_id2, census_fields){
  list.of.packages <- c("tidyr","dplyr")
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  if(is.data.frame(filename1a)==TRUE){
    temp_dbf <- filename1a
  }else{temp_dbf <- read.dbf(filename1a)}
  
  #temp_dbf <- subset(temp_dbf, FID_US_prj != -1)
  temp_dbf <- subset(temp_dbf, FID_all_me != -1)
  initial_rows <- nrow(temp_dbf)
  #the above steps get rid of the empty data, which is not needed 
  if(missing(merge_table)==FALSE){
    if(missing(merge_id1)==TRUE){
      stop("Extra data provided but merge ID 1 is missing")
    }else if(missing(merge_id2)==TRUE){
      stop("Extra data provided but merge ID 2 is missing")
    }else if(missing(merge_id1)==FALSE & missing(merge_id2)==FALSE){
      #temp_dbf[, (colnames(temp_dbf) == merge_id1 ) == TRUE] <- as.character(temp_dbf[, (colnames(temp_dbf) == merge_id1 ) == TRUE])
      #merge_table[, (colnames(merge_table) == merge_id2 ) == TRUE] <- 
      #as.character(merge_table[, (colnames(merge_table) == merge_id1 ) == TRUE]) #ensures that the field is character for merge
      temp_dbf <- merge(temp_dbf, merge_table, by.x = merge_id1, by.y= merge_id2) # merges the temp_dbf field with a census table 
    } #provided by the user 
    print(nrow(temp_dbf))
  }else{}
  print("Read in/merged data") # A check to ensure that the function made it this far 
  if(missing(id1)==FALSE & missing(id2)==FALSE){
    id_position1 <- match(id1, names(temp_dbf)) #These are the ID fields that will go onto make the dyads. The following match cmds
    id_position2 <- match(id2, names(temp_dbf))#finds the col position in the df of the ID fields  
    temp_dbf$DYAD_ID <- paste(temp_dbf[,id_position1], temp_dbf[,id_position2], sep = "_")
  }else{stop("Error: The ID fields necessary to create the DYAD ID is not provided.")}
  temp_dbf$overlap1 <- temp_dbf$INT_AREA/temp_dbf$CB_AREA #the overlap between the 3-way intersection and CB area 
  if(missing(pop_field)==FALSE){
    pop_position <- match(pop_field, names(temp_dbf)) #finds the col position of the pop field, provided by user 
    temp_dbf$pop_wt <- temp_dbf[, pop_position] * temp_dbf$overlap1 #the field for weighted population
    print(summary(temp_dbf$overlap1))
  }else{stop("A population field is not provided.")}
  if(missing(census_fields)==FALSE){
    temp_var_name <- paste(census_fields, "wt", sep="_") #the names for the census fields provided by user. Takes the names and appends 
    var_position <- match(census_fields, names(temp_dbf)) # wt to the end. Now finds col position of census fields  
    print(var_position)
    for(i in 1:length(census_fields)){
      temp_dbf$temp_name <- temp_dbf[, var_position[i]] * temp_dbf$overlap1
      colnames(temp_dbf)[colnames(temp_dbf)=="temp_name"] <- temp_var_name[i]
    }
    var_position2 <- match(temp_var_name, names(temp_dbf))
    print(temp_var_name) # a check on whether the data worked 
  }else{}
  print("Calculated overlap stage 1")
  temp_dbf$shp1_id <- as.character(temp_dbf[,id_position1]) # for ease of use, renaming the fields to collapse on
  temp_dbf$shp2_id <- as.character(temp_dbf[,id_position2])
  temp_dbf <- as.data.frame(temp_dbf)
  print(nrow(temp_dbf))
  if(missing(census_fields)==FALSE){
    flwA <- vector("list", length(temp_var_name))
    temp_var_name_shp1 <- paste("shp1", temp_var_name, sep="_")
    flwB <- vector("list", length(temp_var_name_shp1))
    temp_var_name_shp2 <- paste("shp2", temp_var_name, sep="_")
    flwC <- vector("list", length(temp_var_name_shp2))
    for(j in 1:length(temp_var_name)){
      flwA[[j]] <- aggregate(temp_dbf[,var_position2[j]], list(temp_dbf$DYAD_ID), sum)
    }
    print("Completed the aggregation of the Dyadic data")
    temp_storeA<-do.call("cbind", flwA)
    temp_seq <- seq(3,ncol(temp_storeA), by=2)
    temp_storeA <- temp_storeA[, -c(temp_seq)]
    colnames(temp_storeA)[1] <- "DYAD_ID"
    for(j in 2:ncol(temp_storeA)){
      colnames(temp_storeA)[j] <- temp_var_name[j-1]
    }
    #temp_dbfA <- summaryBy(pop_wt ~ DYAD_ID, data = temp_dbf, var.names = "pop_mean", FUN=c(mean), id=c(id1,id2))
    temp_dbfA <- aggregate(temp_dbf$pop_wt, list(temp_dbf$DYAD_ID, temp_dbf$shp1_id, temp_dbf$shp2_id), sum)
    colnames(temp_dbfA)[1] <- "DYAD_ID" 
    colnames(temp_dbfA)[2] <- id1 
    colnames(temp_dbfA)[3] <- id2 
    colnames(temp_dbfA)[4] <- "pop_wt" 
    #temp_dbfA <- merge(temp_dbfA, temp_dbfA_1, by="DYAD_ID")
    temp_dbfA <- merge(temp_dbfA, temp_storeA, by="DYAD_ID")
    for(j in 1:length(temp_var_name_shp1)){
      flwB[[j]] <- aggregate(temp_dbf[,var_position2[j]], list(temp_dbf$shp1_id), sum)
    }
    print("Completed the aggregation of the Shp1 data")
    
    temp_storeB<-do.call("cbind", flwB)
    temp_seqB <- seq(3,ncol(temp_storeB), by=2)
    temp_storeB <- temp_storeB[, -c(temp_seqB)]
    colnames(temp_storeB)[1] <- "shp1_id"
    for(j in 2:ncol(temp_storeB)){
      colnames(temp_storeB)[j] <- temp_var_name_shp1[j-1]
    }
    print("Completed the aggregation of the Shp2 data")
    temp_dbfB <- aggregate(temp_dbf$pop_wt, list(temp_dbf$shp1_id), sum)
    colnames(temp_dbfB)[1] <- "shp1_id" 
    colnames(temp_dbfB)[2] <- "first_shp_pop" 
    temp_dbfB <- merge(temp_dbfB, temp_storeB, by="shp1_id")
    print(names(temp_dbfB))
    for(j in 1:length(temp_var_name_shp2)){
      flwC[[j]] <- aggregate(temp_dbf[,var_position2[j]], list(temp_dbf$shp2_id), sum)
    }
    temp_storeC<-do.call("cbind", flwC)
    temp_seqC <- seq(3,ncol(temp_storeC), by=2)
    temp_storeC <- temp_storeC[, -c(temp_seqC)]
    colnames(temp_storeC)[1] <- "shp2_id"
    for(j in 2:ncol(temp_storeC)){
      colnames(temp_storeC)[j] <- temp_var_name_shp2[j-1]
    }
    temp_dbfC <- aggregate(temp_dbf$pop_wt, list(temp_dbf$shp2_id), sum)
    colnames(temp_dbfC)[1] <- "shp2_id" 
    colnames(temp_dbfC)[2] <- "second_shp_pop" 
    temp_dbfC <- merge(temp_dbfC, temp_storeC, by="shp2_id")
    print("Completed summarize command")
  }else{
    temp_dbfA <- aggregate(temp_dbf$pop_wt, list(temp_dbf$DYAD_ID, temp_dbf$shp1_id, temp_dbf$shp2_id), sum)
    colnames(temp_dbfA)[1] <- "DYAD_ID" 
    colnames(temp_dbfA)[2] <- id1 
    colnames(temp_dbfA)[3] <- id2 
    colnames(temp_dbfA)[4] <- "pop_wt"
    temp_dbfB <- aggregate(temp_dbf$pop_wt, list(temp_dbf$shp1_id), sum)
    colnames(temp_dbfB)[1] <- "shp1_id" 
    colnames(temp_dbfB)[2] <- "first_shp_pop"
    temp_dbfC <- aggregate(temp_dbf$pop_wt, list(temp_dbf$shp2_id), sum)
    colnames(temp_dbfC)[1] <- "shp2_id" 
    colnames(temp_dbfC)[2] <- "second_shp_pop"
  }
  
  print("Collapsed the data")
  temp_dbfA2 <- merge(temp_dbfA, temp_dbfB, by.x=id1, by.y="shp1_id")
  print(names(temp_dbfA2))
  temp_dbfA2 <- merge(temp_dbfA2, temp_dbfC, by.x=id2, by.y="shp2_id")
  temp_dbfA2$overlap1 <- temp_dbfA2$pop_wt/temp_dbfA2$first_shp_pop
  temp_dbfA2$overlap2 <- temp_dbfA2$pop_wt/temp_dbfA2$second_shp_pop
  if(missing(census_fields)==FALSE){
    new_names <- paste(census_fields, "pct_dyad", sep="_")
    new_namesB <- paste(census_fields, "pct_shp1", sep="_")
    new_namesC <- paste(census_fields, "pct_shp2", sep="_")
    var_position.x <- match(temp_var_name, names(temp_dbfA2))
    var_positionB <- match(temp_var_name_shp1, names(temp_dbfA2))
    print(var_positionB)
    var_positionC <- match(temp_var_name_shp2, names(temp_dbfA2))
    print(var_positionC)
    for(i in 1:length(temp_var_name)){
      temp_dbfA2$temp_field <- (temp_dbfA2[ ,var_position.x[i]] / temp_dbfA2$pop_wt)*100
      colnames(temp_dbfA2)[colnames(temp_dbfA2)=="temp_field"] <- new_names[i]
    }
    for(i in 1:length(temp_var_name_shp1)){
      temp_dbfA2$temp_fieldB <- (temp_dbfA2[ ,var_positionB[i]] / temp_dbfA2$first_shp_pop)*100
      colnames(temp_dbfA2)[colnames(temp_dbfA2)=="temp_fieldB"] <- new_namesB[i]
    }
    for(i in 1:length(temp_var_name_shp2)){
      temp_dbfA2$temp_fieldC <- (temp_dbfA2[ ,var_positionC[i]] / temp_dbfA2$second_shp_pop)*100
      colnames(temp_dbfA2)[colnames(temp_dbfA2)=="temp_fieldC"] <- new_namesC[i]
    }
  }else{}
  return(temp_dbfA2)
}
