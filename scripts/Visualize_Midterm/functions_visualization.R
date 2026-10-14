# Functions to Reuse for Visualizations
# Rachel - 10/13
# GOAL: build reusable modules for flexible data frames
# now what in the LinkedIn description ^ ....

# Constants ==============================
# Vector of hex codes, used for easy visualizations
colo_pale <- c(
  '#335c67',
  '#fff3b0',
  '#e09f3e',
  '#9e2a2b',
  '#540b0e'
)

# Font determined
windowsFonts(my_font = windowsFont("Georgia"))

# Themes ================================
theme_eda <- function(base_size = 10) {
  theme_minimal(
    base_size = base_size,
    base_family = "my_font"
  ) +
    theme(
      # Overall typography
      text = element_text(
        family = "my_font",
        color = "#33332F"
      ),
      
      # Title and subtitle
      plot.title = element_text(
        face = "bold",
        size = rel(1.3),
        color = "#33332F",
        margin = margin(b = 5)
      ),
      plot.subtitle = element_text(
        size = rel(0.95),
        color = "#77766F",
        margin = margin(b = 12)
      ),
      
      # Caption
      plot.caption = element_text(
        size = rel(0.8),
        color = "#77766F",
        hjust = 0,
        lineheight = 1.3,
        margin = margin(t = 12)
      ),
      
      # Axes
      axis.title = element_text(
        size = rel(0.9),
        color = "#55554F"
      ),
      axis.text = element_text(
        size = rel(0.85),
        color = "#55554F"
      ),
      axis.ticks = element_blank(),
      
      # Gridlines: subtle and minimal
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(
        color = "#E7E3DA",
        linewidth = 0.4
      ),
      panel.grid.minor = element_blank(),
      
      # Legend
      legend.position = "bottom",
      legend.title = element_blank(),
      legend.text = element_text(size = rel(0.85)),
      legend.key = element_blank(),
      
      # Facets
      strip.text = element_text(
        face = "bold",
        color = "#55554F"
      ),
      panel.spacing = unit(12, "pt"),
      
      # Background and margins
      panel.background = element_blank(),
      plot.background = element_blank(),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      plot.margin = margin(12, 12, 12, 12)
    )
}

# For automatically coloring different categories
eda_fill <- function(variable, data, palette = colo_pale) {
  n <- dplyr::n_distinct(data[[variable]], na.rm = TRUE)
  
  scale_fill_manual(
    values = rep(palette, length.out = n)
  )
}

# Functions ===========================
# Input: X, var1, var2
# Output: Dataframe with conditional proportions
summarize_binary <- function(X,
                             predictor,
                             response = search_occurred_fct) {
  
  X |>
    filter(!is.na({{ predictor }}),
           !is.na({{ response }})) |>
    count({{ predictor }}, {{ response }}, name = "n") |>
    group_by({{ predictor }}) |>
    mutate(
      freq = 100 * n / sum(n)
    ) |>
    ungroup()
}

# Input: X, variable to sort, order (default ascending)
# Output: Factors of X sorted by their variable value
sort_bars <- function(data, x, decreasing = FALSE, 
                      by = NULL, response = NULL) {
  
  if (is.null(by)) {
    # Sort by frequency of the variable
    data[[x]] <- forcats::fct_infreq(data[[x]])
    
    if (!decreasing) {
      data[[x]] <- forcats::fct_rev(data[[x]])
    }
    
  } else {
    # Sort by a specific response category's frequency
    sort_data <- data |>
      filter(.data[[response]] == by) |>
      arrange(.data[[x]])
    
    ordering <- sort_data[[x]][
      order(sort_data$freq, decreasing = !decreasing)
    ]
    
    data[[x]] <- factor(data[[x]], levels = ordering)
  }
  
  data
}
