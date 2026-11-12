# Cross-Validated Feature Selection

ML Project documentation log (continuation of the original Feature Selection log). Notebook: `ML_Project_Feature_Selection_CV.ipynb`. This version reflects the re-run that includes District.

With feature selection done inside each CV fold, no method beats keeping all 20 variables. The consensus rule keeps 14 of them, all stable across folds, at a cost of 0.0018 AUC (logistic regression) or 0.0039 (gradient boosting).

## Revision Note

The first version of this log evaluated 19 variables. District was lost when the data was loaded with `index_col=0`, which turned the file's first column (District) into the row index. The notebook now loads the file without it, so 20 variables are evaluated and every number below comes from the corrected run.

## What Changed and Why

The original script fitted every selection step (univariate tests, mutual information, lasso, random forest, multivariable regression) on the **whole** training set and only compared feature sets with cross-validation afterwards. The held-out folds had therefore already influenced which features were chosen, so the CV scores were optimistic. This was the last item in the original log ("Redo feature selection within each fold").

The new notebook puts the selection **inside** each CV fold:

- The preprocessing code from `preprocessing_pipeline.ipynb` is reused as the front end of one scikit-learn `Pipeline`: bin rare levels, impute, one-hot encode, scale, **select features**, final model.
- `cross_validate` runs on that pipeline, so binning, imputation, encoding, scaling and the selection itself are fitted on the training part of each fold only. The validation part of the fold is only transformed.
- Selection works on the **original variable**: all dummies of a categorical (and its missing-value indicator) are kept or dropped together.
- The test set is never loaded.
- Folds are identical for every method (5-fold stratified, seed 10), so results are paired.

## Setup

```
Rows: 121317 | positive rate: 5.507% | events: 6681
Dropped (non-numeric, not in any column list): BlockAddress, StopDate
Numeric columns passed through untouched: isTrafficViolation
```

The row counts and dropped text columns are from the first run's printout; the data file is the same.

**Candidate variables: 20.**

- Categorical (7): VehicleStyle, VehicleColor, SubjectRace, SubjectEyeColor, SubjectHairColor, Zip, District. `District` is a numeric district code with 8 levels; it is converted to text and one-hot encoded like the other categoricals.
- Numeric (6): SubjectAge, SubjectHeight, SubjectWeight, VehicleYear, hour, month.
- Binary (7): SubjectGender, isLA, SubjectHasPhotoID, night, weekend, isDriver, isTrafficViolation.

Compared with the 24 in the original log, `year`, `Zone`, `Latitude` and `Longitude` are excluded because the preprocessing pipeline drops them (they are in its drop list). `year` was the second-strongest single predictor in the original log (OR 0.65 per SD, AUC 0.641) and is **not** a candidate here, so the AUCs below are not comparable to the original log's 0.82.

**Preprocessing:** the simple pipeline (median / most-frequent / "Missing" imputation with missing indicators, rare levels under 1% pooled into Other, one-hot encoding, numeric scaling). One fix was made to the original calls: `build_simple_pipeline` was being passed `dis_cols` where it expects `bin_cols`, which sent age, height, weight, vehicle year, month and hour through the pipeline twice (once scaled, once raw).

**Final models (used only to score each selection):** L2 logistic regression, and histogram gradient boosting (learning rate 0.1, 200 iterations, early stopping).

**Metrics:** ROC AUC (main), average precision, Brier score.

## Selection Methods (all run inside each fold)

| Method | Rule for keeping a variable |
| --- | --- |
| `none` | Baseline, keep everything |
| `lasso` | L1 logistic regression on standardized features; C chosen by inner 3-fold CV on AUC; keep if any coefficient is non-zero |
| `lasso_1se` | Same, but the strongest penalty whose inner CV AUC is within 1 SE of the best |
| `rf_impurity` | Random forest impurity importance (summed over dummies) must beat a random noise column |
| `rf_perm` | Random forest permutation importance on an inner 25% hold-out; all columns of a variable are shuffled together; keep if AUC drop is above 2 SD and above 0 (5 repeats, up to 8,000 rows) |
| `mutual_info` | Mutual information must beat the largest MI obtained with a shuffled target (30,000-row subsample) |
| `univariate_lrt` | Likelihood-ratio test of the variable alone vs. intercept-only, Benjamini–Hochberg adjusted, alpha 0.05 |
| `consensus` | Keep if at least 3 of 5 votes: `univariate_lrt`, `mutual_info`, `lasso`, `rf_impurity`, `rf_perm` |

