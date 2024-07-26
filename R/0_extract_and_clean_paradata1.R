#----------------------------------------------------------------------------
# Step 1) Combine multiple paradata files from zipfiles.  
#         
#           
#----------------------------------------------------------------------------

data <- data.table::data.table() # empty data table to append paradata to 

file_names <- fs::dir_ls(
  path = here::here("data", "01_paradata"),
  regexp = "\\.zip"
)

for (name in file_names){ # unzip, append data to main dataset 
  unzip(name)
  aux <- data.table::fread("paradata.tab")
  data <- rbind(data, aux)
  file.remove("paradata.do", "paradata.tab")
  print(paste(name, "extracted"))
  }

  rm(aux, file_names) # remove auxiliary data

#----------------------------------------------------------------------------
# Step 2) Calculating time length using susopara and conduct additional cleaning 
#         
#           
#----------------------------------------------------------------------------

  # prepare
  data <- susopara::parse_paradata(dt = data)
  
  # compute duration between events
  data <- susopara::calc_time_btw_active_events(dt = data)
  
  # remove extreme times
  data <- data %>%
    tidytable::filter(
      (elapsed_min < quantile(elapsed_min, 0.99, na.rm=TRUE)) &
      (elapsed_min>0 & !is.na(elapsed_min))
    )
  
#------------------------------------------------
# Step 3) Create module name based on json file  
# 
#
#------------------------------------------------

path_json <- fs::path(here::here("data", "02_metadata"), "document.json")

# ingest
qnr_df <- susometa::parse_questionnaire(path = path_json)

# create section-variable table
variables_by_section <- susometa::get_questions_by_section(qnr_df = qnr_df) %>%
  data.table::data.table()

# =============================================================================
# Add module attribute to paradata
# =============================================================================

data <- data %>%
  tidytable::left_join(variables_by_section, by = "variable") 

rm(qnr_df, variables_by_section)

data <- data.table::data.table(data) # Make sure data.table format after merge


