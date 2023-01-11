library(httr)
library(rgdal) 
library(sf) 
library(sp) 
library(rgeos)

#create a funciton that will input plot codes and call to arcgis repo for unitboundaries
#or figure out whytf the download.file does not work on this computer


setwd("C:/Users/kseeger/OneDrive - DOI/Desktop/GIT_RSTUDIO/SIP_NPS_CODE/Mapping")

# Get park unit boundary data ----
park_code <- "FOMA"
  # KATE, ENTER 4-LETTER PARK CODE HERE
  
unitBoundaryURL <- paste0("https://services1.arcgis.com/fBc8EJBxQRMcHlei/ArcGIS/rest/services/IMD_Units_Generic_areas_of_analysis_(AOAs)_-_IMD_BND_ALL_UNITS_AOA_nad_py_view/FeatureServer/0/query?where=UNITCODE+%3D+%27", park_code, "%27&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&distance=&units=esriSRUnit_Meter&relationParam=&outFields=*&returnGeometry=true&maxAllowableOffset=&geometryPrecision=&outSR=4326&gdbVersion=&returnDistinctValues=false&returnIdsOnly=false&returnCountOnly=false&returnExtentOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&resultOffset=&resultRecordCount=&f=geojson") # save output as WGS84

#paste0("https://gis.data.ca.gov/")

#shiny::req(http_status(GET(unitBoundaryURL))$category=="Success") 

tempUnitOutput <- "tempUnit.geojson"

#download.file(unitBoundaryURL, tempUnitOutput, method = libcurl) # readOGR geoJSON driver needs dsn to be a local file, so download the file first, then read it
#checking error code below
imported_dat <- tryCatch(readOGR(dsn = unitBoundaryURL, dropNULLGeometries = FALSE), error=function(e) print("Error retrieving data")) # return error message if problems still arise with downloading from web services

#shiny::req(class(imported_dat)=="SpatialPolygonsDataFrame")
imported_dat <- spTransform(imported_dat, CRS("+proj=longlat +datum=WGS84")) # convert to WGS84

# Check for problems with self-intersections, etc. These problems should be fixed in the updated version of LandscapeDynamics
if(any(sf::st_is_valid(sf::st_as_sf(imported_dat))) == FALSE) {
  temp_sf <- sf::st_make_valid(sf::st_as_sf(imported_dat))
  imported_dat <- sf:::as_Spatial(temp_sf)
}

unlink("tempUnit.geojson")
plot(imported_dat)
