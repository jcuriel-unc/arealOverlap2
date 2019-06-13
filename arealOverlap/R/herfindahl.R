#' Calculates the herfindahl index/nestedness of a geographic unit
#' 
#' The function accepts the output of the overlapfunction and calculates the sum of squared population proportions for for the first level
#' of geography and all of its dyads. The final score is between 1 and 0, where 1 is complete nesting, and values approaching 0 are 
#' completely split across different geographies and heterogenous. 
#' @param overlap_output The cleaned output from the overlapfunction. 
#' @param id1 The ID field of the first shapefile
#' @return The data frame with the herfindahl index (i.e. how nested) the first level of geography is by population. The following are the 
#' fields:
#' \itemize{
#'    \item id = The specified user ID from the first shapefile 
#'    \item herf_index = The herfindahl index of how nested the first level of geography is within the second level of geography. 
#'    Scores closer to 1 reflect complete nesting, and 0 non-nesting. 
#' 
#' } 
#' @export
#' @examples
#' overlap115 <- overlapfunction(zip_cd115V, id1 =  "ZCTA5CE10", id2="GEOID", pop_field = "POP2010")
#' test1<-herfindahl(overlap115, "ZCTA5CE10")

herfindahl <- function(overlap_output, id){
  herfindahl <- aggregate((overlap_output$overlap1)^2, list(overlap_output[,id]), sum)
  colnames(herfindahl)[1] <- id
  colnames(herfindahl)[2] <- "herf_index"
  return(herfindahl)
}