### Script to create the yougov ext set up 
install.packages(c("devtools", "roxygen2"))  # install dependecies if not already here 
library("devtools")
#library("roxygen2")
library(usethis)
parentDirectory <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(parentDirectory)
### read in the zip code data from ACS 
## version of stringr necessary to run yougov: 0.6.2
##create("yougovExt")
setwd("arealOverlap")
###proceed to create data in the raw folder

#usethis::use_data_raw(name = 'sample_data')
##usethis::use_data(sample_data, overwrite = T)
#save(sample_data, file = "data/sample_data.rda")


## These create empty files to be filled with user entered data 
file.create("R/weight_overlap_new.R")


# Create skelton if title, description, import, etc. 
sinew::makeOxygen(sample_data)

document()

devtools::build()
setwd(parentDirectory)
install.packages("arealOverlap_0.0.1.0000.tar.gz", type="source", repos=NULL, dependencies = TRUE)
library(arealOverlap) # was able to use both stringr and yougov; good 
#install("zipWRUext2")

### testing out fxns and such 
moe(sample_data$weight)
library(stringr)
test_relabel<- relabel_crunch(ds$Racial_Resentment_1_A)
sample_data_sub <- subset(sample_data,is.na(Racial_Resentment_1_A)==F)
topline_results<-topline_moe(sample_data_sub, x="Racial_Resentment_1_A", weight1="weight", 
            round_t=TRUE, collapse_arg=TRUE, ds$Racial_Resentment_1_A)
topline_results

moe_plotr_topline(topline_results, x,y, weight1="weight", round_t=TRUE, collapse_arg=TRUE, ds_var)
moe_plotr_topline(topline_results, ds_var=ds$Racial_Resentment_1_A, 
                  x="Racial_Resentment_1_A", 
                  xtitle="")
## crosstab results 
crosstab1 <- clean_moe_crosstab(data=sample_data_sub, x="officials_treat", y="Racial_Resentment_1_A", 
                                weight1 = "weight",
                                collapse_arg=TRUE, ds_var =  ds$Racial_Resentment_1_A)
crosstab1

test_crosstab_plot <- moe_plotr_crosstab(df=crosstab1, x="officials_treat", y="Racial_Resentment_1_A",
                                         ds_var=ds$Racial_Resentment_1_A, leg_title = "Treatment #",
                                         pct_var="pct_by_x", ytitle="Percent", color_vec_choice=c(""))
