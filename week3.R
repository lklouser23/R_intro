#### Intro to R: data parsing with dplyr ####

#### Objectives ####

# review previous weeks' material

# Today:
# installing and loading packages
# selecting columns and rows (the tidyverse way)
# combining commands using pipes
# creating new columns by modifying existing data
# summarizing data based on data in other columns

#### Packages and tidyverse ####

# start package installation at the start of class, as sometimes it takes a few minutes
# install package (only once on your own computer)
install.packages("tidyverse")
# explain output in console:
#   red doesn't necessarily mean anything is wrong! Installing software gives a lot of output about things downloading and compiling
#   if prompted, install all packages (say yes or all)

# packages are collections of functions
#   contributed by community, for public use
#   can obtain on CRAN or GitHub
# today, using dplyr for large scale data; part of tidyverse
# tidyverse is a collection of packages that are trendy/useful
#   for large-scale data manipulation
# link to tidyverse documentation: https://www.tidyverse.org
# can install parts of tidyverse independently,
#   but might as well install all at once (we'll use next week, too)

# load library/package (needs to happen every time R restarts)
library(tidyverse)
# attaching packages references everything included in tidyverse
# we need to load libraries the same way that we need to open software applications after installing them
# there are many other packages included as dependencies
# conflicts represents functions with same names are present in base R (stats)
# double colon syntax (::) allows you to reference functions with same name,
#   but present in other packages
# check dplyr installation
?select
# help documentation should open up for select {dplyr},
#   indicating package has loaded appropriately
# can also look in "Packages" tab in lower right hand panel
#   search for package
#   if package is present, it's installed
#   if box is checked, package is loaded
# you may end up with errors later if required packages didn't install;
#   tell instructor if you get an error saying a function isn't available

#### Selecting columns and rows ####

# can probably skip this part: create data directory and download data again, if needed
dir.create("data") # R will complain if this already exists
download.file("https://raw.githubusercontent.com/fredhutchio/R_intro/master/extra/clinical.csv", "data/clinical.csv")

# To wrap R source files: Tools -> Global Options -> Code, check box for "Soft-wrap R source files"

# reading in data and saving to object
clinical <- read_csv("data/clinical.csv")
# note differences with import last week!
# tibble: opinionated table in tidyverse, easier to work with large data
# recall object
clinical
str(clinical)

# selecting columns with dplyr
sel_columns <- select(clinical, tumor_stage, ethnicity, disease)
# select range of columns
sel_columns2 <- select(clinical, tumor_stage:vital_status)
# additional useful ways for selecting columns: starts_with(), ends_with(), contains()
# select rows conditionally
filtered_rows <- filter(clinical, disease == "LUSC") # keep only lung cancer cases
# can apply other filters (as discussed last week)

## Challenge: create a new object from clinical called race_disease that includes only the race, ethnicity, and disease columns

## Challenge: create a new object from race_disease called race_BRCA that includes only BRCA (disease)

#### Combining commands ####

# last challenge uses intermediate objects to combine commands: two step process

# nest commands (same as created above, but here only in two lines)
race_BRCA2 <- select(filter(clinical, disease == "BRCA"), race, ethnicity, disease)

# combine commands using pipes (improves readability of complex commands)
# same example as above
piped <- clinical %>%
  select(race, ethnicity, disease) %>%
  filter(disease == "BRCA")
# extract race, ethinicity, and disease from cases born prior to 1930
piped2 <- clinical %>%
  filter(year_of_birth < 1930) %>%
  select(race, ethnicity, disease)
# does the order of commands differ? 
piped3 <- clinical %>%
  select(race, ethnicity, disease) %>%
  filter(year_of_birth < 1930)
# in this case, yes it does matter!

#### BREAK ####

## Challenge: Use pipes to extract the columns gender, years_smoked, and year_of_birth from the object clinical for only living patients (vital_status) who have smoked fewer than 1 cigarettes per day

#### Mutate ####

# mutate allows unit conversions or ratios, creates a new column
# convert days to years
clinical_years <- clinical %>%
  mutate(years_to_death = days_to_death / 365)
# convert days to year and months at same time, and we don't always need to assign to object
clinical %>%
  mutate(years_to_death = days_to_death / 365,
         months_to_death = days_to_death / 30) %>%
  glimpse() # better option for tibble preview

## Challenge: extract only lung cancer patients (LUSC, from disease) and create a new column called total_cig representing an estimate of the total number of cigarettes smoked (use columns years smoked and cigarettes per day)

#### Split-apply-combine ####

# frame the problem: we want to summarize data by gender

# show categories in gender
unique(clinical$gender)

# group_by not always useful by itself, but powerful together with tally()
# count number of individuals with each tumor stage
clinical %>%
  group_by(gender) %>%
  tally() # empty parentheses not required, but good practice
# shows missing data, too

# the split/apply/combine approach:
# split data into groups,
# apply an analysis to each group,
# combine results back into one object

# summarize average days to death by gender
clinical %>%
  group_by(gender) %>%
  summarize(mean_days_to_death = mean(days_to_death, na.rm = TRUE))
# why doesn't the above work to remove NA?

# remove NA
clinical %>%
  filter(!is.na(gender)) %>%
  group_by(gender) %>%
  summarize(mean_days_to_death = mean(days_to_death))

## Challenge: create object called smoke_complete from clinical that contains no missing data for cigarettes per day or age at diagnosis 
# Extra: how do you save resulting table to file? How would you find this answer?
smoke_complete <- clinical %>%
  filter(!is.na(age_at_diagnosis)) %>%
  filter(!is.na(cigarettes_per_day))
write_csv(smoke_complete, "data/smoke_complete.csv")
# there is also write.csv from base R
#   base R by default includes row names (numbers) and quotes around cells

## Challenge: create a new object called birth_complete that contains no missing data for year of birth or vital status

# make sure ALL missing data is removed!
birth_complete <- clinical %>%
  filter(!is.na(year_of_birth)) %>%
  filter(!is.na(vital_status)) %>%
  filter(vital_status != "not reported")

#### Filtering data based on number of cases of each type ####

# counting number of records in each cancer
cancer_counts <- clinical %>%
  count(disease) %>%
  arrange(n) # sorts based on defined column, not strictly necessary

# get names of frequently occurring cancers
frequent_cancers <- cancer_counts %>%
  filter(n >= 500) 
# extract data from cancers to keep
birth_reduced <- birth_complete %>%
  filter(disease %in% frequent_cancers$disease)

# save results to file in data/ named birth_reduced
write_csv(birth_reduced, "data/birth_reduced.csv")

## Challenge: extract all tumor stages for which more than 200 cases (also check to see if there are any other missing/ambiguous data!)

#### Wrapping up ####

# review today's objectives: single-table verbs in dplyr
#   other functionality that allows combination
#   and manipulation of multiple tables
# direct towards practice questions (linked in HackMD)
# dplyr includes two-table verbs for joining tables together
# dplyr cheatsheet:
#   https://github.com/rstudio/cheatsheets/raw/master/data-transformation.pdf
# preview next week's objectives
