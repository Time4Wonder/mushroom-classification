# 03_train_test_split.R
# Stratified 70/30 train-test split for both dataset variants (cf. Ch. 5.5)
# Uses manual stratified sampling (caret's createDataPartition not available)

# --- 1. Split helper ---
set.seed(467)

stratified_sample <- function(y, p = 0.7) {
  indices <- seq_along(y)
  train_idx <- unlist(sapply(unique(y), function(cls) {
    cls_idx <- indices[y == cls]
    sample(cls_idx, size = round(length(cls_idx) * p))
  }))
  sort(train_idx)
}

# --- 2. Full variant ---
cat("---Full variant (21 features) ---\n")
data_full <- readRDS("data/processed/mushroom_clean_full.rds")

train_index <- stratified_sample(data_full$class, p = 0.7)
train_full <- data_full[train_index, ]
test_full  <- data_full[-train_index, ]

cat("Training data: ", nrow(train_full), "rows\n")
cat("Test data:     ", nrow(test_full), "rows\n")
cat("Train class distribution:\n")
print(prop.table(table(train_full$class)))
cat("Test class distribution:\n")
print(prop.table(table(test_full$class)))

saveRDS(train_full, "data/processed/train_full.rds")
saveRDS(test_full,  "data/processed/test_full.rds")
cat("Saved: train_full.rds, test_full.rds\n\n")

# --- 3. Reduced variant (same index, same seed) ---
cat("---Reduced variant (19 features, without odor + spore_print_color) ---\n")
data_reduced <- readRDS("data/processed/mushroom_clean_reduced.rds")

# Same stratified split (class distribution is identical)
train_reduced <- data_reduced[train_index, ]
test_reduced  <- data_reduced[-train_index, ]

cat("Training data: ", nrow(train_reduced), "rows\n")
cat("Test data:     ", nrow(test_reduced), "rows\n")
cat("Train class distribution:\n")
print(prop.table(table(train_reduced$class)))
cat("Test class distribution:\n")
print(prop.table(table(test_reduced$class)))

saveRDS(train_reduced, "data/processed/train_reduced.rds")
saveRDS(test_reduced,  "data/processed/test_reduced.rds")
cat("Saved: train_reduced.rds, test_reduced.rds\n")
