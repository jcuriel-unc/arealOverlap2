#' Calculates the percentage of the population of the second shapefile correctly matched by knowing only the first level 
#' 
#' This function weights the population of the first level of geography by the proportion of the population with the second level of
#' geography that it shares the most overlap with. The data is then collapsed and divided by the population of the second level of 
#' geography in order to determine the population of the second level of geography that could be reached out to successfully by 
#' knowing only the first level of geography as opposed to point data. 
#' @param overlap_output The cleaned output from the overlapfunction. 
#' @param id1 The ID field of the first shapefile of interest
#' @param id2 The ID field of the second shapefile of interest  
#' @return The best match weighted population (i.e. how nested) for the second level of geography. The data frame values are as 
#' follows:
#' \itemize{
#'    \item id = The user specified ID for the second level of geography. 
#'    \item correctly_matched_pop = The weighted and summed population of the first level of geography with the second level of geography that
#'    it shares the most overlap with. 
#'    \item pop_wt = The calculated total population of the second level of geography
#'    \item correct_pct = The percentage of the population that would be correctly matched to the second level of geography knowing only 
#'    the information from the first level of geography as opposed to some more specific spatial information, such as points/addresses. 
#' 
#' }
#' @export
#' @examples
#' correctly_matched


correctly_matched <- function(overlap_output, id1, id2){
  list.of.packages <- c("dplyr")
  new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  overlap_output$id1 <- overlap_output[,id1]
  overlap_output$id2 <- overlap_output[,id2]
  matched_df <-overlap_output %>% 
    group_by(id1) %>%
    slice(which.max(overlap1))
  matched_df$correctly_matched_pop <- matched_df$overlap1 * matched_df$first_shp_pop
  pop_sum <- aggregate(matched_df$correctly_matched_pop, list(matched_df$id2), sum)
  colnames(pop_sum)[1] <- id2
  colnames(pop_sum)[2] <- "correctly_matched_pop"
  pop_sum2 <- aggregate(overlap_output$pop_wt, list(overlap_output$id2), sum)
  colnames(pop_sum2)[1] <- id2
  colnames(pop_sum2)[2] <- "pop_wt"
  pop_sum <- merge(pop_sum, pop_sum2, by=id2)
  pop_sum$correct_pct <- pop_sum$correctly_matched_pop/pop_sum$pop_wt
  return(pop_sum)
}