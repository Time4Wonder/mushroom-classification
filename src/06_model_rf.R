# 06_model_rf.R
# Random Forest (Ch. 4.1, Ensemble-Erweiterung)
# Manual 10-fold CV for mtry tuning, trained on reduced variant
# Variable importance plots, ROC curves

library(randomForest)
library(pROC)

metrics <- function(cm, label) {
  TP <- cm["edible", "edible"]
  TN <- cm["poisonous", "poisonous"]
  FP <- cm["edible", "poisonous"]
  FN <- cm["poisonous", "edible"]
  cat(sprintf("--- %s ---\n", label))
  cat("Confusion Matrix:\n")
  print(cm)
  cat(sprintf("Accuracy:      %.4f\n", (TP + TN) / sum(cm)))
  cat(sprintf("Sensitivity:   %.4f  (edible correct)\n", TP / (TP + FN)))
  cat(sprintf("Specificity:   %.4f  (poisonous correct)\n", TN / (TN + FP)))
  cat(sprintf("Precision:     %.4f  (edible predicted correct)\n", TP / (TP + FP)))
  cat(sprintf("Balanced Acc:  %.4f\n", (TP/(TP+FN) + TN/(TN+FP)) / 2))
  cat(sprintf("FN rate:       %.4f  (giftig -> essbar = TOD)\n", FN / (FN + TP)))
  cat(sprintf("FP rate:       %.4f  (essbar -> giftig)\n", FP / (FP + TN)))
  cat(sprintf("FN count:      %d\n", FN))
  cat(sprintf("FP count:      %d\n\n", FP))
  invisible(list(TP = TP, TN = TN, FP = FP, FN = FN))
}

# --- Manual stratified 10-fold CV for mtry tuning ---
tune_mtry <- function(train_data, mtry_values, n_folds = 10, ntree = 500) {
  set.seed(467)
  y <- train_data$class
  n <- nrow(train_data)
  folds <- vector("list", n_folds)
  classes <- unique(y)
  for (cls in classes) {
    idx <- which(y == cls)
    folds_cls <- split(idx, cut(seq_along(idx), n_folds, labels = FALSE))
    for (k in seq_len(n_folds)) {
      folds[[k]] <- c(folds[[k]], folds_cls[[k]])
    }
  }

  cv_results <- data.frame(mtry = integer(), accuracy = numeric(), stringsAsFactors = FALSE)

  for (m in mtry_values) {
    acc_folds <- numeric(n_folds)
    for (k in seq_len(n_folds)) {
      train_idx <- setdiff(seq_len(n), folds[[k]])
      rf_cv <- randomForest(class ~ ., data = train_data[train_idx, ],
                            mtry = m, ntree = ntree,
                            importance = FALSE)
      pred_cv <- predict(rf_cv, newdata = train_data[folds[[k]], ])
      cm_cv <- table(pred_cv, train_data[folds[[k]], "class"])
      acc_folds[k] <- sum(diag(cm_cv)) / sum(cm_cv)
    }
    cv_results <- rbind(cv_results, data.frame(mtry = m, accuracy = mean(acc_folds)))
    cat(sprintf("  mtry = %2d: CV Accuracy = %.4f\n", m, mean(acc_folds)))
  }
  best_mtry <- cv_results$mtry[which.max(cv_results$accuracy)]
  cat(sprintf("  -> Best mtry = %d\n\n", best_mtry))
  list(results = cv_results, best_mtry = best_mtry)
}

dir.create("docs/plots", recursive = TRUE, showWarnings = FALSE)

# =====================================================================
# 1. REDUCED VARIANT (19 features)
# =====================================================================
cat("=================================================================\n")
cat("RANDOM FOREST: Reduced Variante (19 Features)\n")
cat("=================================================================\n\n")

train_reduced <- readRDS("data/processed/train_reduced.rds")
test_reduced  <- readRDS("data/processed/test_reduced.rds")

p <- ncol(train_reduced) - 1
cat(sprintf("Features: %d, ntrain: %d, ntest: %d\n\n", p, nrow(train_reduced), nrow(test_reduced)))

# --- Tune mtry via 10-fold CV ---
mtry_candidates <- seq(2, min(p, 12))
cat("--- mtry Tuning (10-fold CV) ---\n")
tune_reduced <- tune_mtry(train_reduced, mtry_candidates)

# --- Final model with best mtry ---
rf_reduced <- randomForest(class ~ ., data = train_reduced,
                           mtry = tune_reduced$best_mtry, ntree = 500,
                           importance = TRUE)

