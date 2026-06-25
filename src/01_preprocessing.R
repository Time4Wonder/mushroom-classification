# 01_preprocessing.R
# Load raw mushroom data, clean, map factor levels, impute missing values

# --- 1. Read raw data ---
# Annahme: Skript wird aus dem Projektroot ausgeführt
# (via Rscript src/01_preprocessing.R oder via 00_Main.R)
raw <- read.csv("mushroom/agaricus-lepiota.data",
                header = FALSE,
                sep = ",",
                stringsAsFactors = FALSE)

# --- 2. Assign column names ---
colnames(raw) <- c(
  "class", "cap_shape", "cap_surface", "cap_color", "bruises", "odor",
  "gill_attachment", "gill_spacing", "gill_size", "gill_color",
  "stalk_shape", "stalk_root", "stalk_surface_above_ring",
  "stalk_surface_below_ring", "stalk_color_above_ring",
  "stalk_color_below_ring", "veil_type", "veil_color",
  "ring_number", "ring_type", "spore_print_color", "population", "habitat"
)

data <- raw

# --- 3. Handle missing values in stalk_root ---
data$stalk_root[data$stalk_root == "?"] <- NA

mode_stalk_root <- names(which.max(table(data$stalk_root)))
data$stalk_root[is.na(data$stalk_root)] <- mode_stalk_root

# --- 4. Factor mappings ---
data$class <- factor(data$class,
                     levels = c("e", "p"),
                     labels = c("edible", "poisonous"))

data$cap_shape <- factor(data$cap_shape,
                         levels = c("b", "c", "x", "f", "k", "s"),
                         labels = c("bell", "conical", "convex", "flat", "knobbed", "sunken"))

data$cap_surface <- factor(data$cap_surface,
                           levels = c("f", "g", "y", "s"),
                           labels = c("fibrous", "grooves", "scaly", "smooth"))

data$cap_color <- factor(data$cap_color,
                         levels = c("n", "b", "c", "g", "r", "p", "u", "e", "w", "y"),
                         labels = c("brown", "buff", "cinnamon", "gray", "green", "pink", "purple", "red", "white", "yellow"))

data$bruises <- factor(data$bruises,
                       levels = c("t", "f"),
                       labels = c("bruises", "no"))

data$odor <- factor(data$odor,
                    levels = c("a", "l", "c", "y", "f", "m", "n", "p", "s"),
                    labels = c("almond", "anise", "creosote", "fishy", "foul", "musty", "none", "pungent", "spicy"))

data$gill_attachment <- factor(data$gill_attachment,
                               levels = c("a", "d", "f", "n"),
                               labels = c("attached", "descending", "free", "notched"))

data$gill_spacing <- factor(data$gill_spacing,
                            levels = c("c", "w", "d"),
                            labels = c("close", "crowded", "distant"))

data$gill_size <- factor(data$gill_size,
                         levels = c("b", "n"),
                         labels = c("broad", "narrow"))

data$gill_color <- factor(data$gill_color,
                          levels = c("k", "n", "b", "h", "g", "r", "o", "p", "u", "e", "w", "y"),
                          labels = c("black", "brown", "buff", "chocolate", "gray", "green", "orange", "pink", "purple", "red", "white", "yellow"))

data$stalk_shape <- factor(data$stalk_shape,
                           levels = c("e", "t"),
                           labels = c("enlarging", "tapering"))

data$stalk_root <- factor(data$stalk_root,
                          levels = c("b", "c", "u", "e", "z", "r"),
                          labels = c("bulbous", "club", "cup", "equal", "rhizomorphs", "rooted"))

data$stalk_surface_above_ring <- factor(data$stalk_surface_above_ring,
                                        levels = c("f", "y", "k", "s"),
                                        labels = c("fibrous", "scaly", "silky", "smooth"))

data$stalk_surface_below_ring <- factor(data$stalk_surface_below_ring,
                                        levels = c("f", "y", "k", "s"),
                                        labels = c("fibrous", "scaly", "silky", "smooth"))

data$stalk_color_above_ring <- factor(data$stalk_color_above_ring,
                                      levels = c("n", "b", "c", "g", "o", "p", "e", "w", "y"),
                                      labels = c("brown", "buff", "cinnamon", "gray", "orange", "pink", "red", "white", "yellow"))

data$stalk_color_below_ring <- factor(data$stalk_color_below_ring,
                                      levels = c("n", "b", "c", "g", "o", "p", "e", "w", "y"),
                                      labels = c("brown", "buff", "cinnamon", "gray", "orange", "pink", "red", "white", "yellow"))

data$veil_type <- factor(data$veil_type,
                         levels = c("p", "u"),
                         labels = c("partial", "universal"))

data$veil_color <- factor(data$veil_color,
                          levels = c("n", "o", "w", "y"),
                          labels = c("brown", "orange", "white", "yellow"))

data$ring_number <- factor(data$ring_number,
                           levels = c("n", "o", "t"),
                           labels = c("none", "one", "two"))

data$ring_type <- factor(data$ring_type,
                         levels = c("c", "e", "f", "l", "n", "p", "s", "z"),
                         labels = c("cobwebby", "evanescent", "flaring", "large", "none", "pendant", "sheathing", "zone"))

data$spore_print_color <- factor(data$spore_print_color,
                                 levels = c("k", "n", "b", "h", "r", "o", "u", "w", "y"),
                                 labels = c("black", "brown", "buff", "chocolate", "green", "orange", "purple", "white", "yellow"))

data$population <- factor(data$population,
                          levels = c("a", "c", "n", "s", "v", "y"),
                          labels = c("abundant", "clustered", "numerous", "scattered", "several", "solitary"))

data$habitat <- factor(data$habitat,
                       levels = c("g", "l", "m", "p", "u", "w", "d"),
                       labels = c("grasses", "leaves", "meadows", "paths", "urban", "waste", "woods"))

# --- 5. Remove irrelevant features ---
cat("\n--- Feature removal check ---\n")
cat("veil_type levels:", paste(levels(data$veil_type), collapse = ", "), "\n")
cat("veil_type distribution:\n")
print(table(data$veil_type))

# veil_type is constant (only "partial") -- no predictive value (cf. Ch. 3.1 lecture)
data$veil_type <- NULL
cat("Removed constant feature: veil_type\n")

# --- 6. Save full variant (21 features, veil_type removed) ---
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
saveRDS(data, "data/processed/mushroom_clean_full.rds")
write.csv(data, "data/processed/mushroom_clean_full.csv", row.names = FALSE)
cat("Saved full variant (21 features): data/processed/mushroom_clean_full.rds + .csv\n")

# --- 7. Save reduced variant (without odor + spore_print_color) ---
# Reasoning: Geruch ist subjektiv/inkonsistent, Sporenabdruck im Feld nicht praktikabel
data_reduced <- data
data_reduced$odor <- NULL
data_reduced$spore_print_color <- NULL
saveRDS(data_reduced, "data/processed/mushroom_clean_reduced.rds")
write.csv(data_reduced, "data/processed/mushroom_clean_reduced.csv", row.names = FALSE)
cat("Saved reduced variant (19 features): data/processed/mushroom_clean_reduced.rds + .csv\n")

cat("\n--- Summary ---\n")
cat("Full variant dimensions:   ", nrow(data), "x", ncol(data), "\n")
cat("Reduced variant dimensions:", nrow(data_reduced), "x", ncol(data_reduced), "\n")
cat("Features removed in reduced:", setdiff(names(data), names(data_reduced)), "\n")
cat("\nClass distribution:\n")
print(table(data$class))
