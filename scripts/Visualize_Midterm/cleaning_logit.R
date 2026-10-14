# Organizing 
# Rachel - 10/13
# GOAL: get a feel for which variables we have, which are most relevant to
# our predictors, and their basic distributions en masse

# Libraries ================================
library(tidyverse)
library(kableExtra)
library(car)
library(glmnet)
set.seed(123) # for reproducibility

# Read in Data =============================
train_data_raw <- read.csv('../../data/final_test_train/stop_search_train_imputed.csv')
# Prep data
# Factorize all non-continuous measures
cont_variables <- c(
  "VehicleYear", "SubjectAge", "SubjectHeight",
  "SubjectWeight", "Longitude", "Latitude", "hour"
)
train_data <- train_data_raw |>
  # Turn all variables into factors
  mutate(across(everything(), as.factor)) |>
  
  # Turn the appropriate variables into continuous measures
  mutate(across(
    all_of(cont_variables),
    as.numeric
  )) |>
  
  # Remove relevant variables (see 10/13 documentation for justification)
  select(-where(~ is.factor(.) & n_distinct(.) > 10))

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
# NOTE: nothing below was done due to no improved model
# summary(model_reduced) #year and month are the biggest
# 
# train_data <- train_data |>
#   mutate(
#     
#     # 1. Compress months into seasons
#     season = case_when(
#       month %in% c(12, 1, 2) ~ "Winter",
#       month %in% c(3, 4, 5) ~ "Spring",
#       month %in% c(6, 7, 8) ~ "Summer",
#       month %in% c(9, 10, 11) ~ "Fall"
#     ),
#     season = factor(
#       season,
#       levels = c("Winter", "Spring", "Summer", "Fall")
#     ),
#     # 2. Remodeling year as a cont var
#     year_num = as.numeric(year)
#   )
# 
# # Checking models to see if this recoding is gut
# # Common predictors: exclude the original time variables
# base_formula <- update(
#   formula(model_reduced),
#   . ~ . - year - month
# )
# 
# # Fitting four alternative models ...
# m_year_month <- glm( # cat year, cat month
#   update(base_formula, . ~ . + year + month),
#   data = train_data,
#   family = binomial()
# )
# m_yearnum_month <- glm( # cont year, cat month
#   update(base_formula, . ~ . + year_num + month),
#   data = train_data,
#   family = binomial()
# )
# m_year_season <- glm( # cat year, cat season
#   update(base_formula, . ~ . + year + season),
#   data = train_data,
#   family = binomial()
# )
# m_yearnum_season <- glm( # cont year, cat seson
#   update(base_formula, . ~ . + year_num + season),
#   data = train_data,
#   family = binomial()
# )
# 
# # Which model is best?
# AIC(
#   m_year_month, # lowest aic
#   m_yearnum_month,
#   m_year_season,
#   m_yearnum_season
# )
# # Does categorical year improve on continuous year,
# # holding month constant? -> YES, significantly
# anova(m_yearnum_month, m_year_month, test = "Chisq")
# # Does categorical year improve on continuous year,
# # holding season constant? -> YES, significantly
# anova(m_yearnum_season, m_year_season, test = "Chisq")
# # Does month improve on season,
# # holding categorical year constant? -> YES, significantly
# anova(m_year_season, m_year_month, test = "Chisq")
# # Conclusion: categorical month and year

# Elementary Logistic Model ================
# Currently using: raw_model

# Trimming Model ===========================
# # 1) Ridge & Lasso -> what variables might we not need
# # Construct feature matrix
# x <- model.matrix(
#   search_occurred ~ . - Latitude - Longitude,
#   data = train_data
# )[, -1]
# # Response vector
# y <- as.numeric(train_data$search_occurred)
# 
# # Modeling for feature selections
# # Ridge
# cv_ridge <- cv.glmnet(
#   x, y,
#   family = "binomial",
#   alpha = 0
# )
# # Lasso
# cv_lasso <- cv.glmnet(
#   x, y,
#   family = "binomial",
#   alpha = 1
# )
# 
# # Compare cross-validated performance
# plot(cv_ridge)
# plot(cv_lasso)

# 2. Drop 1 on model
summary(model_reduced)
drop1(model_reduced, test = "Chisq")

# 3. Refine model gradually
model <- model_reduced # Redefine so we can keep trimming

# Trim 1) eye color and 2) style
model_reduced <- update(
  model,
  . ~ . - VehicleStyle # cut two insignificant predictors
)
# Diagnostics
AIC(model, model_reduced)
anova(model, model_reduced, test = "Chisq")
