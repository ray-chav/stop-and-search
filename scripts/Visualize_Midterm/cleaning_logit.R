# Organizing 
# Rachel - 10/13
# GOAL: get a feel for which variables we have, which are most relevant to
# our predictors, and their basic distributions en masse

# Libraries ================================
library(tidyverse)
library(car)

# Read in Data =============================
train_data <- read.csv('../../data/final_test_train/stop_search_train_imputed.csv')
# Prep data
# Factorize all non-continuous measures
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
  )) |>
  
  # Remove relevant variables (see 10/13 documentation for justification)
  select(-where(~ is.factor(.) & n_distinct(.) > 10),
         -SubjectID)

# Search for multicollinearity =============
# 1) Numerical multicollinearity
numeric_data <- train_data |>
  select(where(is.numeric)) |>
  select(-any_of("search_occurred"))

cor_matrix <- cor(
  numeric_data,
  use = "pairwise.complete.obs"
)
# Output correlation matrix
round(cor_matrix, 2)

# 2) Categorical naive logistic model
model <- glm(
  search_occurred ~ .,
  data = train_data_trim |>
    select(-any_of("SubjectID")),
  family = binomial()
)
# Check out VIFs (searching for multicollinearity)
car::vif(model)

# Removing variables =======================


# Lumping together variables ===============


# Elementary Logistic Model ================


# Trimming Model ===========================


# Viz Correlations =========================
