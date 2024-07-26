# =============================================================================
# Create report (LSMS Paradata Tool - Module Stats)
# =============================================================================

# -----------------------------------------------------------------------------
# 1) Data Preparations
# -----------------------------------------------------------------------------

# load packages and functions
source("R/0_load_requirements.R")

# prepare paradata
source("R/0_extract_and_clean_paradata1.R")

# Run the line below to see a list of all section names. 
print(unique(data$section[!is.na(data$section)])) 

# -----------------------------------------------------------------------------
# 2) User Inputs
# -----------------------------------------------------------------------------

### Manually Change Sections Names if Necessary using the Code Below 

data[section=="Old Name", section:="New Name"] # Old Name will be changed to New Name
data[section=="Cover", section:="01. Cover"]   # Cover will be changed to 01. Cover

### Identify which ones are individual modules. Modify the list below. Separate with a comma. 

ind_modules <- c("11a. Availability for the individual interview","12. Education and Literacy", 
                 "13. Health care seeking & expenditure", "14a. Internal Migration of Household Members", 
                 "14b. International Migration of Household Members", 
                 "15. Employment", "16. Time Use", "17. Individual - level parcel details", 
                 "18. Apartment", "19. Livestock ownership", "20. Consumer Durables", "21. Mobiles", 
                 "22. Financial assets")

### Specify List of Responsible per Team 

# Here is the team list: 
unique(data$responsible)

# Please put csv sheet containing enumerator login (related to variable responsible) and supervisor.
# Run the code below to upload the data. 

teams <- readr::read_csv("data/03_microdata/team_list.csv")

# After modifying the above code, continue running the code below. (Can ignore warning message it spits out.)
source("R/0_extract_and_clean_paradata2.R") 

# -----------------------------------------------------------------------------
# 3) Output Report
# -----------------------------------------------------------------------------

quarto::quarto_render(input = "R/Paradata_Report.qmd")

# Delete previous file is exist. 
if (file.exists("data/04_created/Paradata_Report.html")) {
  file.remove("data/04_created/Paradata_Report.html")
}

# Move new file into folder. 
fs::file_move(
    path = "R/Paradata_Report.html",
    new_path = "data/04_created/Paradata_Report.html"
)

# Your report is ready in the new path specified. 
