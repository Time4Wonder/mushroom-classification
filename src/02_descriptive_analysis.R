# 02_descriptive_analysis.R
# Target-oriented descriptive analysis of the mushroom dataset

# --- 1. Setup ---
data <- readRDS("data/processed/mushroom_clean_full.rds")

dir.create("docs/plots", recursive = TRUE, showWarnings = FALSE)

# --- 2. Cramers's V for all features vs class ---
cramers_v <- function(x, y) {
  tab <- table(x, y)
  ct <- suppressWarnings(chisq.test(tab, simulate.p.value = TRUE, B = 2000))
  chi2 <- as.numeric(ct$statistic)
  n <- sum(tab)
  sqrt(chi2 / (n * min(nrow(tab) - 1, ncol(tab) - 1)))
}

features <- setdiff(names(data), "class")
cv <- sapply(data[features], function(x) cramers_v(x, data$class))
cv_sorted <- sort(cv, decreasing = TRUE)

cat("Cramers's V (class vs. feature):\n")
print(round(cv_sorted, 4))

# --- 3. Overview plot: Cramers's V horizontal bar chart ---
png("docs/plots/cramers_v.png", width = 800, height = 600)
par(mar = c(5, 13, 4, 2))
barplot(rev(cv_sorted), horiz = TRUE, las = 1,
        xlab = expression("Cramers's V"), xlim = c(0, 1),
        main = "Assoziation der Merkmale mit der Zielvariable (class)",
        col = "steelblue", border = NA)
dev.off()
cat("Saved: docs/plots/cramers_v.png\n")

# --- 4. Conditional bar plots for top 8 features ---
top8 <- names(head(cv_sorted, 8))

png("docs/plots/top8_conditional_barplots.png",
    width = 14, height = 18, units = "in", res = 150)
par(mfrow = c(4, 2), mar = c(4, 4, 3, 2))

for (feat in top8) {
  tab <- table(data[[feat]], data$class)
  prop <- prop.table(tab, margin = 1)
  barplot(t(prop), beside = TRUE, legend.text = TRUE,
          args.legend = list(x = "topright", cex = 0.7),
          main = paste("Klassenanteil nach", feat),
          xlab = feat, ylab = "Anteil",
          ylim = c(0, 1), col = c("darkgreen", "red"))
}

dev.off()
cat("Saved: docs/plots/top8_conditional_barplots.png\n")

# --- 5. Univariate summaries ---
cat("\n--- Univariate summaries ---\n")
cat("\nTarget distribution:\n")
print(table(data$class))
print(prop.table(table(data$class)))
