# 05_model_tree.R
# Decision Tree (rpart) — Ch. 4.1
# Trained on reduced variant (19 features, without odor + spore_print_color)
# Includes cost-sensitive variant (FN 10x worse than FP)

library(rpart)
library(rpart.plot)

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
  cat(sprintf("FN rate:       %.4f  (giftig -> essbar = TOD)\n", FN / (FN + TP)))
  cat(sprintf("FP rate:       %.4f  (essbar -> giftig)\n", FP / (FP + TN)))
  cat(sprintf("FN count:      %d\n", FN))
  cat(sprintf("FP count:      %d\n\n", FP))
}

# --- 1. Setup ---
train <- readRDS("data/processed/train_reduced.rds")
test  <- readRDS("data/processed/test_reduced.rds")

# =====================================================================
# TREE A: Standard (keine Kosten, 1:1)
# =====================================================================
cat("=================================================================\n")
cat("TREE A: Standard (keine Kosten, FP = FN = 1)\n")
cat("=================================================================\n\n")

tree_a <- rpart(class ~ ., data = train, method = "class",
                control = rpart.control(cp = 0.001, xval = 10))

cat("--- cp Table ---\n")
printcp(tree_a)

cp_table <- tree_a$cptable
best_row <- which.min(cp_table[, "xerror"])
best_cp  <- cp_table[best_row, "CP"]
se_threshold <- cp_table[best_row, "xerror"] + cp_table[best_row, "xstd"]
se_cp <- max(cp_table[cp_table[, "xerror"] <= se_threshold, "CP"])

cat(sprintf("\n1-SE rule: min xerror at cp=%.6f, selected cp=%.6f\n\n", best_cp, se_cp))

pruned_a <- prune(tree_a, cp = se_cp)
cat("Tree structure:\n")
print(pruned_a)
cat("Number of splits:", nrow(pruned_a$frame) - 1, "\n\n")

pred_a <- predict(pruned_a, newdata = test, type = "class")
cm_a <- table(Predicted = pred_a, Actual = test$class)
metrics(cm_a, "Standard Tree (1:1)")

# =====================================================================
# TREE B: Cost-sensitive (FN 10x schlimmer als FP)
# =====================================================================
cat("=================================================================\n")
cat("TREE B: Cost-sensitive (FN 10x, FP 1x)\n")
cat("=================================================================\n\n")

cost <- matrix(c(0, 1,    # true edible: FP kostet 1
                 10, 0),  # true poisonous: FN kostet 10
               nrow = 2, byrow = TRUE,
               dimnames = list(levels(train$class), levels(train$class)))

tree_b <- rpart(class ~ ., data = train, method = "class",
                parms = list(loss = cost),
                control = rpart.control(cp = 0.001, xval = 10))

cat("--- cp Table ---\n")
printcp(tree_b)

cp_table_b <- tree_b$cptable
best_row_b <- which.min(cp_table_b[, "xerror"])
se_cp_b <- max(cp_table_b[cp_table_b[, "xerror"] <=
              cp_table_b[best_row_b, "xerror"] + cp_table_b[best_row_b, "xstd"], "CP"])

cat(sprintf("\n1-SE rule: selected cp=%.6f\n\n", se_cp_b))

pruned_b <- prune(tree_b, cp = se_cp_b)
cat("Tree structure:\n")
print(pruned_b)
cat("Number of splits:", nrow(pruned_b$frame) - 1, "\n\n")

pred_b <- predict(pruned_b, newdata = test, type = "class")
cm_b <- table(Predicted = pred_b, Actual = test$class)
metrics(cm_b, "Cost-sensitive Tree (FN 10x)")

# =====================================================================
# VERGLEICH
# =====================================================================
cat("=================================================================\n")
cat("VERGLEICH: Standard vs. Cost-sensitive\n")
cat("=================================================================\n\n")

cat(sprintf("%-30s %12s %12s\n", "Metrik", "Standard (1:1)", "Cost (FN 10x)"))
cat(sprintf("%s\n", strrep("-", 56)))

fp_a <- cm_a["edible", "poisonous"]
fn_a <- cm_a["poisonous", "edible"]
fp_b <- cm_b["edible", "poisonous"]
fn_b <- cm_b["poisonous", "edible"]

cat(sprintf("%-30s %12d %12d\n", "FP (giftig -> essbar = TOD)", fp_a, fp_b))
cat(sprintf("%-30s %12d %12d\n", "FN (essbar -> giftig = harmlos)", fn_a, fn_b))
cat(sprintf("%-30s %12.4f %12.4f\n", "Accuracy",
  (sum(diag(cm_a)))/sum(cm_a), (sum(diag(cm_b)))/sum(cm_b)))
cat(sprintf("%-30s %12.4f %12.4f\n", "Sensitivity",
  cm_a["edible", "edible"]/(cm_a["edible", "edible"]+fn_a),
  cm_b["edible", "edible"]/(cm_b["edible", "edible"]+fn_b)))
cat(sprintf("%-30s %12.4f %12.4f\n", "Specificity",
  cm_a["poisonous", "poisonous"]/(cm_a["poisonous", "poisonous"]+fp_a),
  cm_b["poisonous", "poisonous"]/(cm_b["poisonous", "poisonous"]+fp_b)))

# --- Plot cost-sensitive tree ---
dir.create("docs/plots", recursive = TRUE, showWarnings = FALSE)
png("docs/plots/tree_plot.png", width = 2000, height = 1400, res = 150)
rpart.plot(pruned_b, type = 2, extra = 104,
           box.palette = c("red", "green"),
           main = "Decision Tree (Cost-sensitive, FN 10x) — Reduced Variant")
dev.off()
cat("\nSaved: docs/plots/tree_plot.png\n")

# --- Save both models ---
saveRDS(pruned_a, "data/processed/tree_model.rds")
saveRDS(pruned_b, "data/processed/tree_model_cost.rds")
cat("Saved: tree_model.rds, tree_model_cost.rds\n")
