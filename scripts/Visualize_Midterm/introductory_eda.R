# Reading in Data
# Rachel - 10/13
# GOAL: get a feel for which variables we have, which are most relevant to
# our predictors, and their basic distributions en masse

# Libraries ================================
library(tidyverse)
library(kableExtra)
library(GGally)
library(mosaic)

# Read in Data =============================
train_data <- read.csv('../../data/final_test_train/stop_search_train_imputed.csv')

# Merge data together
# NOT NEEDED !

# Basic EDA ================================
colnames(train_data)

# Factor search occurred variable
cont_variables <- c(
  "VehicleYear", "SubjectAge", "SubjectHeight",
  "SubjectWeight", "Longitude", "Latitude", "hour"
)
train_data <- train_data |>
  # Turn all variables into factors
  mutate(across(everything(), as.factor)) |>
  
  # Turn the appropriate variables into continuous measures
  mutate(across(
    all_of(cont_variables),
    as.numeric
  ))

# Build proportion table/dataframe
prop_df <- train_data |>
  count(search_occurred) |> 
  mutate(
    prop = n / sum(n),
    perc = round(prop * 100, 2),
    search_occurred_fct = if_else(
      search_occurred == 0,
      "Searched",
      "Unsearched"
    )
  )

# Simple distribution of data
barplot(
  height = prop_df$n,
  names.arg = prop_df$search_occurred_fct, #label each bar
  main = "Less Search Instances than Not",
  xlab = "Search Status",
  ylab = "Count of Instances",
  col = c("lavender", "purple4")
)
# Build table
kable(
  prop_df[,c("search_occurred_fct","perc")],
  col.names = c('Status', 'Percentage(%)')) |> # filter to relevant vars
  kable_styling(
    position = "center",
    full_width = FALSE,
    font_size = 35,
    html_font = "my_font"
  )

# Viz All Predictors =======================
# Exploring Zone
kbl(table(train_data$Zone, train_data$District)) |>
  kable_styling()
# Meaningful spatial data in Zone?
mosaicplot(Zone ~ District, data = train_data, 
           main = "Mosaic Plot of Zone by District",
           color = TRUE,
           las = 2)

# Ensure all categorical variables do not have too many levels
train_data_trim <- train_data |>
  # Clear any NAs if they remain
  tidyr::drop_na() |>
  # Drop categorical variables w/ more than 10
  select(-where(~ is.factor(.) & n_distinct(.) > 10),
         -SubjectID)

# Which vars did we cut?
setdiff(colnames(train_data), colnames(train_data_trim))

# CUT VARIABLES:
  # 1. Zone - Kill!!
  # 2. VehicleColor - probably OK for now; analyses done later
  # 3. BlockAddress - fine; probably can be excluded
  # 4. StopDate - fine; can be excluded
  # 5. SubjectID - idk i think we just dont need it atm
  # 6. Zip - zip code probably heavily tied with district

# A stupid amount of ggpairs plots below
# First 3 variables
ggpairs(train_data_trim |>
          select(1:3, 'search_occurred'),
        aes(color = search_occurred, alpha = 0.5)) +
  theme_minimal()
# Second 3 variables
ggpairs(train_data_trim |>
          select(4:6, 'search_occurred'),
        aes(color = search_occurred, alpha = 0.5)) +
  theme_minimal()
# Third 3 variables
ggpairs(train_data_trim |>
          select(7:9, 'search_occurred'),
        aes(color = search_occurred, alpha = 0.5)) +
  theme_minimal()
# Fourth 3 variables
ggpairs(train_data_trim |>
          select(10:12, 'search_occurred'),
        aes(color = search_occurred, alpha = 0.5)) +
  theme_minimal()
# Fifth 3 variables
ggpairs(train_data_trim |>
          select(13:15, 'search_occurred'),
        aes(color = search_occurred, alpha = 0.5)) +
  theme_minimal()
# Sixth 3 variables
ggpairs(train_data_trim |>
          select(16:18, 'search_occurred'),
        aes(color = search_occurred, alpha = 0.5)) +
  theme_minimal()
# Seventh 3 variables
ggpairs(train_data_trim |>
          select(19:21, 'search_occurred'),
        aes(color = search_occurred, alpha = 0.5)) +
  theme_minimal()
