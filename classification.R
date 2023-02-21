############################ Step 0: Load libraries
library(pacman)
p_load(NHANES, tidyverse, tidymodels, naniar, Amelia, discrim, naivebayes, gt)

############################ Step 1: Understand and explore data
data(NHANES)
head(NHANES)

############################ Step 2: Prepare and explore data (pre-processing)
# Select variables and drop NA's
NHANES_SleepTrouble <- NHANES |> select(-ID, -SleepHrsNight) |> 
  select(SleepTrouble, everything()) |> 
  drop_na(SleepTrouble)

# Summarize sleep trouble
NHANES_SleepTrouble |> group_by(SleepTrouble) |> 
  summarize(n = n()) |> 
  mutate(freq = n / sum(n))
# 75% don't have sleep trouble, 25% have sleep trouble

# Split the data to train and test using rsample
NHANES_SleepTrouble_split <- initial_split(NHANES_SleepTrouble,
                                           prop = 0.75)
NHANES_SleepTrouble_split

NHANES_SleepTrouble_split |> training()

NHANES_SleepTrouble_split |> training() |> Amelia::missmap()

# kNN - Select variables and drop NA's
NHANES_SleepTrouble_num <- NHANES |> select(-ID, -SleepHrsNight) |> 
  select(SleepTrouble, where(is.numeric)) |> 
  drop_na(SleepTrouble)

# Split the data to train and test using rsample
NHANES_SleepTrouble_num_split <- initial_split(NHANES_SleepTrouble_num,
                                               prop = 0.75)
NHANES_SleepTrouble_num_split

NHANES_SleepTrouble_num_split |> training()

NHANES_SleepTrouble_num_split |> training() |> Amelia::missmap()

# Prepare recipe
# Removed near zero variance variables
# Imputed using kNN
NHANES_SleepTrouble_rec <- training(NHANES_SleepTrouble_split) |> 
  recipe(SleepTrouble ~ .) |> 
  step_nzv(all_predictors()) |> 
  step_impute_knn(all_predictors()) |> 
  prep()
summary(NHANES_SleepTrouble_rec)
tidy(NHANES_SleepTrouble_rec)

NHANES_SleepTrouble_test <- NHANES_SleepTrouble_rec |> 
  bake(testing(NHANES_SleepTrouble_split))
NHANES_SleepTrouble_train <- juice(NHANES_SleepTrouble_rec)

# Prepare recipe
# Removed near zero variance variables
# Imputed using kNN
NHANES_SleepTrouble_num_rec <- training(NHANES_SleepTrouble_num_split) |> 
  recipe(SleepTrouble ~ .) |> 
  step_normalize(all_predictors()) |> 
  step_nzv(all_predictors()) |> 
  step_impute_knn(all_predictors()) |> 
  prep()
summary(NHANES_SleepTrouble_num_rec)
tidy(NHANES_SleepTrouble_num_rec)

NHANES_SleepTrouble_num_test <- NHANES_SleepTrouble_num_rec |> 
  bake(testing(NHANES_SleepTrouble_split))
NHANES_SleepTrouble_num_train <- juice(NHANES_SleepTrouble_num_rec)

# Prepare recipe
# Removed near zero variance variables
# Imputed using kNN
# Removed highly correlated features
NHANES_SleepTrouble_log_rec <- training(NHANES_SleepTrouble_split) |> 
  recipe(SleepTrouble ~ .) |> 
  step_nzv(all_predictors()) |> 
  step_impute_knn(all_predictors()) |> 
  step_corr(all_numeric()) |> 
  prep()
summary(NHANES_SleepTrouble_log_rec)
tidy(NHANES_SleepTrouble_log_rec)

NHANES_SleepTrouble_log_test <- NHANES_SleepTrouble_log_rec |> 
  bake(testing(NHANES_SleepTrouble_split))
NHANES_SleepTrouble_log_train <- juice(NHANES_SleepTrouble_log_rec)

############################ Step 3: Train model
############## Logistic Regression
NHANES_SleepTrouble_log <- logistic_reg() |> 
  set_engine("glm") |> 
  set_mode("classification") |> 
  fit(SleepTrouble ~ ., data = NHANES_SleepTrouble_log_train)
