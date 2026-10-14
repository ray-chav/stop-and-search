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
train_data <- train_data %>%
  mutate(across(where(~ !is.numeric(.)), as.factor))

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

# First 5 variables
ggpairs(train_data_trim |>
          select(1:4, 'search_occurred'),
        aes(color = search_occurred, alpha = 0.5))
# Second 5 variables
# Third 4 variables
# Fourth 4 variables
# Fifth 4 variables

# Elementary Logistic Model ================


# Trimming Model ===========================


# Viz Correlations =========================
