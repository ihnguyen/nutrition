# Prediction and Classification of Sleep
The purpose of this study is to predict sleeping hours and classify sleep trouble with study, demographic, physical measurement, health, and lifestyle variables based on 5,000 American participants’ health and nutrition examination surveys since early 1960’s data.

## Predicting sleeping hours with Multiple Linear Regression and Decision Tree (Regression Tree)
### Multiple Linear Regression
For the multiple regression model, an increase in the age decade is associated with a decrease in number of sleeping hours with decade 50-59 with the largest decrease. Out of Hispanic, Mexican, White and other races, Mexican race is associated with an increase of sleeping hours versus other race which has the least hours. Based on education, participants who are in high school are associated with a a decrease in sleeping hours versus other education groups. Those with lower household income are associated with an increase in sleeping hours compared to those with higher household income. Those with poor general health are associated with a decrease in sleeping hours compared to those with very good general health. Those who use the computer more than four hours a day are shown to be associated with an increase in sleeping hours than those less than four hours. Those who smoke at least 100 cigarettes a year are associated with a decrease in sleeping hours than others.

### Decision Tree (Regression Tree)
In the regression tree model, the two main predictors that explain number of sleeping hours in a weekday/workday night are number of days of poor mental health and age decade. Those with 5.5 or more days of poor mental health are predicted to have 6.2 hours of sleep. Those with less than 5.5 days of poor mental health and belong to age range 20-69 are predicted to have 6.9 hours of sleep. Those with less than 5.5 days of poor mental health and are older than 69 are predicted to have 7.3 hours of sleep.


<details><summary>Figure 1: Decision Tree</summary>
<p>
![](https://github.com/ihnguyen/nutrition/blob/main/decision_tree.png)
</p>
</details>

When comparing the models, 7% of the variability observed in the number of hours of sleep a weekday or workday night is explained by the multiple regression model whereas only 3% of the variability observed in the number of hours of sleep a weekday or workday night is explained by the decision tree model. Since linear model has the lowest RMSE of 1.29 and MAE of 1.01, the multiple linear regression model is the best at predicting number of sleeping hours per weekday/workday night in the NHANES data set.

<details><summary>Table 1: Evaluation of Null Model</summary>
<p>
![](https://github.com/ihnguyen/nutrition/blob/main/null.png)
</p>
</details>

<details><summary>Table 1: Evaluation of Multiple Linear Regression Model</summary>
<p>
![](https://github.com/ihnguyen/nutrition/blob/main/mlr.png)
</p>
</details>

<details><summary>Table 1: Evaluation of Regression Tree Model</summary>
<p>

![regression_tree2](https://user-images.githubusercontent.com/73903035/220228992-e25306a3-9647-4bbd-8d56-db8e67f9e9c2.png)

</p>
</details>




## Classifying sleep trouble with Logistic Regression, kNN, Random Forests, Naive Bayes
<details><summary>Figure 1: Missingness</summary>
<p>
![](https://github.com/ihnguyen/nutrition/blob/main/missingness.png)
</p>
</details>
### Logistic Regression
The logistic model has a 76% accuracy. Females are more likely to have sleep trouble than males. Increasing age, days with poor mental health, depression, weight, days with poor physical health, smoking at least 100 cigarettes in their life, and consuming at least 12 drinks of alcohol in one year will increase the probability of sleep trouble.

<details><summary>Figure 1: Predictions</summary>
<p>
![](https://github.com/ihnguyen/nutrition/blob/main/predictors_1.png)
</p>
</details>

<details><summary>Figure 1: Predictions</summary>
<p>
![](https://github.com/ihnguyen/nutrition/blob/main/predictors_2.png)
</p>
</details>

### kNN
The kNN model has a 89.3% accuracy and ROC AUC value is 81.5%.

### C5.0
88.0% accuracy % roc auc

### Random Forests
86.3% accuracy 88.3% roc auc

### Naive Bayes
74.6% accuracy 70.2% roc auc

When comparing the models, kNN performed the best out of the four models.

1 kNN roc_auc binary 0.933 2 C5.0 roc_auc binary 0.915 3 Random Forest roc_auc binary 0.900 4 Logistic Regression roc_auc binary 0.714 5 Naive Bayes roc_auc binary 0.703

<details><summary>Figure 1: ROC AUC Plot - Model Comparison</summary>
<p>
![](https://github.com/ihnguyen/nutrition/blob/main/rocauc.png)
</p>
</details>

<details><summary>Table 1: ROC AUC Values - Model Comparison</summary>
<p>
![](https://github.com/ihnguyen/nutrition/blob/main/rocauc.png)
</p>
</details>

## How to improve models?
- C5.0 by boosting
- Decision tree by cost or trials
- Logistic and Linear Regression by regularization
