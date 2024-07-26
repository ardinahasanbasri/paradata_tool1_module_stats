#--------------------------------------------------------------------
# Step 4) Create team data and merge
#
#--------------------------------------------------------------------

teams <- data.table::data.table(teams)
teams <- teams[,c("login", "supervisor")]
data.table::setnames(teams, "login", "responsible")

supervisors <- unique(teams$supervisor[!is.na(teams$supervisor)])
num_of_teams <- length(supervisors)

for (x in 1:num_of_teams) {
  teams[supervisor==supervisors[x], team:=x]
}

teams[!is.na(team), team := as.character(team)] 
teams[ , team := paste0("Team ",team)] 

data <- merge(data, teams)

rm(teams)

#--------------------------------------------------------------------
# Step 5) Create person ID for individual level questionnaire
#
#--------------------------------------------------------------------

# Create variable person_answer and leave empty
data[, person_ID:=""]

# If it is an individual module, grab p3 to get person answer. 
data[section %in% ind_modules, person_ID:=row]  

# Tag if a module is an individual module or not
data[section %in% ind_modules, ind_mod:=1]  
data[!section %in% ind_modules, ind_mod:=0]  

# Change person_ID that has multiple digits  
data[ind_mod==1,.(count = .N), by=person_ID]
data[, person_ID:=substr(person_ID, 1, 2)]   # Get the first two numbers.
data[, person_ID:=gsub( ",", "",person_ID)]  # If there is a comma, erase. 
data[,.(count = .N), by=person_ID]

testit::assert(length(data$person_ID[(data$person_ID=="" | is.na(data$person_ID)) & data$ind_mod==1])==0)

# Keep data where responsible not empty. 
data <- data[responsible!=""]

#--------------------------------------------------------------------
# Step 6) Save clean file to use for other analysis.  
#--------------------------------------------------------------------

data.table::fwrite(
  data, 
  file = fs::path(here::here("data", "04_created", "paradata_clean.csv"))
)
