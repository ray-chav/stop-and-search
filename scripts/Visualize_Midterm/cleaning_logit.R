# Organizing 
# Rachel - 10/13
# GOAL: get a feel for which variables we have, which are most relevant to
# our predictors, and their basic distributions en masse

# Libraries ================================
library(tidyverse)
library(kableExtra)
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
kbl(round(cor_matrix, 2)) |>
  kable_styling()
# Conclusion: nothing of concern

# 2) Categorical naive logit model
raw_model <- glm(
  search_occurred ~ ., # Predict search_occurred
  data = train_data |>
    select(-any_of("SubjectID")), # Check all varse -ID
  family = binomial() # Model choice is simple
)
summary(raw_model) # Just for funsieiiiies
# Check out VIFs (searching for multicollinearity)
kbl(car::vif(raw_model)) |>
  kable_styling(
    full_width = FALSE,
    font_size = 10
  )
# Conclusion: nothing of concern

# Removing variables =======================
# Exclude latitude and longitude
model_reduced <- update(
  raw_model,
  . ~ . - Latitude - Longitude
)

# Compare model fit
anova(model_reduced, raw_model, test = "Chisq")
AIC(model_reduced, raw_model)
# Conclusion: remove Lat and Long!

# Lumping together variables ===============
summary(model_reduced) #year and month are the biggest

train_data <- train_data |>
  mutate(
    
    # 1. Compress months into seasons -----
    season = case_when(
      month %in% c(12, 1, 2) ~ "Winter",
      month %in% c(3, 4, 5) ~ "Spring",
      month %in% c(6, 7, 8) ~ "Summer",
      month %in% c(9, 10, 11) ~ "Fall"
    ),
    season = factor(
      season,
      levels = c("Winter", "Spring", "Summer", "Fall")
    ),
    # 2. Remodeling year as a cont var ----
    year_num = as.numeric(year)
  )

# Elementary Logistic Model ================


# Trimming Model ===========================


# Viz Correlations =========================
