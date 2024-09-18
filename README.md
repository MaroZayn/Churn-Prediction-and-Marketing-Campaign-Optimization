# Churn-Prediction-and-Marketing-Campaign-Optimization
## Overview
This project focuses on predicting customer churn and optimizing marketing campaigns using Machine Learning models. The goal is to identify customers likely to churn and maximize profits from marketing efforts by contacting the right individuals.

## Data Preprocessing
We started by preparing our data to ensure it was ready for modeling. The steps involved:
1. **Filtering and Merging Data**: We filtered datasets separately before merging them for analysis and model input.
2. **Handling Missing and Extreme Values**: Various operations were performed depending on the dataset:

### Main Dataset (data1)
- Converted the variable `si2014` to a factor and transformed `ultimo_ing.x`, `abb13`, and `abb14` into date objects.
- Created a new variable `abb14_renewed`, which is set to 1 if a renewal date exists in 2014 (non-missing `abb14`) and 0 otherwise. This variable acts as an indicator of renewal.

### Handling Missing Dates
- For individuals who never visited the museum (not in `in13`), missing last visit dates (`ultimo_ing.x`) were replaced with the subscription start date (`abb13`).
- For individuals who visited the museum (in `an13`), missing last visit dates were replaced with dates found in the visit records (`an13`).

### Visit Dataset (in13)
- No modifications were made, as this dataset had no missing or incorrect values.

### Customer Information Dataset (an13)
- The variable `professionne` was removed as it only contained missing values.
- Missing values in the `sesso` (gender) variable were replaced with "Unknown".
- Extreme values were handled, such as nonsensical birth year values (e.g., 902, 903, 2013).

After handling these issues, we merged the datasets into a single dataset named `churn` and encoded all binary variables. This explains variables like `sesso_F` and `tipo_pag_ACQUISTO ON-LINE` in our code.

## Modeling (Machine Learning)
The goal was to predict customer renewal (target variable: `si2014`) for marketing purposes. We tested various statistical methods to select the most relevant features (X) for our predictions.

### Classification Models Used:
- Logistic Regression
- Decision Trees
- Random Forest
- XGBoost

### Model Tuning
Before and after hyperparameter tuning, we observed improvements in model performance, particularly for Random Forest, which saw an increase from 69% to 75% accuracy. This means that the model correctly predicted non-renewal for 3 out of 4 individuals.

### ROC Curve and AUC
The ROC curve shows the relationship between the true positive rate (sensitivity) and false positive rate (1 - specificity) for different classification thresholds. The AUC (Area Under the Curve) measures model performance, where a value close to 1 indicates strong predictive ability.

- **Best Model**: XGBoost with an AUC of 0.78, suggesting reasonable discrimination between churners and non-churners.
- **Probability Distribution**: The Random Forest model accurately classifies non-churners with high probability but struggles with churners.

## Profit Curve
The marketing campaign aims to reduce churn by contacting individuals, with each contact costing €0.20. There are two outcomes:
1. **Churner Contact**: Relevant contact, resulting in a profit of (10 – cost).
2. **Non-Churner Contact**: Irrelevant contact, incurring a cost of (10 – amount paid – cost).

The profit formula used is based on this understanding.

## Conclusion
Our models proved to be a valuable decision-making tool for the marketing campaign, with profit curves closely matching theoretical expectations. We could further enhance model performance by collecting more data and improving the data preprocessing phase.
