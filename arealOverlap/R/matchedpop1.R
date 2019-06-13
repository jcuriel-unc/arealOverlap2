#' Calculates the first level of geography's population that is nested
#' 
#' Calculates the herfindahl index and weights the first level of geography's population by herfindahl index 
#' @param overlap_output The cleaned output from the overlapfunction. 
#' @param id1 The ID field of the first shapefile of interest 
#' @return The data frame with the herfindahl index weighted population (i.e. how nested) for the first level of geography. The values
#' are as follows:
#' \itemize{
#'    \item id = The user specified ID for the first shapefile 
#'    \item herf_index = The herfindahl index of how nested the first level of geography is within the second level of geography. 
#'    Scores closer to 1 reflect complete nesting, and 0 non-nesting.
#'    \item population = The total population for the first level of geography 
#'    \item weighted_pop = The total population of the first level of geography multiplied by the herfindahl index. 
#' 
#' }
#' @export
#' @examples
#' overlap115 <- overlapfunction(zip_cd115V, id1 =  "ZCTA5CE10", id2="GEOID", pop_field = "POP2010")
#' test3<-matched_pop(overlap115, "ZCTA5CE10")



matched_pop <- function(overlap_output, id){
  herfindahl <- aggregate((overlap_output$overlap1)^2, list(overlap_output[,id]), sum)
  colnames(herfindahl)[1] <- id
  colnames(herfindahl)[2] <- "herf_index"
  pop_sum <- aggregate(overlap_output$pop_wt, list(overlap_output[,id]), sum)
  colnames(pop_sum)[1] <- id
  colnames(pop_sum)[2] <- "population"
  pop_sum$population <- ceiling(pop_sum$population)
  #pop_sum$population <- floor(pop_sum$population,1)
  weighted_df <- merge(herfindahl, pop_sum, by=id)
  weighted_df$weighted_pop <- weighted_df$population * weighted_df$herf_index
  return(weighted_df)
}