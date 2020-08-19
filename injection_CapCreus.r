# Templet filled for CapdeCreus data by I. Bartomeus using:

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
data <- read.csv("data/CapCreusNtw.csv")
head(data)


# Reference
reference <- list(doi = "10.1007/s00442-007-0946-1", # desirable
                  jstor = "null",
                  pmid = "null", # Might not have one? 
                  paper_url = "https://doi.org/10.1007/s00442-007-0946-1", # desirable
                  data_url = "null", 
                  author = "Ignasi Bartomeus",
                  year = "2005",
                  bibtex = "@article{bartomeus_contrasting_2008,
	                          title = {Contrasting effects of invasive plants in plant-pollinator networks},
	                          volume = {155},
	                          issn = {1432-1939},
	                          url = {https://doi.org/10.1007/s00442-007-0946-1},
	                          doi = {10.1007/s00442-007-0946-1},
	                          abstract = {The structural organization of mutualism networks, typified by interspecific positive interactions, is important to maintain community diversity. However, there is little information available about the effect of introduced species on the structure of such networks. We compared uninvaded and invaded ecological communities, to examine how two species of invasive plants with large and showy flowers (Carpobrotusaffine acinaciformis and Opuntiastricta) affect the structure of Mediterranean plantâpollinator networks. To attribute differences in pollination to the direct presence of the invasive species, areas were surveyed that contained similar native plant species cover, diversity and floral composition, with or without the invaders. Both invasive plant species received significantly more pollinator visits than any native species and invaders interacted strongly with pollinators. Overall, the pollinator community richness was similar in invaded and uninvaded plots, and only a few generalist pollinators visited invasive species exclusively. Invasive plants acted as pollination super generalists. The two species studied were visited by 43\% and 31\% of the total insect taxa in the community, respectively, suggesting they play a central role in the plantâpollinator networks. Carpobrotus and Opuntia had contrasting effects on pollinator visitation rates to native plants: Carpobrotus facilitated the visit of pollinators to native species, whereas Opuntia competed for pollinators with native species, increasing the nestedness of the plantâpollinator network. These results indicate that the introduction of a new species to a community can have important consequences for the structure of the plantâpollinator network.},
	                          number = {4},
	                          journal = {Oecologia},
	                          author = {Bartomeus, Ignasi and Vilà, Montserrat and Santamaría, Luís},
	                          month = apr,
	                          year = {2008},
	                          pages = {761--770}
                            }")
                  
# User
# Not usefull right now for people outside the Mangal project since they can't upload data yet.
user <- list(name = "Ignasi Bartomeus",
             email = "nacho.bartomeus@gmail.com", # Email where you can be reached
             orcid = "0000-0001-7893-4389", # ORCID_ID
             organization = "Estación Biológica de Doñana", # Ex: "Université de Sherbrooke"
             type = "user") # %in% c("administrator", "user")

# Dataset
dataset <- list(name        = "Bartomeus_2005",
                date        = "2005-00-00",
                description = "Plant-pollinator networks collected in Mediterranean scrublands, some of them invaded 
                                by exotic species", #Ex: "Food web structure of rocky intertidal communities in New England and Washington"
                public      = TRUE) #Is this available publicly

# Network
# If only one network (or if lat/lon and description doesn't vary between networks) in the dataset proceed to fill once the network list below
# If there is multiple networks, AND if the description/latitude/longitude varies between networks, what I used to do was to have .txt or .csv file (or can create a data_frame in R directly) with 3 columns.
# The columns were "network_description", "latitude", "longitude", and I for-looped over it during the injection since we can only inject one table at a time.
ntw_data <- data.frame(name = c("BAT1CA", "BAT2CA", "FRA1OP", "FRA2OP", 
                                "MED1CA", "MED2CA", "MED3CA", "MED4CA", 
                                "MIQ1OP", "MIQ2OP", "SEL1OP", "SEL2OP"),
                       network_description = paste("plant-pollintor network sampled in Cap de Creus region, Spain", 
                                                   c("", ", invaded by Carpobrotus affine acinaciformis", 
                                                         "", ", invaded by Opuntia stricta",
                                                         "", ", invaded by Carpobrotus affine acinaciformis",
                                                         "", ", invaded by Carpobrotus affine acinaciformis",
                                                         "", ", invaded by Opuntia stricta",
                                                         "", ", invaded by Opuntia stricta"), sep = ""),
                       latitude = c(42.352,
                                    42.354,
                                    42.417,
                                    42.417,
                                    42.324,
                                    42.323,
                                    42.320,
                                    42.319,
                                    42.398,
                                    42.398,
                                    42.301,
                                    42.300),
                       longitude = c(3.177,
                                     3.175,
                                     3.158,
                                     3.160,
                                     3.293,
                                     3.297,
                                     3.305,
                                     3.303,
                                     3.147,
                                     3.150,
                                     3.229,
                                     3.231))

head(ntw_data)

for(i in 1:6){ ##WARNING: Now ir overscripts network each time, so injection has to bee added into the loop
  network <- list(name = paste0("Bartomeus_", ntw_data$name[i]),
                  date = "2005-00-00",
                  lat = ntw_data$latitude[i], # Latitude
                  lon = ntw_data$longitude[i], # Longitude
                  srid = "epsg:3857", # Spatial reference system
                  description = ntw_data$network_description[i], # Might bring more precision than the dataset description ex: "Food web structure of an exposed rocky shore community, Pemaquid point, New England"
                  public = TRUE, # Are the data publicly available
                  all_interactions = FALSE) # Is the network recording ALL presence AND absence of interactions
}

# Attribute
# Used to describe an attribute that can be linked to Interaction table, Trait table and Environment table.
attribute <- list( name        = "Frequency", # Interaction: "Presence/Absence", "Frequency" etc., Trait: "body length", "mass" etc., Environment: "precipitation" etc.
                   table_owner = "interaction", # %in% c("interaction","trait","environment") 
                   description = "Frequency of interaction", # Interaction: "Presence or absence of interaction", Trait: "Body length of the organism", Environment: "Quantity of precipitation".
                   unit        = "Number of visits recorded per 6 minuts") # necessary if  it's a Trait or Environment attribute, facultative if Interaction attribute (ex: no units for Presence/Absence)

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

#NOTE from NACHO: I am bit lost here. I can't find where the interactions are stored. 
#would it work something like

interaction_data <- data.frame(network= data$site, #if needed inject per network looping through the 6 sites
                               sp_taxon_1 = data$gen_sp,
                               sp_taxon_2 = data$plant,
                               value = data$freq)
  
interaction <- list(date          = paste0(data$year, "-", data$month, "-", data$day), #"YEAR-MONTH-DAY", # Date of the recorded interactions
                    direction     = "UNDIRECTED", # Direction of the interaction
                    type          = "MUTUALISM",
                    method        = "OBSERVATION", # The general method with which the interaction was recorded
                    description   = "null", # Not necessary
                    public        = TRUE, # Are the data publicly available
                    lat           = "null", # Latitude #QUESTION: Can we extract this from the network table?
                    lon           = "null", # Longitude
                    srid          = "null") # Spatial reference system

####################################################################################################

# Node
# (Might be a weird table to make if the taxonomy is already well resolved, but we need it because sometimes in the original interaction matrices there are names like : Canis sp. so we want to link Canis sp. to only the genus "Canis" in the Taxonomy table.)
# Same as the interaction data, separate each nodes (taxon) by networks/sites into a list.
# We need a data_frame with two columns:
# First column (original_name): Names that were originally used in the interaction matrix, might be common name
# Second column (clear_name): Names that were taxonomically resolved i.e.: no "sp.", no whitespaces etc.
# To get the name resolved (if they aren't already) I used to use taxize::gnr_resolve()

####################################################################################################

# Taxonomy
# Check which taxon are already in the Mangal Taxonomy Endpoint
# We will only add the ones that aren't already in Mangal
server <- "https://mangal.io"
taxa_back_df <- data.frame()

for (i in 1:length(taxa_back)) {
  
  path <- httr::modify_url(server, path = paste0("/api/v2/","taxonomy/?name=", gsub(" ", "%20", taxa_back[i])))
  if (length(content(GET(url = path, config = httr::add_headers("Content-type" = "application/json")))) == 0) {
    
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
enviro_attribute <- list(name        = "NAME OF THE ENVIRONMENT ATTRIBUTE", # Ex: "annual rainfall"
                         table_owner = "environment",
                         description = "BRIEF DESCRIPTION", # Ex: "The annual rainfall of the study area"
                         unit        = "UNITS") # Ex: "mm"
# The actual environmental data
enviro_rain <- list(name  = "NAME OF THE ENVIRONMENTAL DATA", # Ex: "annual rainfall"
               lat   = LAT, # Latitude
               lon   = LON, # Longitude
               srid  = SRID, # Spatial reference system
               date  = "YEAR-MONTH-DAY", # Date of the recorded environmental data
               value = VALUE) # Value 

#########################################################################################################

# Trait
#NOTE: I have no trait variables, so I ignore this part.
# Coming soon
# Example:
# The attribute related to the trait data
trait_attribute <- list(name        = "NAME OF THE TRAIT ATTRIBUTE", # Ex: "Body size"
                        table_owner = "trait",
                        description = "Average body length", # Ex: "Average body length"
                        unit        = "UNITS") # Ex: "mm"
# The actual trait data
# Create or import a data_frame with three columns:
# First column is the taxons names ("taxon")
# Second column is the trait name ("name")
# Third column is the trait value ("value")

##########################################################################################################
