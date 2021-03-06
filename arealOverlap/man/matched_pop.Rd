% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/matchedpop1.R
\name{matched_pop}
\alias{matched_pop}
\title{Calculates the first level of geography's population that is nested}
\usage{
matched_pop(overlap_output, id)
}
\arguments{
\item{overlap_output}{The cleaned output from the overlapfunction.}

\item{id1}{The ID field of the first shapefile of interest}
}
\value{
The data frame with the herfindahl index weighted population (i.e. how nested) for the first level of geography. The values
are as follows:
\itemize{
   \item id = The user specified ID for the first shapefile 
   \item herf_index = The herfindahl index of how nested the first level of geography is within the second level of geography. 
   Scores closer to 1 reflect complete nesting, and 0 non-nesting.
   \item population = The total population for the first level of geography 
   \item weighted_pop = The total population of the first level of geography multiplied by the herfindahl index. 

}
}
\description{
Calculates the herfindahl index and weights the first level of geography's population by herfindahl index
}
\examples{
overlap115 <- overlapfunction(zip_cd115V, id1 =  "ZCTA5CE10", id2="GEOID", pop_field = "POP2010")
test3<-matched_pop(overlap115, "ZCTA5CE10")
}
