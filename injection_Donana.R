# Templet filled for Doñana data by I. Bartomeus using:

# R Guidelines / Template for Mangal data injection
# More information on Mangal and API Endpoints at https://mangal.io and https://mangal.io/doc/api/
# This guideline is an aggregation of different script parts coming from different people at the Mangal project.
# Author of this guideline : Benjamin Mercier
# Date : August 2020

# All caps field must be filled, null fields are optional.
# Use one formatting/injection script per dataset. A dataset can contain multiple networks/sites.

###################################################################################################
# Set the metadata
# Fill the information in the lists below to the best of your knowledge

#load data needed later on: 
#load("data/all_interactions.rda") #date missing
all_interactions <- read.csv("data/master_transects_2015.csv")
load("data/sites.rda")
head(all_interactions)
head(sites)

# Reference
reference <- list(doi = "10.1101/629931", # desirable
                  jstor = "null",
                  pmid = "null", # Might not have one? 
                  paper_url = "https://doi.org/10.1101/629931", # desirable
                  data_url = "null", 
                  author = "Ignasi Bartomeus",
                  year = "2015",
                  bibtex = "@article{magrach_2015,
	                          title = {Niche complementarity among pollinators increases community-level plant reproductive success},
	                          volume = {},
	                          issn = {},
	                          url = {https://doi.org/10.1101/629931},
	                          doi = {10.1101/629931},
	                          abstract = {Our understanding of how the structure of species interactions shapes natural communities has increased, particularly regarding plant-pollinator interactions. However, research linking pollinator diversity to reproductive success has focused on pairwise plant-pollinator interactions, largely overlooking community-level dynamics. Here, we present one of the first empirical studies linking pollinator visitation to plant reproduction from a community-wide perspective. We use a well-replicated dataset encompassing 16 plant-pollinator networks and data on reproductive success for 19 plant species from Mediterranean shrub ecosystems. We find that statistical models including simple visitation metrics are sufficient to explain the variability observed. However, a mechanistic understanding of how pollinator diversity affects reproductive success requires additional information on network structure. Specifically, we find positive effects of increasing complementarity in the plant species visited by different pollinators on plant reproductive success. Hence, maintaining communities with a diversity of species but also of functions is paramount to preserving plant diversity.},
	                          number = {629931},
	                          journal = {bioRxiv, ver. 7 peer-reviewed by Peer Community in Ecology},
	                          author = {Ainhoa Magrach, Francisco P. Molina, Ignasi Bartomeus},
	                          month = jun,
	                          year = {2020},
	                          pages = {}
                            }")

# User
# Not usefull right now for people outside the Mangal project since they can't upload data yet.
user <- list(name = "Ignasi Bartomeus",
             email = "nacho.bartomeus@gmail.com", # Email where you can be reached
             orcid = "0000-0001-7893-4389", # ORCID_ID
             organization = "Estación Biológica de Doñana", # Ex: "Université de Sherbrooke"
             type = "user") # %in% c("administrator", "user")

# Dataset
dataset <- list(name        = "Bartomeus_2015",
                date        = "2015-00-00",
                description = "Plant-pollinator networks collected in Mediterranean scrublands", #Ex: "Food web structure of rocky intertidal communities in New England and Washington"
                public      = TRUE) #Is this available publicly

# Network
# If only one network (or if lat/lon and description doesn't vary between networks) in the dataset proceed to fill once the network list below
# If there is multiple networks, AND if the description/latitude/longitude varies between networks, what I used to do was to have .txt or .csv file (or can create a data_frame in R directly) with 3 columns.
# The columns were "network_description", "latitude", "longitude", and I for-looped over it during the injection since we can only inject one table at a time.

sites$network_description <- "One of the 16 plant-pollintor networks sampled in the Doñana National Park influence area, Spain"
ntw_data <- data.frame(name = sites$Site_ID,
                       network_description = sites$network_description,
                       latitude = sites$latitude,
                       longitude = sites$longitude)

#head(ntw_data)

for(i in 1:16){ ##WARNING: Now it overscripts network each time, so injection has to bee added into the loop. Ben: That is exactly what I used to do!
  network <- list(name = paste0("Bartomeus_2015_", ntw_data$name[i]), # Just added the year after the name.
                  date = "2015-00-00",
                  lat = ntw_data$latitude[i], # Latitude
                  lon = ntw_data$longitude[i], # Longitude
                  srid = 3857, # Spatial reference system
                  description = ntw_data$network_description[i], # Might bring more precision than the dataset description ex: "Food web structure of an exposed rocky shore community, Pemaquid point, New England"
                  public = TRUE, # Are the data publicly available
                  all_interactions = FALSE) # Is the network recording ALL presence AND absence of interactions
                  print(network$name)
}

# Attribute
# Used to describe an attribute that can be linked to Interaction table, Trait table and Environment table.
attribute <- list( name        = "Frequency", # Interaction: "Presence/Absence", "Frequency" etc., Trait: "body length", "mass" etc., Environment: "precipitation" etc.
                   table_owner = "interaction", # %in% c("interaction","trait","environment") 
                   description = "Frequency of interaction in number of flowers visited per observation recorded along 100m, 30 min transects. Each transect was visited seven times over one season", # Interaction: "Presence or absence of interaction", Trait: "Body length of the organism", Environment: "Quantity of precipitation".
                   unit        = "Number of visits") # necessary if  it's a Trait or Environment attribute, facultative if Interaction attribute (ex: no units for Presence/Absence)

####################################################################################################

# Interaction
# If there is multiple network, separate the interaction data_frame by networks/sites into a list. 
# The interaction "matrices" have to be long format (NO ADJACENCY MATRICES):
# First column is named "sp_taxon_1" (making the interaction), second column is named "sp_taxon_2" (receiving the interaction) and third column named "value" is the interaction value.
# Interaction value is either 1/0 if it's Presence/Absence, or a whole/real positive number if it's a frequency or relative diet.

# All the informations in the list below can vary between each interaction in the network. If they don't vary, just fill once the list below.
# If they vary, they can be "manually" added as a column to the LONG FORMAT interaction matrix.
# For example, in the same network, we could have predators eating their prey (type = "predation") and herbivores grazing on plants (type = "herbivory")
# This way, we "cbind" a column named "type", and on each line where we have predation, the value of the column "type" will be "predation". (Same logic for the herbivory)
# If an argument varies in a network, remove it from the list below. (Because in the injection process, each argument is cbinded to the long format interaction matrix)
all_interactions <- subset(all_interactions, Out == "transect") #remove out of transect observations.
all_interactions <- all_interactions[!(all_interactions$Plant_gen_sp == "NA NA"),]
all_interactions[which(is.na(all_interactions$Frequency)),"Frequency"] <- 1
head(all_interactions)

interaction_data <- data.frame(network= all_interactions$Site_ID, #if needed inject per network looping through the 12 sites
                               sp_taxon_1 = all_interactions$Pollinator_gen_sp,
                               sp_taxon_2 = all_interactions$Plant_gen_sp,
                               value = all_interactions$Frequency,
                               date = paste0(all_interactions$Year, "-", 
                                             all_interactions$Month, "-", 
                                             all_interactions$Day)) 

interaction_data$date <- as.Date(interaction_data$date, format = "%Y-%m-%d") # Ben: Reformated the date to have the 0 for the months and days.
interaction_data <- split(interaction_data, f = interaction_data$network, drop = TRUE) # Ben : The information in the dataframe is exactly what we need. What I used to do though was separate each dataframe per network into a list, so I could embedded the injection of the network data and the interaction data in the same "for loop", as the "i" will get the related data from network and interaction.
interaction_data <- lapply(interaction_data, function(x) {x[,-1]}) # Probably you need to drop other variables.

# Ben: I removed the date field, because it was a field that varied between interaction, so I added it to the interaction dataframe.
interaction <- list(direction     = "UNDIRECTED", # Direction of the interaction
                    type          = "MUTUALISM",
                    method        = "OBSERVATION", # The general method with which the interaction was recorded
                    description   = "null", # Not necessary
                    public        = TRUE, # Are the data publicly available
                    lat           = ntw_data[i,"lat"], # Latitude #QUESTION: Can we extract this from the network table? Ben: Yes that is exactly what I used to do!!!
                    lon           = ntw_data[i, "lon"], # Longitude
                    srid          = 3857) # Spatial reference system

####################################################################################################

# Node
# (Might be a weird table to make if the taxonomy is already well resolved, but we need it because sometimes in the original interaction matrices there are names like : Canis sp. so we want to link Canis sp. to only the genus "Canis" in the Taxonomy table.)
# Same as the interaction data, separate each nodes (taxon) by networks/sites into a list.
# We need a data_frame with two columns:
# First column (original_name): Names of all the taxons that were originally used in the interaction matrix, might be common name
# Second column (clear_name): Names that were taxonomically resolved i.e.: no "sp.", no whitespaces etc.
# To get the name resolved (if they aren't already) I used to use taxize::gnr_resolve()
# Ben: 
library(taxize)
# Creating the node dataframe for each network. First column is the original_name found in the network, and second column (name_clear) are the names resolved i.e.: without "sp" etc.
nodes <- interaction_data
nodes <- lapply(nodes, function(x) unique(c(x$sp_taxon_1, x$sp_taxon_2)))
#nodes_temp <- lapply(nodes, function(x) gsub("[A-Z]{1}[[:digit:]]{1,}$", "", x)) # Removing the capital letters/numbers at the end, and the "sp".
nodes_temp <- lapply(nodes, function(x) gsub(" sp", "", x))
nodes_temp <- lapply(nodes_temp, function(x) gsub(" NA", "", x))
nodes_temp <- lapply(nodes_temp, function(x) gsub(" morpho1", "", x))
nodes_temp <- lapply(nodes_temp, function(x) gsub(" morpho2", "", x))
nodes <- purrr::map2(nodes, nodes_temp, ~cbind(as.data.frame(.x), as.data.frame(.y))) # Cbinding the two back together into a dataframe

#NACHO: The nodes object is full of numbres, not characters... but I can't spot why.

# Getting the name resolved
resolved_nodes <- lapply(nodes, function(x) {as.data.frame(taxize::gnr_resolve(x[,".y"], canonical = TRUE, highestscore = TRUE, best_match_only = TRUE))})
NA_nodes <- lapply(resolved_nodes, function(x) attributes(x)$not_known) # Getting the taxons that aren't recognized. Will check them manually on ITIS/GBIF/Internet..


# Matching the name back into nodes
nodes <- purrr::map2(nodes, resolved_nodes, ~dplyr::left_join(.x, .y, by = c(".y" = "user_supplied_name"))) # Matching back the resolved name to the original_name
nodes <- lapply(nodes, function(x) x[,c(".x", "matched_name2")]) # Selecting only the column we need
nodes <- lapply(nodes, function(x) `colnames<-`(x, c("original_name", "name_clear"))) # Changing column names

####################################################################################################

# Taxonomy
# Check which taxon are already in the Mangal Taxonomy Endpoint
# We will only add the ones that aren't already in Mangal

taxa_back <- unique(do.call(rbind, nodes[1:6])$name_clear)

server <- "https://mangal.io"
taxa_back_df <- data.frame()

for (i in 1:length(taxa_back)) {
  
  path <- httr::modify_url(server, path = paste0("/api/v2/","taxonomy/?name=", gsub(" ", "%20", taxa_back[i])))
  if (length(httr::content(httr::GET(url = path, config = httr::add_headers("Content-type" = "application/json")))) == 0) {
    
    taxa_back_df[nrow(taxa_back_df)+1, 1] <- taxa_back[i]
  }
}

# Create column to store the different taxonomy database IDs
taxa_back_df[, "bold"] <- NA
taxa_back_df[, "eol"]  <- NA
taxa_back_df[, "tsn"]  <- NA
taxa_back_df[, "ncbi"] <- NA

# Loop to get the IDs for each taxon
for (i in 1:nrow(taxa_back_df)) {
  try (expr = (taxa_back_df[i, "bold"] <- get_boldid(taxa_back_df[i, 1], row = 5, verbose = FALSE)[1]), silent = TRUE)
  try (expr = (taxa_back_df[i, "eol"] <- get_eolid(taxa_back_df[i, 1], row = 5, verbose = FALSE)), silent = TRUE) # Might need a key?
  try (expr = (taxa_back_df[i, "tsn"] <- get_tsn(taxa_back_df[i, 1], row = 5, verbose = FALSE, accepted = TRUE)[1]), silent = TRUE)
  try (expr = (taxa_back_df[i, "ncbi"] <- get_uid(taxa_back_df[i, 1], row = 5, verbose = FALSE)[1]), silent = TRUE)
}

########################################################################################################

# Environment
#NOTE: I have no environment variables, so I ignore this part.
# Coming soon
# Example:
# The attribute related to the environmental data
# enviro_attribute <- list(name        = "NAME OF THE ENVIRONMENT ATTRIBUTE", # Ex: "annual rainfall"
#                          table_owner = "environment",
#                          description = "BRIEF DESCRIPTION", # Ex: "The annual rainfall of the study area"
#                          unit        = "UNITS") # Ex: "mm"
# The actual environmental data
# enviro_rain <- list(name  = "NAME OF THE ENVIRONMENTAL DATA", # Ex: "annual rainfall"
#                lat   = LAT, # Latitude
#                lon   = LON, # Longitude
#                srid  = SRID, # Spatial reference system
#                date  = "YEAR-MONTH-DAY", # Date of the recorded environmental data
#                value = VALUE) # Value 

#########################################################################################################

# Trait
#NOTE: I have no trait variables, so I ignore this part.
# Coming soon
# Example:
# The attribute related to the trait data
# trait_attribute <- list(name        = "NAME OF THE TRAIT ATTRIBUTE", # Ex: "Body size"
#                         table_owner = "trait",
#                         description = "Average body length", # Ex: "Average body length"
#                         unit        = "UNITS") # Ex: "mm"
# The actual trait data
# Create or import a data_frame with three columns:
# First column is the taxons names ("taxon")
# Second column is the trait name ("name")
# Third column is the trait value ("value")

##########################################################################################################
