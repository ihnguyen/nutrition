############################ Step 0: Load libraries
library(pacman)
p_load(tidyverse, mosaicData, mdsr, tidymodels, patchwork, NHANES, Amelia,
       class, modelr, popbio, ROCR, kknn, gmodels, rpart, rpart.plot, skimr,
       lessR, ggeffects, car, GGally)

############################ Step 1: Understand and explore data
# View data
data(NHANES)
# How many missing data are in the data?
Amelia::missmap(NHANES)

############################ Step 2: Prepare and explore data (pre-processing)
NHANES_SleepHrsNight <- NHANES |>  select(-ID, -SleepTrouble) |> 
  select( SleepHrsNight, everything()) |> 
  drop_na(SleepHrsNight)
head(NHANES_SleepHrsNight)
# Plot target variable
hist(NHANES_SleepHrsNight$SleepHrsNight)
# Set seed for reproducibility
# Split data into 75% train and 25% test
set.seed(123)
NHANES_SleepHrsNight_split <- initial_split(NHANES_SleepHrsNight, prop = 0.75)
NHANES_SleepHrsNight_split
# Train data
NHANES_SleepHrsNight_split |> 
  training()
# Test data
NHANES_SleepHrsNight_split |> 
  testing()
# Create recipe for pre-processing
### Near zero variance
### Imputation for missing data
### Remove highly correlated features
NHANES_SleepHrsNight_recipe <- training(NHANES_SleepHrsNight_split) |> 
  recipe(SleepHrsNight ~ .) |> 
  step_nzv(all_predictors()) |> 
  step_impute_knn(all_predictors()) |> 
  step_corr(all_numeric()) |> 
  prep()
# View recipe
summary(NHANES_SleepHrsNight_recipe)

tidy(NHANES_SleepHrsNight_recipe)

# Bake recipe in testing data
NHANES_SleepHrsNight_testing <- NHANES_SleepHrsNight_recipe |> 
  bake(testing(NHANES_SleepHrsNight_split))
# View data
head(NHANES_SleepHrsNight_testing)
# Juice recipe
NHANES_SleepHrsNight_training <- juice(NHANES_SleepHrsNight_recipe)
# View data
head(NHANES_SleepHrsNight_training)

############################ Step 3: Train model
############## Null model
NHANES_SleepHrsNight_null <- linear_reg() |>  
  set_engine("lm") |> 
  set_mode("regression") |> 
  fit(SleepHrsNight ~ 1, data = NHANES_SleepHrsNight_training)
# Predictions
NHANES_SleepHrsNight_null_pred <- predict(NHANES_SleepHrsNight_null,
                                          NHANES_SleepHrsNight_testing)
# Combine predictions with data
NHANES_SleepHrsNight_null_pred_all <-NHANES_SleepHrsNight_null_pred |> 
  bind_cols(NHANES_SleepHrsNight_testing)
head(NHANES_SleepHrsNight_null_pred_all)
# Notice that all the predictions are the same
# Plot null model
boxplot(NHANES_SleepHrsNight_training$SleepHrsNight)

############## Multiple Linear Regression
NHANES_SleepHrsNight_lm <- linear_reg() |>  
  set_engine("lm") |> 
  set_mode("regression") |> 
  fit(SleepHrsNight ~ ., data = NHANES_SleepHrsNight_training)
# Predictions
NHANES_SleepHrsNight_lm_pred <- predict(NHANES_SleepHrsNight_lm,
                                        NHANES_SleepHrsNight_testing)
# Combine predictions with data
NHANES_SleepHrsNight_lm_pred_all <-NHANES_SleepHrsNight_lm_pred |> 
  bind_cols(NHANES_SleepHrsNight_testing)
head(NHANES_SleepHrsNight_lm_pred_all)
# Notice different predictions from the null

# Plot multiple linear regression using ggeffects and patchwork libraries
mlr1 <- plot(ggeffects::ggpredict(NHANES_SleepHrsNight_lm, "AgeDecade")) +
  labs(x = "Age Decade", y = "Sleeping Hours per Night") + ggtitle("")
mlr2 <- plot(ggeffects::ggpredict(NHANES_SleepHrsNight_lm, "Race1")) +
  labs(x = "Race", y = "Sleeping Hours per Night") + ggtitle("")
mlr3 <- plot(ggeffects::ggpredict(NHANES_SleepHrsNight_lm, "HealthGen")) +
  labs(x = "General Health", y = "Sleeping Hours per Night") + ggtitle("")
mlr4 <- plot(ggeffects::ggpredict(NHANES_SleepHrsNight_lm, "BMI_WHO")) +
  labs(x = "Body Mass Index Category", y = "Sleeping Hours per Night") + ggtitle("")

mlr1 + mlr2 + mlr3 +mlr4

mlr5 <- plot(ggeffects::ggpredict(NHANES_SleepHrsNight_lm, "HHIncome")) +
  labs(x = "Household Income", y = "Sleeping Hours per Night") + ggtitle("") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
mlr6 <- plot(ggeffects::ggpredict(NHANES_SleepHrsNight_lm, "CompHrsDay")) +
  labs(x = "Computer or Gaming Hours per Day", y = "Sleeping Hours per Night") + ggtitle("")
mlr7 <- plot(ggeffects::ggpredict(NHANES_SleepHrsNight_lm, "Smoke100")) +
  labs(x = "Smoked at least 100 Cigarettes", y = "Sleeping Hours per Night") + ggtitle("")

mlr5 + mlr6 + mlr7 + plot_layout(nrow = 2, byrow = FALSE)


############## Decision Tree (Regression Tree)
show_engines("decision_tree")
NHANES_SleepHrsNight_dt <- decision_tree() |>  
  set_engine("rpart") |> 
  set_mode("regression") |> 
  fit(SleepHrsNight ~ ., data = NHANES_SleepHrsNight_training)
# Predictions
NHANES_SleepHrsNight_dt_pred <- predict(NHANES_SleepHrsNight_dt,
                                        NHANES_SleepHrsNight_testing)
# Combine predictions with data
NHANES_SleepHrsNight_dt_pred_all <-NHANES_SleepHrsNight_dt_pred |> 
  bind_cols(NHANES_SleepHrsNight_testing)
head(NHANES_SleepHrsNight_dt_pred_all)
# notice different predictions from the null

# Plot regression tree
rpart.plot(NHANES_SleepHrsNight_dt$fit)

library(gt)
############################ Step 4: Evaluate models
############## Null model
NHANES_SleepHrsNight_null |> 
  predict(NHANES_SleepHrsNight_testing) |> 
  bind_cols(NHANES_SleepHrsNight_testing) |> 
  metrics(truth = SleepHrsNight, estimate = .pred) |> 
  mutate(metric = .metric,
         estimate = .estimate) |> 
  select(metric, estimate) |>
  gt()

############## Multiple Linear Regression
NHANES_SleepHrsNight_lm |> 
  predict(NHANES_SleepHrsNight_testing) |> 
  bind_cols(NHANES_SleepHrsNight_testing) |> 
  metrics(truth = SleepHrsNight, estimate = .pred) |> 
  mutate(metric = .metric,
       estimate = .estimate) |> 
  select(metric, estimate) |>
  gt()

############## Decision Tree (Regression Tree)
NHANES_SleepHrsNight_dt |> 
  predict(NHANES_SleepHrsNight_testing) |> 
  bind_cols(NHANES_SleepHrsNight_testing) |> 
  metrics(truth = SleepHrsNight, estimate = .pred) |> 
  mutate(metric = .metric,
         estimate = .estimate) |> 
  select(metric, estimate) |>
  gt()