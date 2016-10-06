##### Script for automatically retrieving Census ACS data 
##### Date Modified: 10/5/2016
##### Notes/To Do
### Look into re-creating this as a standalone executable
### uncomment large query section
### more elegant way to rename cols for query df
### issue with commas in column names when opening the csv in excel

##### Install Packages (Uncomment If You Don't Have These)
#install.packages(c("acs", "tigris"))
#####

##### Import Packages, trying not to use more than necesary 
library(acs)
library(tigris)
#####

##### Functions
import.csv <- function(filename) {
  return(read.csv(filename, sep = ",", header = TRUE, na.strings = c("NA")))
}
# utility function for export to csv file
write.csv <- function(ob, filename) {
  write.table(ob, filename, quote = FALSE, sep = ",", row.names = FALSE)
}
#####

##### House Work Prior to Query
API_KEY <- "985b6faddcf29a1751a27c944fe9bcb230112f36"
api.key.install(API_KEY)


##### Manually set parameters for query, change as necessary
#### see docu re proper input and further geos: https://cran.r-project.org/web/packages/acs/acs.pdf

##Geos
#state can by 2 digit FIPS or 2 letter postal code
state_list <- c("NY")
#county can be numeric fips codes or county names
county_list <- c(5, 47, 61, 81, 85)
#tract must be FIPS code, keep trailing zeros, can drop leading
tract_list <- "*"
#block groups must be FIPS cosdes
block_group_list <- NA
#make geo object
geo <- geo.make(state = state_list, county = county_list, tract = tract_list, block.group = block_group_list)

## Temporal
# last year in query, e.g. 2011 for 2006-2011 5 year
last_year <- 2014
# span for query, eg. 5 years
span_years <- 5

## Dataset
# dataset to query, e.g. acs or sf1
dataset <- "acs"
## Table Name
# name of table to be requested, e.g. "B01003"
table_name <- "B01003"


##### Read in CSV for large queries, place the csv in the same directory as this script and name it: "query_geos.csv"
##### CSV should have a record for each geo combination desired
##### commented out for now to test api methods
##### Must have following columns in the following order:
# State - 2 digit postal or FIPScode for states
# County - numeric fips code for counties, put NA's if not desired
# Tracks - numeric fips code for tracts, put NA's if not desired
# Block_Groups - numeric fips code for BGs, put NA's if not desired
# large_query <- import.csv("query_geos.csv")
# 
# state_list <- large_query[[1]]
# county_list <- large_query[[2]]
# tract_list <- large_query[[3]]
# block_group_list <- large_query[[4]]

##### fetch query
query_result <- acs.fetch(endyear = last_year, span = span_years, geography = geo, dataset = dataset,
                          table.number = table_name, col.names = "pretty")

##### convert acs object to data frame
temp <- as.data.frame(query_result@estimate)
colnames(temp) <- lapply(colnames(temp), function(x) paste(x, "Estimate"))
temp2 <- as.data.frame(query_result@standard.error)
colnames(temp2) <- lapply(colnames(temp2), function(x) paste(x, "Std. Error"))
query_df <- cbind(query_result@geography, temp, temp2)
rm("temp", "temp2")

##### Write out data frame as a CSV
write.csv(query_df, "Census_API_Query.csv")


