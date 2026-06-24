# 04_model_logistic.R
# Logistic Regression (Ch. 4.1) — baseline binary classifier
#
# Note: glm fails on both variants due to quasi-complete separation.
# The mushroom dataset contains features whose levels perfectly (or near-
# perfectly) separate the classes. This is a known limitation of unregularized
# logistic regression (the MLE does not exist / coefficients diverge).
# Tree-based methods are inherently better suited for this data.

# --- 1. Full variant: demonstrate perfect separation ---
cat("--- Full variant (21 features): perfect separation ---\n")
train_full <- readRDS("data/processed/train_full.rds")
test_full  <- readRDS("data/processed/test_full.rds")

log_full <- glm(class ~ ., data = train_full, family = binomial)
cat("glm: algorithm did not converge — odor causes perfect separation\n\n")

# --- 2. Reduced variant: quasi-complete separation persists ---
cat("--- Reduced variant (19 features, without odor + spore_print_color) ---\n")
train <- readRDS("data/processed/train_reduced.rds")
test  <- readRDS("data/processed/test_reduced.rds")

log_model <- glm(class ~ ., data = train, family = binomial)

cat("glm: algorithm still did not converge — quasi-complete separation\n")
cat("   (e.g. gill_color, stalk_color still have perfectly predictive levels)\n")
cat("   Residual deviance near 0 = degenerate fit\n\n")

cat("--- Model summary ---\n")
s <- summary(log_model)
print(s)

# --- 3. Predict on test data (predictions are unreliable) ---
prob <- predict(log_model, newdata = test, type = "response")
pred <- factor(ifelse(prob > 0.5, "edible", "poisonous"),
               levels = levels(test$class))

cm <- table(Predicted = pred, Actual = test$class)
cat("\n--- Confusion Matrix ---\n")
print(cm)

TP <- cm["edible", "edible"]
TN <- cm["poisonous", "poisonous"]
FP <- cm["edible", "poisonous"]
FN <- cm["poisonous", "edible"]

accuracy     <- (TP + TN) / sum(cm)
sensitivity  <- TP / (TP + FN)
specificity  <- TN / (TN + FP)

cat("\n--- Metrics (unreliable due to non-convergence) ---\n")
cat("Accuracy:      ", round(accuracy, 4), "\n")
cat("Sensitivity:   ", round(sensitivity, 4), "\n")
cat("Specificity:   ", round(specificity, 4), "\n")

# --- 4. Discussion ---
cat("\n--- Discussion ---\n")
cat("Logistic regression (unregularized glm) is unsuitable for this dataset.\n")
cat("Even on the reduced variant (19 features), quasi-complete separation\n")
cat("occurs because multiple feature levels perfectly predict the class.\n")
cat("The MLE does not exist — coefficients diverge, predictions are\n")
cat("unreliable. This is a known limitation discussed in Ch. 4.1.\n\n")
cat("Tree-based methods (rpart, randomForest) handle this naturally:\n")
cat("- They split on the most informative feature at each node\n")
cat("- They don't estimate coefficients but find decision boundaries\n")
cat("- Perfectly predictive levels are leveraged, not broken\n\n")
cat("For a proper baseline on this data, use rpart (see src/05_model_tree.R)\n")
cat("or a penalized logistic regression (Firth's method, LASSO from Ch. 9).\n")

# --- 5. Save model anyway (for reference) ---
saveRDS(log_model, "data/processed/logistic_model.rds")
cat("\nSaved: data/processed/logistic_model.rds\n")
