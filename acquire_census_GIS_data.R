# Script by Joseph Holler for acquiring GIS data from the Census, 11/24/2020

# Prior to using this script, sign up for your own Census API Key at https://api.census.gov/data/key_signup.html
# Replace every instance of <key> in this script with your Census API key

# Read more about tidycensus at https://walker-data.com/tidycensus/ 

#install and load tidycensus package, for using US Census, and sf, for spatial data formats
install.packages("tidycensus")
install.packages("sf")
library(tidycensus)
library(sf)

# load reference tables
vars <- load_variables(2018, "acs5", cache = TRUE)
varsSubj <- load_variables(2018, "acs5/subject", cache = TRUE)
varsProf <- load_variables(2018, "acs5/profile", cache = TRUE)

# vars contains B and C tables which may work for block groups
# varsSubj contains subject tables which only work for tracts or larger
# varsProf contains profile tables which only work for tracts or larger

# example usage: download non-Hispanic white population data by tract for Bronx, NY based on 2018 ACS 5-year average
bronxBG <- get_acs(state="NY", county="005", geography="block group", 
                   variables=c(white="B03002_003",totalre="B03002_001"), 
                   year=2018, geometry=TRUE, output="wide", key="<key>")

# write results to a shapefile
dir.create("data")
st_write(bronxBG, "data/bronxBG.shp")

# example usage: download poverty data by tract for Bronx, NY based on 2018 ACS 5-year average (this is not available at block group level)
bronxTract <- get_acs(state="NY", county="005", geography="tract", 
                      variables=c(pop_ps="S1701_C01_001", belpov="S1701_C02_001"),
                      year=2018, geometry=TRUE, output="wide", key="<key>")

# write results to a shapefile
st_write(bronxTract, "data/bronxTract.shp")

# make a choropleth map in R with ggplot
install.packages("ggplot2")
library(ggplot2)

# map the poverty data
ggplot() + 
  geom_sf(data=bronxTract, aes(fill=cut_interval(belpovE/pop_psE,5)), color = "grey")+
  scale_fill_brewer(palette="Purples")+
  guides(fill=guide_legend(title="Percent", title.hjust=0.5)) +
  labs(title = "Population Under Poverty Level") +
  theme(plot.title = element_text(hjust = 0.5))