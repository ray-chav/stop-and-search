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

# Generating Pairwise Comparisons ===========
# Function to generate and save a ggpairs plot
# Input: vector range of columns
        # X
        # response var of interest
        # possible directory you want the PNGs saved in
# Output: saved PNGs of ggpairs run on those columns of interest
save_gpairs <- function(var_range,
                        data = train_data_trim,
                        response = "search_occurred",
                        directory = "") {
  
  # Filter data down to only what we want
  plot_data <- data |>
    select(all_of(var_range), all_of(response))
  
  # GGpairs plot with our ys
  p <- ggpairs(
    plot_data,
    aes(color = .data[[response]], alpha = 0.5) # Plot y in corner
  ) +
    theme_minimal()
  
  # Generate fielnames to capture our ranges
  filename <- paste0(
    "ggpairs_",
    min(var_range), "_to_", max(var_range),
    ".png"
  )
  
  # Attach directory to filenames
  filename <- file.path(directory, filename)
  
  # Save as a png
  # Dim: 3500x4000
  ggsave(
    filename = filename,
    plot = p,
    width = 4000,
    height = 3500,
    units = 'px',
    dpi = 300
  )
  
  return(p)
}

# Run for each group of 3 variables
for (i in seq(1, 19, by = 3)) {
  save_gpairs(i:(i + 2),
              directory = "../../eda_visualizations/ggpairs/")
}

# Chopped code below ------------------------
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
#--------------------------------
