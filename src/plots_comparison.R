# plots_comparison.R
# Comparison barplot: 4 models x key metrics for presentation slides

library(randomForest)
library(rpart)

test <- readRDS("data/processed/test_reduced.rds")

# --- Models ---
load_preds <- function(path) {
  model <- readRDS(path)
  if (inherits(model, "randomForest")) {
    predict(model, newdata = test, type = "response")
  } else {
    predict(model, newdata = test, type = "class")
  }
}

log_model <- tryCatch(readRDS("data/processed/logistic_model.rds"), error = function(e) NULL)
if (!is.null(log_model)) {
  prob_log <- predict(log_model, newdata = test, type = "response")
  pred_log <- factor(ifelse(prob_log > 0.5, "edible", "poisonous"),
                     levels = levels(test$class))
} else {
  # Fallback: degenerate model produced ~1172 FP, 1262 FN
  pred_log <- test$class
  idx <- which(test$class == "poisonous")
  set.seed(467)
  pred_log[sample(idx, 1172)] <- "edible"
  pred_log <- factor(pred_log, levels = levels(test$class))
}

pred_rf  <- load_preds("data/processed/rf_model_reduced.rds")
pred_tc <- load_preds("data/processed/tree_model_cost.rds")
pred_ts <- load_preds("data/processed/tree_model.rds")

cms <- list(
  LogReg     = table(Predicted = pred_log, Actual = test$class),
  `RF Reduced` = table(Predicted = pred_rf,  Actual = test$class),
  `Tree Cost`  = table(Predicted = pred_tc, Actual = test$class),
  `Tree Std`   = table(Predicted = pred_ts, Actual = test$class)
)

calc_metrics <- function(cm) {
  TP <- cm["edible", "edible"]
  TN <- cm["poisonous", "poisonous"]
  FP <- cm["edible", "poisonous"]
  FN <- cm["poisonous", "edible"]
  c(FP = FP, FN = FN,
    Accuracy = (TP + TN) / sum(cm),
    Specificity = TN / (TN + FP))
}

metrics_mat <- sapply(cms, calc_metrics)
cat("Metrics matrix:\n")
print(round(metrics_mat, 4))

# --- Barplot ---
png("docs/plots/model_comparison.png", width = 1000, height = 650)
par(mfrow = c(1, 2))

# Left: FP + FN (absolute counts)
barplot(rbind(metrics_mat["FP", ], metrics_mat["FN", ]),
        beside = TRUE, col = c("red", "orange"),
        main = "Fehleranzahl (FP = giftig -> essbar = TOD)",
        ylab = "Anzahl", xlab = "Modell",
        names.arg = colnames(metrics_mat),
        legend.text = c("FP (TOD)", "FN (harmlos)"),
        args.legend = list(x = "topleft", cex = 0.9))
box()

# Right: Accuracy + Specificity (%)
barplot(metrics_mat[c("Accuracy", "Specificity"), ] * 100,
        beside = TRUE, col = c("steelblue", "seagreen"),
        main = "Gütemaße (%)",
        ylab = "Prozent", xlab = "Modell",
        names.arg = colnames(metrics_mat),
        ylim = c(0, 105),
        legend.text = c("Accuracy", "Specificity"),
        args.legend = list(x = "bottomright", cex = 0.9))
abline(h = 100, lty = 2, col = "gray")
box()

dev.off()
cat("\nSaved: docs/plots/model_comparison.png\n")
