# ===============================================
# 📊 EXPLORATION DU JEU DE DONNÉES MNIST
# Projet : Digit Recognition - Centre de Tri Postal
# Langage : R
# ===============================================

# -----------------------------------------------
# 📦 INSTALLATION ET CHARGEMENT DES PACKAGES
# -----------------------------------------------

# Installer les packages si nécessaire
packages_requis <- c("ggplot2", "reshape2", "gridExtra", "dplyr", "tidyr")

for (pkg in packages_requis) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}

# -----------------------------------------------
# 📂 CHARGEMENT DES DONNÉES
# -----------------------------------------------

cat("=" , rep("=", 49), "\n", sep = "")
cat("📊 EXPLORATION DU DATASET MNIST\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Définir le chemin vers les données
data_path <- "c:/Users/Me/Desktop/RH/centre-de-tri/data/"

# Charger les données d'entraînement
cat("📥 Chargement des données d'entraînement...\n")
train_data <- read.csv(paste0(data_path, "train.csv"))
cat("   ✅ Dimensions train:", nrow(train_data), "lignes x", ncol(train_data), "colonnes\n")

# Charger les données de test
cat("📥 Chargement des données de test...\n")
test_data <- read.csv(paste0(data_path, "test.csv"))
cat("   ✅ Dimensions test:", nrow(test_data), "lignes x", ncol(test_data), "colonnes\n\n")

# -----------------------------------------------
# 🔍 EXPLORATION INITIALE
# -----------------------------------------------

cat("🔍 STRUCTURE DES DONNÉES\n")
cat("-" , rep("-", 49), "\n", sep = "")

# Afficher les premières colonnes
cat("Premières colonnes du train:\n")
print(names(train_data)[1:10])

# Distribution des labels
cat("\n📊 Distribution des labels (chiffres 0-9):\n")
print(table(train_data$label))

# Statistiques de base
cat("\n📈 Statistiques des valeurs de pixels:\n")
cat("   Min:", min(train_data[, -1]), "\n")
cat("   Max:", max(train_data[, -1]), "\n")
cat("   Moyenne:", round(mean(as.matrix(train_data[, -1])), 2), "\n")

# -----------------------------------------------
# 🖼️ FONCTIONS DE VISUALISATION
# -----------------------------------------------

#' Fonction pour convertir une ligne de pixels en matrice 28x28
#' @param pixel_row Vecteur de 784 pixels
#' @return Matrice 28x28
pixels_to_matrix <- function(pixel_row) {
  # Convertir en matrice 28x28
  mat <- matrix(as.numeric(pixel_row), nrow = 28, ncol = 28, byrow = TRUE)
  # Retourner la matrice (rotation pour affichage correct)
  return(mat)
}

#' Fonction pour afficher une image MNIST
#' @param pixel_row Vecteur de 784 pixels
#' @param label Label du chiffre (optionnel)
#' @param title Titre personnalisé (optionnel)
plot_digit <- function(pixel_row, label = NULL, title = NULL) {
  mat <- pixels_to_matrix(pixel_row)
  
  # Créer le titre
  if (is.null(title)) {
    title <- ifelse(is.null(label), "Image MNIST", paste("Chiffre:", label))
  }
  
  # Afficher avec image()
  image(1:28, 1:28, t(mat[28:1, ]), 
        col = gray.colors(256, start = 1, end = 0),
        xlab = "", ylab = "", main = title,
        axes = FALSE)
}

#' Fonction pour afficher une image avec ggplot2
#' @param pixel_row Vecteur de 784 pixels
#' @param label Label du chiffre
plot_digit_ggplot <- function(pixel_row, label = NULL) {
  mat <- pixels_to_matrix(pixel_row)
  
  # Convertir en data frame pour ggplot
  df <- reshape2::melt(mat)
  names(df) <- c("y", "x", "value")
  
  # Créer le titre
  title <- ifelse(is.null(label), "Image MNIST", paste("Chiffre:", label))
  
  # Plot
  p <- ggplot(df, aes(x = x, y = 29 - y, fill = value)) +
    geom_tile() +
    scale_fill_gradient(low = "white", high = "black") +
    theme_void() +
    theme(legend.position = "none",
          plot.title = element_text(hjust = 0.5, size = 14, face = "bold")) +
    ggtitle(title) +
    coord_fixed()
  
  return(p)
}

# ===============================================
# 📝 QUESTION 1a : Afficher une image quelconque
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("📝 QUESTION 1a : Afficher une image avec son label\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Sélectionner une image aléatoire
set.seed(42)  # Pour reproductibilité
index_aleatoire <- sample(1:nrow(train_data), 1)

# Extraire le label et les pixels
label_image <- train_data$label[index_aleatoire]
pixels_image <- as.numeric(train_data[index_aleatoire, -1])

cat("Image sélectionnée : index", index_aleatoire, "\n")
cat("Label (chiffre) :", label_image, "\n")

# Afficher l'image
par(mar = c(1, 1, 3, 1))
plot_digit(pixels_image, label_image, 
           title = paste("Question 1a - Chiffre:", label_image, "(index:", index_aleatoire, ")"))

# Sauvegarder la figure
output_path <- "c:/Users/Me/Desktop/RH/centre-de-tri/outputs/figures/"
dir.create(output_path, recursive = TRUE, showWarnings = FALSE)
png(paste0(output_path, "Q1a_image_aleatoire.png"), width = 400, height = 400)
par(mar = c(1, 1, 3, 1))
plot_digit(pixels_image, label_image, 
           title = paste("Question 1a - Chiffre:", label_image))
dev.off()
cat("✅ Figure sauvegardée: Q1a_image_aleatoire.png\n")

# ===============================================
# 📝 QUESTION 1b : Afficher les chiffres de 0 à 9
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("📝 QUESTION 1b : Afficher les chiffres de 0 à 9\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Trouver le premier exemple de chaque chiffre
png(paste0(output_path, "Q1b_chiffres_0_a_9.png"), width = 1000, height = 400)
par(mfrow = c(2, 5), mar = c(1, 1, 3, 1))

for (digit in 0:9) {
  # Trouver le premier index pour ce chiffre
  idx <- which(train_data$label == digit)[1]
  pixels <- as.numeric(train_data[idx, -1])
  
  plot_digit(pixels, digit, title = paste("Chiffre", digit))
}

dev.off()
cat("✅ Figure sauvegardée: Q1b_chiffres_0_a_9.png\n")

# Afficher aussi à l'écran
par(mfrow = c(2, 5), mar = c(1, 1, 3, 1))
for (digit in 0:9) {
  idx <- which(train_data$label == digit)[1]
  pixels <- as.numeric(train_data[idx, -1])
  plot_digit(pixels, digit, title = paste("Chiffre", digit))
}

# ===============================================
# 📝 QUESTION 1c : Les 9 premières images du chiffre 7
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("📝 QUESTION 1c : Les 9 premières images du chiffre 7\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Trouver les 9 premiers indices du chiffre 7
indices_sept <- which(train_data$label == 7)[1:9]
cat("Indices des 9 premières images du chiffre 7:", indices_sept, "\n")

# Sauvegarder la figure
png(paste0(output_path, "Q1c_neuf_premiers_7.png"), width = 600, height = 600)
par(mfrow = c(3, 3), mar = c(1, 1, 3, 1))

for (i in 1:9) {
  idx <- indices_sept[i]
  pixels <- as.numeric(train_data[idx, -1])
  plot_digit(pixels, 7, title = paste("7 -", i, "(idx:", idx, ")"))
}

dev.off()
cat("✅ Figure sauvegardée: Q1c_neuf_premiers_7.png\n")

# Afficher à l'écran
par(mfrow = c(3, 3), mar = c(1, 1, 3, 1))
for (i in 1:9) {
  idx <- indices_sept[i]
  pixels <- as.numeric(train_data[idx, -1])
  plot_digit(pixels, 7, title = paste("7 -", i))
}

# ===============================================
# 📝 QUESTION 1d : Représentant moyen de chaque chiffre
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("📝 QUESTION 1d : Représentant moyen de chaque chiffre\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Calculer l'image moyenne pour chaque chiffre
cat("Calcul des images moyennes...\n")

# Sauvegarder la figure
png(paste0(output_path, "Q1d_moyennes_0_a_9.png"), width = 1000, height = 400)
par(mfrow = c(2, 5), mar = c(1, 1, 3, 1))

for (digit in 0:9) {
  # Sélectionner toutes les images de ce chiffre
  images_digit <- train_data[train_data$label == digit, -1]
  
  # Calculer la moyenne de chaque pixel
  moyenne_pixels <- colMeans(images_digit)
  
  # Afficher l'image moyenne
  plot_digit(moyenne_pixels, digit, 
             title = paste("Moyenne", digit, "(n=", nrow(images_digit), ")"))
  
  cat("   Chiffre", digit, ": calculé sur", nrow(images_digit), "images\n")
}

dev.off()
cat("\n✅ Figure sauvegardée: Q1d_moyennes_0_a_9.png\n")

# Afficher à l'écran
par(mfrow = c(2, 5), mar = c(1, 1, 3, 1))
for (digit in 0:9) {
  images_digit <- train_data[train_data$label == digit, -1]
  moyenne_pixels <- colMeans(images_digit)
  plot_digit(moyenne_pixels, digit, 
             title = paste("Moyenne", digit))
}

# ===============================================
# 📊 RÉSUMÉ FINAL
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("📊 RÉSUMÉ DE L'EXPLORATION\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

cat("📁 Dataset MNIST:\n")
cat("   - Images d'entraînement:", nrow(train_data), "\n")
cat("   - Images de test:", nrow(test_data), "\n")
cat("   - Taille image: 28x28 =", 28*28, "pixels\n")
cat("   - Classes: 0 à 9 (10 chiffres)\n\n")

cat("📊 Distribution des classes (train):\n")
for (digit in 0:9) {
  count <- sum(train_data$label == digit)
  pct <- round(100 * count / nrow(train_data), 1)
  bar <- paste(rep("█", round(pct/2)), collapse = "")
  cat(sprintf("   %d: %5d (%4.1f%%) %s\n", digit, count, pct, bar))
}

cat("\n📂 Figures sauvegardées dans:\n")
cat("   ", output_path, "\n")
cat("   - Q1a_image_aleatoire.png\n")
cat("   - Q1b_chiffres_0_a_9.png\n")
cat("   - Q1c_neuf_premiers_7.png\n")
cat("   - Q1d_moyennes_0_a_9.png\n")

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("✅ EXPLORATION TERMINÉE !\n")
cat("=" , rep("=", 49), "\n")