The original log also used a multivariable logistic regression drop-one test as a vote. It is not part of the new consensus; the lasso covers that role.

## Results

### 1. Predictive performance with in-fold selection

Mean ± SD of ROC AUC over the 5 outer folds. These are honest estimates of the whole "select, then fit" procedure.

| Selector | Variables kept (mean ± SD) | Logistic regression AUC | Gradient boosting AUC |
| --- | --- | --- | --- |
| none | 20.0 | 0.8082 ± 0.0079 | 0.8276 ± 0.0078 |
| lasso | 19.8 ± 0.4 | 0.8082 ± 0.0079 | 0.8268 ± 0.0068 |
| lasso\_1se | 18.4 ± 1.0 | 0.8080 ± 0.0079 | 0.8261 ± 0.0080 |
| univariate\_lrt | 17.8 ± 0.4 | 0.8076 ± 0.0078 | 0.8206 ± 0.0071 |
| rf\_perm | 15.6 ± 1.0 | 0.8070 ± 0.0082 | 0.8252 ± 0.0074 |
| consensus | 15.2 ± 0.7 | 0.8064 ± 0.0075 | 0.8237 ± 0.0068 |
| rf\_impurity | 5.8 ± 0.7 | 0.7739 ± 0.0077 | 0.7894 ± 0.0090 |
| mutual\_info | 5.6 ± 1.9 | 0.7716 ± 0.0178 | 0.7867 ± 0.0170 |

**Reading it:**

- **No method beats keeping everything.** Change in AUC against `none`:
  - Logistic regression: lasso +0.0000, lasso\_1se -0.0001, univariate\_lrt -0.0006, rf\_perm -0.0012, consensus -0.0018.
  - Gradient boosting: lasso -0.0008, lasso\_1se -0.0016, rf\_perm -0.0024, consensus -0.0039, univariate\_lrt -0.0070.
  - These are small next to the fold-to-fold SD of about 0.007–0.008. The notebook also printed paired differences against `none`; they were not included in the output I was given, so this judgement is from the means.
- **`rf_impurity` and `mutual_info` cost about 0.034–0.041 AUC** because they keep only about 6 variables. They keep mainly the continuous variables (age, height, vehicle year, and sometimes hour or weight) plus gender and `isTrafficViolation`, and discard binary and categorical variables (`night`, `isDriver`, `Zip`, `District`, `SubjectRace`, `isLA`, `SubjectHasPhotoID`) that clearly carry signal, since the lasso and permutation importance keep them and the AUC falls when they are removed. Impurity importance is already known to favour continuous variables (noted in the original log), and the same appears to hold for MI here. Neither should be used on its own.
- **`lasso`, `lasso_1se` and `univariate_lrt` barely prune** (17.8–19.8 of 20 variables). With 121k rows almost everything is significant or gets a non-zero coefficient, as the original log also warned.
- **`consensus` removes about 5 variables (20 → 15.2 per fold)** for a small AUC cost. The cost is somewhat larger than in the first run (which was -0.0006 for logistic regression and -0.0023 for gradient boosting with 19 variables).
- **Gradient boosting beats logistic regression by about 0.0195 AUC with all variables** (0.8276 vs 0.8082), and by 0.013–0.019 under every selector. The original log concluded that "logistic regression is adequate" from a gap of about 0.01, so non-linear effects or interactions may matter more than that log suggested.

Average precision and Brier score tell the same story:

| Selector | Model | Avg. precision | Brier score |
| --- | --- | --- | --- |
| none | logistic regression | 0.2418 | 0.0465 |
| consensus | logistic regression | 0.2408 | 0.0465 |
| none | gradient boosting | 0.2748 | 0.0454 |
| consensus | gradient boosting | 0.2731 | 0.0455 |

### 2. Effect of adding District

Comparing with the first run (19 variables, no District), using `none` (all variables):

| Model | First run (19 variables) | This run (20 variables) | Change |
| --- | --- | --- | --- |
| Logistic regression | 0.8081 | 0.8082 | +0.0001 |
| Gradient boosting | 0.8256 | 0.8276 | +0.0020 |

District adds about 0.002 AUC for gradient boosting and essentially nothing for logistic regression. It may overlap with `Zip` (both are location variables), but this run cannot show that.

### 3. Selection stability

Number of the 5 outer folds in which each variable was selected.