head(predict(NHANES_SleepTrouble_log, NHANES_SleepTrouble_log_test))

############## kNN
NHANES_SleepTrouble_knn <- nearest_neighbor(neighbors = 9) |> 
  set_engine("kknn") |> 
  set_mode("classification") |> 
  fit(SleepTrouble ~ ., data = NHANES_SleepTrouble_num_train)
head(predict(NHANES_SleepTrouble_knn, NHANES_SleepTrouble_num_test))

############## Random Forest
NHANES_SleepTrouble_ranger <- rand_forest(trees = 100) |> 
  set_engine("ranger") |> 
  set_mode("classification") |> 
  fit(SleepTrouble ~ ., data = NHANES_SleepTrouble_train)
head(predict(NHANES_SleepTrouble_ranger, NHANES_SleepTrouble_test))

############## Decision Tree
NHANES_SleepTrouble_c5 <- boost_tree(trees = 100) |> 
  set_engine("C5.0") |> 
  set_mode("classification") |> 
  fit(SleepTrouble ~ ., data = NHANES_SleepTrouble_train)
head(predict(NHANES_SleepTrouble_c5, NHANES_SleepTrouble_test))

############## Naive Bayes
NHANES_SleepTrouble_nb <- naive_Bayes() |> 
  set_engine("naivebayes") |> 
  fit(SleepTrouble ~ ., data = NHANES_SleepTrouble_train)
head(predict(NHANES_SleepTrouble_nb, NHANES_SleepTrouble_test))



############################ Step 4: Evaluate models
# Look at accuracy and kappa
############## Logistic Regression
NHANES_SleepTrouble_log |> 
  predict(NHANES_SleepTrouble_log_test) |> 
  bind_cols(NHANES_SleepTrouble_log_test) |> 
  metrics(truth = SleepTrouble, estimate = .pred_class)

############## kNN
NHANES_SleepTrouble_knn |> 
  predict(NHANES_SleepTrouble_num_test) |> 
  bind_cols(NHANES_SleepTrouble_num_test) |> 
  metrics(truth = SleepTrouble, estimate = .pred_class)

############## Random Forest
NHANES_SleepTrouble_ranger |> 
  predict(NHANES_SleepTrouble_test) |> 
  bind_cols(NHANES_SleepTrouble_test) |> 
  metrics(truth = SleepTrouble, estimate = .pred_class)

############## Decision Tree
NHANES_SleepTrouble_c5 |> 
  predict(NHANES_SleepTrouble_test) |> 
  bind_cols(NHANES_SleepTrouble_test) |> 
  metrics(truth = SleepTrouble, estimate = .pred_class)

############## Naive Bayes
NHANES_SleepTrouble_nb |> 
  predict(NHANES_SleepTrouble_test) |> 
  bind_cols(NHANES_SleepTrouble_test) |> 
  metrics(truth = SleepTrouble, estimate = .pred_class)


# View confusion matrices
############## Logistic Regression
NHANES_SleepTrouble_log |> 
  predict(NHANES_SleepTrouble_log_test) |> 
  bind_cols(NHANES_SleepTrouble_log_test) |> 
  conf_mat(truth = SleepTrouble, estimate = .pred_class)

############## kNN
NHANES_SleepTrouble_knn |> 
  predict(NHANES_SleepTrouble_num_test) |> 
  bind_cols(NHANES_SleepTrouble_num_test) |> 
  conf_mat(truth = SleepTrouble, estimate = .pred_class)

############## Random forest
NHANES_SleepTrouble_ranger |> 
  predict(NHANES_SleepTrouble_test) |> 
  bind_cols(NHANES_SleepTrouble_test) |> 
  conf_mat(truth = SleepTrouble, estimate = .pred_class)

############## Decision Tree
NHANES_SleepTrouble_c5 |> 
  predict(NHANES_SleepTrouble_test) |> 
  bind_cols(NHANES_SleepTrouble_test) |> 
  conf_mat(truth = SleepTrouble, estimate = .pred_class)

############## Naive Bayes
NHANES_SleepTrouble_nb |> 
  predict(NHANES_SleepTrouble_test) |> 
  bind_cols(NHANES_SleepTrouble_test) |> 
  conf_mat(truth = SleepTrouble, estimate = .pred_class)


