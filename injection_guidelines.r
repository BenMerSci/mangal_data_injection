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

# Reference
reference <- list(doi = "null", # desirable
                  jstor = "null",
                  pmid = "null", # Might not have one? 
                  paper_url = "null, URL of the attached paper", # desirable
                  data_url = "null, URL of the attached data", 
                  author = "FIRST AUTHOR NAME",
                  year = "YEAR, EX: 1990",
                  bibtex = "BIBTEX LONG FORMAT")
                  
# User
# Not usefull right now for people outside the Mangal project since they can't upload data yet.
user <- list(name = "FIRST AND LAST NAME",
             email = "@", # Email where you can be reached
             orcid = "XXXX-XXXX-XXXX-XXXX", # ORCID_ID
             organization = "NAME OF ORGANIZATION", # Ex: "Université de Sherbrooke"
             type = "TYPE OF USER") # %in% c("administrator", "user")

# Dataset
dataset <- list(name        = "AUTHORLASTNAME_YEAR",
                date        = "YEAR-MONTH-DAY",
                description = "DESCRIPTION OF THE DATASET COLLECTED", #Ex: "Food web structure of rocky intertidal communities in New England and Washington"
                public      = TRUE/FALSE) #Is this available publicly

# Network
# If only one network (or if lat/lon and description doesn't vary between networks) in the dataset proceed to fill once the network list below
# If there is multiple networks, AND if the description/latitude/longitude varies between networks, what I used to do was to have .txt or .csv file (or can create a data_frame in R directly) with 3 columns.
# The columns were "network_description", "latitude", "longitude", and I for-looped over it during the injection since we can only inject one table at a time.
network <- list(name = "NAME_DATE_IDNUMBER EX: Mercier_2020_1",
                 date = "YEAR-MONTH_DAY",
                 lat = LAT, # Latitude
                 lon = LON, # Longitude
                 srid = SRID, # Spatial reference system
                 description = "Description of the network", # Might bring more precision than the dataset description ex: "Food web structure of an exposed rocky shore community, Pemaquid point, New England"
                 public = TRUE/FALSE, # Are the data publicly available
                 all_interactions = TRUE/FALSE) # Is the network recording ALL presence AND absence of interactions

# Attribute
# Used to describe an attribute that can be linked to Interaction table, Trait table and Environment table.
attribute <- list(name        = "NAME OF THE ATTRIBUTE", # Interaction: "Presence/Absence", "Frequency" etc., Trait: "body length", "mass" etc., Environment: "precipitation" etc.
                   table_owner = "API ENDPOINT NAME", # %in% c("interaction","trait","environment") 
                   description = "BRIEF DESCRIPTION OF THE ATTRIBUTE", # Interaction: "Presence or absence of interaction", Trait: "Body length of the organism", Environment: "Quantity of precipitation".
                   unit        = "UNITS") # necessary if  it's a Trait or Environment attribute, facultative if Interaction attribute (ex: no units for Presence/Absence)

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

interaction <- list(date          = "YEAR-MONTH-DAY", # Date of the recorded interactions
              direction     = "DIRECTED/UNDIRECTED/UNKNOWN", # Direction of the interaction
              type          = "COMPETITION, AMENSALISM, NEUTRALISM, COMMENSALISM, MUTUALISM, PARASITISM, PREDATION, HERBIVORY, SYMBIOSIS, SCAVENGER, DETRITIVORE, UNSPECIFIED or CONSUMPTION"
              method        = "OBSERVATION/BIBLIO/EXPERIMENTAL", # The general method with which the interaction was recorded
              description   = "null", # Not necessary
              public        = TRUE/FALSE, # Are the data publicly available
              lat           = LAT, # Latitude
              lon           = LON, # Longitude
              srid          = SRID) # Spatial reference system

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
  try (expr = (taxa_back_df[i, "eol"] <- get_eolid(taxa_back_df[i, 1], row = 5, verbose = FALSE, silent = TRUE) # Might need a key?
  try (expr = (taxa_back_df[i, "tsn"] <- get_tsn(taxa_back_df[i, 1], row = 5, verbose = FALSE, accepted = TRUE)[1]), silent = TRUE)
  try (expr = (taxa_back_df[i, "ncbi"] <- get_uid(taxa_back_df[i, 1], row = 5, verbose = FALSE)[1]), silent = TRUE)
}

########################################################################################################

# Environment
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
