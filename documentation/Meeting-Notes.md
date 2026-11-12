# Meeting Notes - Stop & Search
*11.09 - ??/??*

### 11.12
Things Done:
- Vijay has finished feature selection --> 14 significant features
- Surafel has finished hyperparameter tuning for log reg and decision tree; working on random forest
- Maha made slide template
- Scheduled presentation rehearsal for 11.16 @7PM

Timeline
- Surafel's part done by today
- Maggie part done by Friday?

Misc. Note
- Visualizations we want (Ray's task):
  - Forest plot of all variables
  - Marginal effects plots of variables of interest
  - Partial dependency plot
  - SHAP values
  - Model performance plot (training vs. test)
  - Brier score, F1, precision recall, statistical plots of that nature
  - Basic EDA description of data plots
- Slides division
  - Maha: Motivation, Problem Setup, Modeling, Evaluation
  - Rachel: Interpretation, Discussion

To-Do:
- [ ] Maggie will work on script for calibration while Surafel finalizes models
- [ ] Maha will start on introductory slides
- [ ] Vijay will refine one of his plots for validation

### 11.09
- Things Done:
  - Surafel: **Cross-validation pipeline**
    - Working on interpretability
  - Surafel doing hyperparameter tuning for logistic regression & decision tree
    - More models to determine (total: logistic, decision tree, random forest)
    - Random forest WIP
- Logistic regression concerns: It might be data leakage between the folds to do feature selection on the whole dataset; LASSO regression might be the better option
  - LASSO will be used on our remaining variables
- Maybe a poll where we can vote on which variables are theoretically ideal?
- On refining location variables: start with broader variable `District`, then work up to `Zip code` for interesting/relevant districts
  - Keeping `District` now could be modeled with a random effects model s.t. we can account for population differences in income, race, other variables (demographic information)
    - Dependency on which `District` they come from / some association we can implement using a REM
- Order of events:
  1. Trimming features via theory (everyone)
  2. Trimming features via LASSO + feature selection (Vijay)
  3. Construct models (Surafel)
  4. Hyperparameter tune models (Surafel)
  5. Compare models via cross-validation (Surafel)
  6. Choose best model (Surafel)
  7. Model calibration (Maggie)
  8. Run model on test set (Maggie)
  9. Analysis & Visualiations (Rachel)
  10. Slides (Maha)
- Timeline:
  - Feature Selection - 11.10
- **Reminder**: 11.17 IS OUR PRESENTATION DATE!!