cat("--- OOB Error ---\n")
cat(sprintf("OOB estimate of error rate: %.2f%%\n\n", tail(rf_reduced$err.rate[, "OOB"], 1) * 100))

# --- OOB error plot ---
png("docs/plots/rf_oob_reduced.png", width = 800, height = 600)
plot(rf_reduced, main = "RF Reduced: OOB Error vs. ntree")
dev.off()
cat("Saved: docs/plots/rf_oob_reduced.png\n\n")

# --- Variable importance ---
png("docs/plots/rf_importance_reduced.png", width = 800, height = 600)
varImpPlot(rf_reduced, main = "RF Reduced: Variable Importance",
           n.var = min(19, nrow(rf_reduced$importance)))
dev.off()
cat("Saved: docs/plots/rf_importance_reduced.png\n\n")

cat("Variable Importance (Mean Decrease Gini):\n")
imp_reduced <- importance(rf_reduced)
print(imp_reduced[order(imp_reduced[, "MeanDecreaseGini"], decreasing = TRUE), ])

# --- Predict ---
pred_rf_r <- predict(rf_reduced, newdata = test_reduced)
cm_rf_r <- table(Predicted = pred_rf_r, Actual = test_reduced$class)
metrics(cm_rf_r, "Random Forest Reduced")

# --- ROC ---
prob_rf_r <- predict(rf_reduced, newdata = test_reduced, type = "prob")[, "edible"]
roc_rf_r <- roc(test_reduced$class, prob_rf_r, levels = c("poisonous", "edible"))
cat(sprintf("AUC (Reduced): %.4f\n\n", auc(roc_rf_r)))

# --- Save ---
saveRDS(rf_reduced, "data/processed/rf_model_reduced.rds")
cat("Saved: data/processed/rf_model_reduced.rds\n\n")

# =====================================================================
# 2. COMPARISON TABLE
# =====================================================================
cat("=================================================================\n")
cat("VERGLEICH: RF Reduced vs. Tree Cost-sensitive vs. Tree Standard\n")
cat("=================================================================\n\n")

extract <- function(cm) {
  list(FP = cm["edible", "poisonous"],
       FN = cm["poisonous", "edible"],
       TP = cm["edible", "edible"],
       TN = cm["poisonous", "poisonous"])
}

e_r <- extract(cm_rf_r)

tree_cost <- readRDS("data/processed/tree_model_cost.rds")
pred_tc <- predict(tree_cost, newdata = test_reduced, type = "class")
cm_tc <- table(Predicted = pred_tc, Actual = test_reduced$class)
e_tc <- extract(cm_tc)

tree_std <- readRDS("data/processed/tree_model.rds")
pred_ts <- predict(tree_std, newdata = test_reduced, type = "class")
cm_ts <- table(Predicted = pred_ts, Actual = test_reduced$class)
e_ts <- extract(cm_ts)

cat(sprintf("%-30s %12s %12s %12s\n",
            "Metrik", "RF Reduced", "Tree Cost", "Tree Std"))
cat(sprintf("%s\n", strrep("-", 58)))
cat(sprintf("%-30s %12d %12d %12d\n",
            "FP (TOD)", e_r$FP, e_tc$FP, e_ts$FP))
cat(sprintf("%-30s %12d %12d %12d\n",
            "FN (harmlos)", e_r$FN, e_tc$FN, e_ts$FN))
cat(sprintf("%-30s %12.4f %12.4f %12.4f\n", "Accuracy",
  (e_r$TP+e_r$TN)/sum(unlist(e_r)),
  (e_tc$TP+e_tc$TN)/sum(unlist(e_tc)),
  (e_ts$TP+e_ts$TN)/sum(unlist(e_ts))))
cat(sprintf("%-30s %12.4f %12.4f %12.4f\n", "Sensitivity",
  e_r$TP/(e_r$TP+e_r$FN), e_tc$TP/(e_tc$TP+e_tc$FN), e_ts$TP/(e_ts$TP+e_ts$FN)))
cat(sprintf("%-30s %12.4f %12.4f %12.4f\n", "Specificity",
  e_r$TN/(e_r$TN+e_r$FP), e_tc$TN/(e_tc$TN+e_tc$FP), e_ts$TN/(e_ts$TN+e_ts$FP)))
cat(sprintf("%-30s %12s %12s %12s\n", "Interpretierbar",
  "Nein", "Ja", "Ja"))
