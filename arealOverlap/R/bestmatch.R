#' Matches the first level of geography to the second level of geography that it is the most nested in
#' 
#' This function collapses the overlapfunction output by the first level of geography so that it can be mathed with the second level
#' of geography that it shares the most population.  
#' @param overlap_output The cleaned output from the overlapfunction. 
#' @param id1 The ID field of the first shapefile of interest 
#' @return The cleaned output with the first shapefile matched to the second level of geography for which it shares the most population
#' @export
#' @examples
#' overlap115 <- overlapfunction(zip_cd115V, id1 =  "ZCTA5CE10", id2="GEOID", pop_field = "POP2010")
#' test4 <- best_match(overlap115, "ZCTA5CE10" )



best_match <- function(overlap_output, id1){
  list.of.packages <- c("dplyr")
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  overlap_output$id1 <- overlap_output[,id1]
  matched_df <-overlap_output %>% 
    group_by(id1) %>%
    slice(which.max(overlap1))
  matched_df$correctly_matched_pop <- matched_df$overlap1 * matched_df$first_shp_pop
  return(matched_df)
}