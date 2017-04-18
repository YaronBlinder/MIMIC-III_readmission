# Predicting 30-day ICU readmissions from the MIMIC-III database


This project was developed as the Capstone project for the Udacity Machine Learning Engineer Nanodegree. Full description and discussion can be found in [Report.pdf](Report.pdf).


## Project Overview

This project describes the development of a model for predicting whether a patient discharged from an intensive care unit (ICU) is likely to be readmitted within 30 days. To do this, I used the MIMIC-III database which contains details records from ~60,000 ICU admissions for ~40,000 patients over a period of 10 years. Using these records, patient records for those readmitted within 30 days of discharge were isolated and used to train a generalized classifier to predict readmission. The project also includes parameter optimization and in depth performance analysis for the classifier.

### Data
This project uses the MIMIC-III database, accessible via:
https://mimic.physionet.org/

To properly run the project from the included files, a local postgres SQL server must be installed and the MIMIC-III database must be set up as described in https://github.com/MIT-LCP/mimic-code/tree/master/buildmimic.

An SQL materialized view was extracted from the database as defined in all_data.sql.

### python libraries used:

- numpy - numerical operation
- pandas - dataframe handling
- os - general operating system operations
- psycopg2 - Used to access a locally installed postgresql server and
perform sql queries.
- xgboost - eXtreme Gradient Boosted trees. Classifier implementation.
- scikit-learn - Used for hyperparameter optimization and performance
metrics evaluation.
- scipy - interp function used during plotting of the ROC curve.
- matplotlib - visualization
- seaborn - visualization

### Main results:
Raw numerical data scatter matrix. A: Scatter matrix of all numerical features. B: zoomed-in view on the first 6 features. Each square shows the scatter plot corresponding to the two features defined by the row and column. The diagonal shows the kernel density estimation plots.
![features before preprocessing](figures\scatter_comb_pre.png)

Preprocessed numerical data scatter matrix. A: Scatter matrix of all numerical features. B: zoomed-in view on the first 6 features. Each square shows the scatter plot corresponding to the two features defined by the row and column. The diagonal shows the kernel density estimation plots.
![features after preprocessing](figures\scatter_comb_post.png)

Receiver Operating Characteristic curve for the optimized model, using 5-fold cross validation.
![ROC curve](figures\ROC.png)

Important features. (A) shows the features sorted by “weight”. (B) shows kde plots for the top 9 most important features, separated by label.
![Feature importance plot](figures\features.png)
