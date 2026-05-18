# Mushroom Datensatz einlesen
# Spaltennamen definieren (UCI Mushroom Dataset)
col_names <- c(
  "class",
  "cap_shape", "cap_surface", "cap_color",
  "bruises", "odor",
  "gill_attachment", "gill_spacing", "gill_size", "gill_color",
  "stalk_shape", "stalk_root",
  "stalk_surface_above_ring", "stalk_surface_below_ring",
  "stalk_color_above_ring", "stalk_color_below_ring",
  "veil_type", "veil_color",
  "ring_number", "ring_type",
  "spore_print_color",
  "population", "habitat"
)

# Datensatz einlesen
mushroom <- read.csv(
  # Lorenz Pfad:
  "/home/t4w/development/ml-project/mushroom/agaricus-lepiota.data",

  header = FALSE,
  col.names = col_names,
  stringsAsFactors = TRUE
)

# Überblick über den Datensatz
str(mushroom)
summary(mushroom)