| Variable | lasso | lasso\_1se | rf\_impurity | rf\_perm | mutual\_info | univariate\_lrt | **consensus** |
| --- | --- | --- | --- | --- | --- | --- | --- |
| SubjectAge | 5 | 5 | 5 | 5 | 5 | 5 | **5** |
| SubjectGender | 5 | 5 | 5 | 5 | 5 | 5 | **5** |
| isTrafficViolation | 5 | 5 | 5 | 5 | 5 | 5 | **5** |
| VehicleYear | 5 | 5 | 5 | 5 | 3 | 5 | **5** |
| SubjectHeight | 5 | 5 | 5 | 4 | 3 | 5 | **5** |
| SubjectWeight | 5 | 5 | 1 | 5 | 2 | 4 | **5** |
| SubjectRace | 5 | 5 | 0 | 5 | 1 | 5 | **5** |
| District | 5 | 5 | 0 | 5 | 0 | 5 | **5** |
| isLA | 5 | 5 | 0 | 4 | 1 | 5 | **5** |
| isDriver | 5 | 5 | 0 | 5 | 0 | 5 | **5** |
| night | 5 | 5 | 0 | 5 | 0 | 5 | **5** |
| SubjectHasPhotoID | 5 | 5 | 0 | 3 | 0 | 5 | **5** |
| Zip | 5 | 5 | 0 | 5 | 0 | 5 | **4** |
| hour | 5 | 4 | 3 | 5 | 3 | 0 | **4** |
| VehicleStyle | 5 | 5 | 0 | 2 | 0 | 5 | **3** |
| SubjectHairColor | 5 | 5 | 0 | 3 | 0 | 5 | **2** |
| weekend | 5 | 5 | 0 | 2 | 0 | 5 | **1** |
| VehicleColor | 5 | 5 | 0 | 1 | 0 | 5 | **1** |
| SubjectEyeColor | 5 | 2 | 0 | 0 | 0 | 5 | **1** |
| month | 4 | 1 | 0 | 4 | 0 | 0 | **0** |

**Reading it:**

- `SubjectAge`, `SubjectGender` and `isTrafficViolation` are chosen by every method in every fold. They are the core of the model.
- **District is selected in all 5 folds** by the lasso, lasso\_1se, permutation importance, univariate test and consensus rule. Only `rf_impurity` and `mutual_info` miss it (0 of 5), which fits their known tendency to discount categorical variables.
- **Zip is also kept** (5 of 5 for lasso, permutation and univariate; 4 of 5 for consensus). It was 5 of 5 under consensus before District was added, so the two location variables may share some signal.
- Twelve variables are selected in all 5 folds by the consensus rule; `Zip` and `hour` are selected in 4 of 5.
- `hour` is a split case: the univariate test never selects it, but the lasso and permutation importance almost always do. This matches the original log, where `hour` failed the univariate test but mattered once other variables were included.
- `weekend`, `VehicleColor`, `SubjectEyeColor` and `month` are selected by the consensus rule in at most 1 fold. This agrees with the original log's Drop group (`weekend`, `VehicleColor`, `VehicleStyle`, `SubjectEyeColor`). `month`, previously "optional", is now dropped.
- `VehicleStyle` (3 of 5) and `SubjectHairColor` (2 of 5) are borderline and fall below the 80% stability cutoff. `SubjectHairColor` was 4 of 5 in the first run, so it changed after District was added; I cannot tell from these outputs whether District caused that or ordinary run-to-run variation.
- In practice the lasso and univariate test keep almost everything, so the 3-vote consensus rule is decided mainly by whether `rf_perm`, `rf_impurity` or `mutual_info` also supports the variable.
- The component methods inside `consensus` are re-run with a different random-number sequence from the standalone rows, so their per-fold choices can differ slightly from the single-method columns.

### 4. Final feature list (consensus)

The procedure was run once on the full training set, and the result was compared with the CV stability.

| List | Variables |
| --- | --- |
| Selected on full training set (14) | SubjectRace, Zip, District, SubjectAge, SubjectHeight, SubjectWeight, VehicleYear, hour, SubjectGender, isLA, SubjectHasPhotoID, night, isDriver, isTrafficViolation |
| Selected in at least 80% of CV folds (14) | The same 14 variables |

The two lists are identical: no variable appears only in the full-train selection and none appears only in the CV-stable list. Unlike the first run, there is no borderline disagreement to resolve.

## Conclusions