# Plot ROC AUC for both models
levels(NHANES$SleepTrouble)

# Set event level as second since yes is second level - most modeling packages assume the first level is of interest
############## Logistic Regression
NHANES_SleepTrouble_log_preds <- NHANES_SleepTrouble_log |> 
  augment(NHANES_SleepTrouble_log_test)
NHANES_SleepTrouble_log_preds |> 
  roc_curve(SleepTrouble, .pred_Yes, event_level = "second") |> 
  ggplot(aes(x= 1-specificity, y = sensitivity)) +
  geom_path() +
  geom_abline(lty = 3) +
  coord_equal()

log_pred <- NHANES_SleepTrouble_log |> 
  augment(NHANES_SleepTrouble_log_test) |> 
  mutate(model = "Logistic Regression")

############## kNN
NHANES_SleepTrouble_knn_preds <- NHANES_SleepTrouble_knn |> 
  augment(NHANES_SleepTrouble_num_test)
NHANES_SleepTrouble_knn_preds |> 
  roc_curve(SleepTrouble, .pred_Yes, event_level = "second") |> 
  ggplot(aes(x= 1-specificity, y = sensitivity)) +
  geom_path() +
  geom_abline(lty = 3) +
  coord_equal()

knn_pred <- NHANES_SleepTrouble_knn |> 
  augment(NHANES_SleepTrouble_num_test) |> 
  mutate(model = "kNN")

############## Random Forest
NHANES_SleepTrouble_ranger_preds <- NHANES_SleepTrouble_ranger |> 
  augment(NHANES_SleepTrouble_test)
NHANES_SleepTrouble_ranger_preds |> 
  roc_curve(SleepTrouble, .pred_Yes, event_level = "second") |> 
  ggplot(aes(x= 1-specificity, y = sensitivity)) +
  geom_path() +
  geom_abline(lty = 3) +
  coord_equal()

ranger_pred <- NHANES_SleepTrouble_ranger |> 
  augment(NHANES_SleepTrouble_test) |> 
  mutate(model = "Random Forest")

############## Decision Tree
NHANES_SleepTrouble_c5_preds <- NHANES_SleepTrouble_c5|> 
  augment(NHANES_SleepTrouble_test)
NHANES_SleepTrouble_c5_preds |> 
  roc_curve(SleepTrouble, .pred_Yes, event_level = "second") |> 
  ggplot(aes(x= 1-specificity, y = sensitivity)) +
  geom_path() +
  geom_abline(lty = 3) +
  coord_equal()

c5_pred <- NHANES_SleepTrouble_c5 |> 
  augment(NHANES_SleepTrouble_test) |> 
  mutate(model = "C5.0")

############## Naive Bayes
NHANES_SleepTrouble_nb_preds <- NHANES_SleepTrouble_nb |> 
  augment(NHANES_SleepTrouble_test)
NHANES_SleepTrouble_nb_preds |> 
  roc_curve(SleepTrouble, .pred_Yes, event_level = "second") |> 
  ggplot(aes(x= 1-specificity, y = sensitivity)) +
  geom_path() +
  geom_abline(lty = 3) +
  coord_equal()

nb_pred <- NHANES_SleepTrouble_nb |> 
  augment(NHANES_SleepTrouble_test) |> 
  mutate(model = "Naive Bayes")


# levels(titanic_train2$survived)
models_out <- bind_rows(c5_pred, ranger_pred,nb_pred, knn_pred, log_pred) 
models_out |> 
  group_by(model) |> 
  roc_curve(event_level = 'second', truth = SleepTrouble, .pred_Yes) |> 
  ggplot(aes(x = 1 - specificity, y = sensitivity, color = model)) + 
  geom_line(size = 1.1) +
  geom_abline(slope = 1, intercept = 0, size = 0.4) +
  scale_fill_brewer() +
  coord_fixed()
mod_comparison <- models_out |> 
  group_by(model) |> 
  roc_auc(event_level = 'second', truth = SleepTrouble, .pred_Yes) |> 
  arrange(desc(.estimate))
mod_comparison |> mutate(roc_auc = .estimate) |>
  select(model, roc_auc) |> gt()
