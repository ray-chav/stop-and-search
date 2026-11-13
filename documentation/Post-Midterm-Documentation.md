## Stop & Search Documentation
All documentation from 10/20 onwards goes here. Write at the top of the document (so that earlier dates are at the bottom of the document, and later dates are at the top) with your updates, including the date and who is writing. Thank you!!

**Format**
# XX.XX \- User

* Update with image attachment (can be placed in documentation images directory with a relative path)
  * ![][image1]  
* Update 2
  * More details on update
* To Do:  
- [ ] Here's something OP needs to remind themselves or someone else to do
- [ ] Here's another list item

------------------------------------

# 11.09 \- Rachel

* Made feature selection Google Doc: [here](https://docs.google.com/document/d/1-PnS19vH6rFnivDEdW9Wowv8eVaFm1W7XDHfhArBYjI/edit?usp=sharing) 
* To Do:  
- [ ] Select a first pass range of features

------------------------------------

# 11.11-13 \- Surafel

* Finalized hyperparameter tuning for our models of choice: LASSO Logistic Regression, Decision Tree Classifier, Random Forest Classifier
* Logistic regression parameters that were tuned:
** C (Inverse of regularization parameter: Smaller C = stronger regularization)
* Decision tree parameters that were tuned:
- [ ] Criterion (gini or entropy), max depth, minimum samples of split, minimum samples of leaf
* Random forest parameters that were tuned:
- [ ] Max depth, minimum samples of split, minimum samples of leaf, max features
* Used PR-AUC/Average Precision metric to decide on optimal metrics, but also looked at ROC-AUC and Brier Score
* Uploaded all notebooks for hyperparameter tuning
* Ran 10-Fold cross validation comparing all three models using: PR-AUC/Average Precision, ROC-AUC, Brier score, Expected Calibration Error (ECE)
- [ ] Random forest had the best performance generally
- [ ] Uploaded notebook for cross-val (preprocessing_pipeline)
- [ ] Uploaded visuals in plots folder of my branch