- **Feature selection does not improve accuracy here.** Keeping all 20 variables gives the best or tied-best AUC for both models. The case for selecting is a simpler, more stable model, not a better score.
- **Recommended reduced set: the 14 consensus variables,** which are stable across folds. Using it costs about 0.0018 AUC (logistic regression) to 0.0039 (gradient boosting) relative to using everything. If accuracy is the only goal, keep all 20.
- **Drop:** `weekend`, `VehicleColor`, `SubjectEyeColor`, `month`. `VehicleStyle` and `SubjectHairColor` are unstable and also excluded by the 80% rule.
- **Keep in every set:** `isTrafficViolation`, `SubjectGender`, `SubjectAge`.
- **District should be kept.** It was selected in every fold by five of the methods and adds about 0.002 AUC for gradient boosting. It cannot be dropped on the evidence of this run.
- **Do not use `rf_impurity` or `mutual_info` alone,** because they discard useful binary and categorical variables.
- **Use gradient boosting** if the goal is the highest score; it leads logistic regression by about 0.0195 AUC with all variables.
- **Reporting caution:** the honest performance estimate for this approach is the `consensus` row in the results table (0.8064 logistic regression, 0.8237 gradient boosting). If the final 14-variable list is evaluated by plain CV afterwards, that number will be slightly optimistic, because the list was chosen using all training rows.

## Considerations / Next Steps

- **Zone, Zip and District:** the original question was "is Zone or Zip better, and can District be dropped?" `District` is kept (see above) and `Zip` is kept (4 to 5 folds). `Zone` is still excluded by the preprocessing drop list, so it was not compared. To test whether either location variable is redundant, run the final models with `Zip` removed, with `District` removed, and with both, and compare AUC.
- Decide whether `year`, `Zone`, `Latitude` and `Longitude` should compete again. They can be restored by editing `DROP_COLS` at the top of the notebook; `year` and the coordinates were strong in the original log.
- Check the paired AUC differences against `none` that the notebook printed, to confirm that the small drops above are within noise.
- **Fix the same loading bug in `preprocessing_pipeline.ipynb`.** It also reads the file with `index_col=0`, so earlier modelling runs probably never saw `District` either.
- **Random-effects selection (added to the notebook, not yet run).** Selectors `glmm_wald`, `glmm_perm` and `consensus_glmm` fit a logistic regression with District as a random intercept (statsmodels `BinomialBayesMixedGLM`) and test each other variable given the District effect. A diagnostic cell reports the share of variation between districts (ICC) per fold. Expect little or no AUC gain, since District is already a feature; the value is in showing which variables are mainly location proxies. With only 8 districts the random-effect variance will be imprecise, and a random intercept does not capture spatial dependence between neighbouring districts. No results from this extension are included in this log.
- If the model must work in districts it has not seen, evaluate with grouped CV (for example `StratifiedGroupKFold` with District as the group); ordinary stratified folds put stops from every district in both training and validation.
- Optionally compare final sets (14 variables, all 20) on fresh folds, keeping in mind the caution above, then evaluate once on the untouched test set.
- Other methods not yet tried: Boruta or shadow-feature selection, RFECV with logistic regression, stability selection (lasso over many bootstrap subsamples), SHAP importance from the boosted model.

## Glossary (How to Read Each Output)

- **Variables kept:** number of original variables (not dummy columns) the selector kept in a fold, averaged over the 5 folds, with the SD across folds.
- **ROC AUC (outer fold):** ability to rank searched stops above non-searched ones (0.5 = coin flip, 1 = perfect), measured on a fold that played no part in the selection or fitting.
- **Average precision:** area under the precision–recall curve; more informative than AUC when only 5.5% of stops lead to a search (a random model would score about 0.055).
- **Brier score:** mean squared error of the predicted probabilities; lower is better.
- **Selection frequency:** the number of outer folds (out of 5) in which a variable was kept. Variables chosen in only 1–2 folds are not reliably useful.
- **lasso vs lasso\_1se:** the best-AUC penalty keeps almost everything; the 1-SE version picks the strongest penalty that is statistically as good, so it prunes more.
- **rf\_perm:** drop in held-out AUC when a variable's values are shuffled; a variable's dummies are shuffled together so a categorical is judged as a whole.
- **consensus:** a variable is kept if at least 3 of the 5 voting methods choose it.
- **Stable (final list):** selected in at least 80% of the outer folds.
- **Random intercept / ICC (random-effects extension):** a random intercept gives each district its own baseline search rate, shrunk toward the overall average. The ICC is the share of the variation in the log-odds of a search that lies between districts; near zero means the district effect adds little.
