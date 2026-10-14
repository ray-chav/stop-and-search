# Reading in Data
# Rachel - 10/13
# GOAL: get a feel for which variables we have, which are most relevant to
# our predictors, and their basic distributions en masse

# Libraries ================================
library(tidyverse)
library(kableExtra)
library(GGally)

# Read in Data =============================
train_data <- read.csv('../../data/final_test_train/stop_search_train_imputed.csv')

# Merge data together
# NOT NEEDED !

# Basic EDA ================================
colnames(train_data)

# Factor search occurred variable
train_data <- train_data %>%
  mutate(search_occurred = factor(search_occurred))

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
#ggpairs(train_data, aes(color = search_occurred, alpha = 0.5))

# Elementary Logistic Model ================


# Trimming Model ===========================


# Viz Correlations =========================
