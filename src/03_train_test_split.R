# 03_train_test_split.R
# Stratified 70/30 train-test split (cf. Ch. 5.5 lecture)
# Uses manual stratified sampling (caret's createDataPartition not available)

# --- 1. Load cleaned data ---
data <- readRDS("data/processed/mushroom_clean.rds")

# --- 2. Stratified train/test split ---
set.seed(467)

stratified_sample <- function(y, p = 0.7) {
  indices <- seq_along(y)
  train_idx <- unlist(sapply(unique(y), function(cls) {
    cls_idx <- indices[y == cls]
    sample(cls_idx, size = round(length(cls_idx) * p))
  }))
  sort(train_idx)
}

train_index <- stratified_sample(data$class, p = 0.7)

train_data <- data[train_index, ]
test_data  <- data[-train_index, ]

# verify class proportions are preserved
cat("Training data: ", nrow(train_data), "rows\n")
cat("Test data:     ", nrow(test_data), "rows\n\n")
cat("Train class distribution:\n")
print(table(train_data$class))
cat("Proportion:\n")
print(prop.table(table(train_data$class)))
cat("\nTest class distribution:\n")
print(table(test_data$class))
cat("Proportion:\n")
print(prop.table(table(test_data$class)))

# --- 3. Save ---
saveRDS(train_data, "data/processed/train.rds")
saveRDS(test_data,  "data/processed/test.rds")
cat("\nSaved: data/processed/train.rds, data/processed/test.rds\n")
