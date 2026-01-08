# ===============================================
# 📊 ÉVALUATION DES MODÈLES
# Questions 7 & 8 : Bonnes et mauvaises prédictions
# Projet : Digit Recognition - Centre de Tri Postal
# ===============================================

# -----------------------------------------------
# 📦 CHARGEMENT DES PACKAGES
# -----------------------------------------------

library(ggplot2)
library(reshape2)
library(caret)
library(randomForest)
library(e1071)
library(gridExtra)

cat("=" , rep("=", 49), "\n", sep = "")
cat("📊 ÉVALUATION DÉTAILLÉE DES MODÈLES\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# -----------------------------------------------
# 📂 CHARGEMENT DES DONNÉES ET MODÈLE
# -----------------------------------------------

data_path <- "c:/Users/SURFACEE/Desktop/CENTRE  de tri/data/"
models_path <- "c:/Users/SURFACEE/Desktop/CENTRE  de tri/models/"
outputs_path <- "c:/Users/SURFACEE/Desktop/CENTRE  de tri/outputs/figures/"

# Charger les données
cat("📥 Chargement des données...\n")
train_data <- read.csv(paste0(data_path, "train.csv"))

# Prétraitement
X <- train_data[, -1] / 255
y <- as.factor(train_data[, 1])

# Split train/test
set.seed(42)
n <- nrow(X)
test_size <- 2000
test_indices <- sample(1:n, test_size)
train_indices <- setdiff(1:n, test_indices)

X_train <- X[train_indices, ]
y_train <- y[train_indices]
X_test <- X[test_indices, ]
y_test <- y[test_indices]

cat("✅ Données chargées\n")
cat("   Train:", length(train_indices), "images\n")
cat("   Test:", length(test_indices), "images\n\n")

# -----------------------------------------------
# 📥 CHARGER LE MEILLEUR MODÈLE
# -----------------------------------------------

cat("📥 Chargement du meilleur modèle...\n")

# Essayer de charger le modèle optimisé ou le modèle de base
if (file.exists(paste0(models_path, "best_model_optimized.rds"))) {
  best_model <- readRDS(paste0(models_path, "best_model_optimized.rds"))
  cat("✅ Modèle optimisé chargé\n")
} else if (file.exists(paste0(models_path, "best_model.rds"))) {
  best_model <- readRDS(paste0(models_path, "best_model.rds"))
  cat("✅ Modèle de base chargé\n")
} else if (file.exists(paste0(models_path, "model_random_forest.rds"))) {
  best_model <- readRDS(paste0(models_path, "model_random_forest.rds"))
  cat("✅ Random Forest chargé\n")
} else {
  cat("⚠️  Aucun modèle trouvé. Entraînement d'un nouveau modèle...\n")
  # Entraîner un modèle rapide
  sample_idx <- sample(1:length(train_indices), 5000)
  best_model <- randomForest(
    x = X_train[sample_idx, ],
    y = y_train[sample_idx],
    ntree = 50
  )
}

# -----------------------------------------------
# 🔮 PRÉDICTIONS
# -----------------------------------------------

cat("\n🔮 Génération des prédictions...\n")

# Prédire selon le type de modèle
if ("randomForest" %in% class(best_model)) {
  predictions <- predict(best_model, X_test)
} else if ("svm" %in% class(best_model)) {
  predictions <- predict(best_model, as.matrix(X_test))
} else if ("rpart" %in% class(best_model)) {
  predictions <- predict(best_model, data.frame(X_test), type = "class")
} else if (is.list(best_model) && "k" %in% names(best_model)) {
  # KNN
  predictions <- class::knn(
    train = best_model$X_train,
    test = X_test,
    cl = best_model$y_train,
    k = best_model$k
  )
} else {
  predictions <- predict(best_model, X_test)
}

cat("✅ Prédictions générées\n")

# -----------------------------------------------
# 📊 MATRICE DE CONFUSION
# -----------------------------------------------

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("📊 MATRICE DE CONFUSION\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

cm <- confusionMatrix(predictions, y_test)
print(cm)

# Visualisation de la matrice de confusion
cm_df <- as.data.frame(cm$table)
names(cm_df) <- c("Prediction", "Reference", "Freq")

p_cm <- ggplot(cm_df, aes(x = Reference, y = Prediction, fill = Freq)) +
  geom_tile() +
  geom_text(aes(label = Freq), color = "white", size = 4) +
  scale_fill_gradient(low = "lightblue", high = "darkblue") +
  theme_minimal() +
  labs(
    title = "Matrice de Confusion",
    subtitle = paste("Accuracy:", round(cm$overall["Accuracy"] * 100, 2), "%"),
    x = "Valeur Réelle",
    y = "Prédiction"
  ) +
  theme(axis.text = element_text(size = 12))

ggsave(paste0(outputs_path, "matrice_confusion.png"), p_cm, 
       width = 10, height = 8, dpi = 150)
cat("✅ Matrice de confusion sauvegardée\n")

# -----------------------------------------------
# 🖼️ FONCTION D'AFFICHAGE
# -----------------------------------------------

pixels_to_matrix <- function(pixel_row) {
  mat <- matrix(as.numeric(pixel_row), nrow = 28, ncol = 28, byrow = TRUE)
  return(mat)
}

plot_digit <- function(pixel_row, label = NULL, pred = NULL, title = NULL) {
  mat <- pixels_to_matrix(pixel_row)
  
  if (is.null(title)) {
    if (!is.null(pred)) {
      title <- paste("Réel:", label, "| Prédit:", pred)
    } else {
      title <- paste("Label:", label)
    }
  }
  
  image(1:28, 1:28, t(mat[28:1, ]), 
        col = gray.colors(256, start = 1, end = 0),
        xlab = "", ylab = "", main = title,
        axes = FALSE)
}

# ===============================================
# 📝 QUESTION 7 : Bonnes prédictions
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("📝 QUESTION 7 : BONNES PRÉDICTIONS\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Trouver les bonnes prédictions
correct_idx <- which(predictions == y_test)
cat("✅ Nombre de bonnes prédictions:", length(correct_idx), "/", length(y_test), "\n")
cat("   Accuracy:", round(length(correct_idx) / length(y_test) * 100, 2), "%\n\n")

# Afficher 16 bonnes prédictions
cat("📊 Affichage de 16 bonnes prédictions:\n")

png(paste0(outputs_path, "Q7_bonnes_predictions.png"), width = 800, height = 800)
par(mfrow = c(4, 4), mar = c(1, 1, 3, 1))

set.seed(123)
sample_correct <- sample(correct_idx, min(16, length(correct_idx)))

for (i in sample_correct) {
  pixels <- as.numeric(X_test[i, ] * 255)
  plot_digit(pixels, 
             label = as.character(y_test[i]), 
             pred = as.character(predictions[i]),
             title = paste("✓", y_test[i]))
}

dev.off()
cat("✅ Figure sauvegardée: Q7_bonnes_predictions.png\n")

# Afficher à l'écran
par(mfrow = c(4, 4), mar = c(1, 1, 3, 1))
for (i in sample_correct) {
  pixels <- as.numeric(X_test[i, ] * 255)
  plot_digit(pixels, 
             label = as.character(y_test[i]), 
             pred = as.character(predictions[i]),
             title = paste("✓ Prédit:", predictions[i]))
}

# ===============================================
# 📝 QUESTION 8 : Mauvaises prédictions
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("📝 QUESTION 8 : MAUVAISES PRÉDICTIONS\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Trouver les mauvaises prédictions
wrong_idx <- which(predictions != y_test)
cat("❌ Nombre de mauvaises prédictions:", length(wrong_idx), "/", length(y_test), "\n")
cat("   Taux d'erreur:", round(length(wrong_idx) / length(y_test) * 100, 2), "%\n\n")

# Analyse des erreurs par chiffre
cat("📊 Analyse des erreurs par chiffre:\n\n")

erreurs_par_chiffre <- data.frame(
  Chiffre = 0:9,
  Total = sapply(0:9, function(d) sum(y_test == d)),
  Erreurs = sapply(0:9, function(d) sum(y_test == d & predictions != y_test)),
  stringsAsFactors = FALSE
)
erreurs_par_chiffre$Taux_Erreur <- round(erreurs_par_chiffre$Erreurs / erreurs_par_chiffre$Total * 100, 2)
erreurs_par_chiffre <- erreurs_par_chiffre[order(-erreurs_par_chiffre$Taux_Erreur), ]

print(erreurs_par_chiffre)

# Chiffre le plus souvent mal classé
pire_chiffre <- erreurs_par_chiffre$Chiffre[1]
cat("\n🔴 Le chiffre le plus souvent mal classé:", pire_chiffre, "\n")
cat("   Taux d'erreur:", erreurs_par_chiffre$Taux_Erreur[1], "%\n")

# Analyse des confusions
cat("\n📊 Confusions les plus fréquentes:\n")
confusions <- data.frame(
  Reel = character(),
  Predit = character(),
  Count = numeric(),
  stringsAsFactors = FALSE
)

for (i in 0:9) {
  for (j in 0:9) {
    if (i != j) {
      count <- sum(y_test == i & predictions == j)
      if (count > 0) {
        confusions <- rbind(confusions, data.frame(
          Reel = as.character(i),
          Predit = as.character(j),
          Count = count
        ))
      }
    }
  }
}

confusions <- confusions[order(-confusions$Count), ]
cat("\nTop 10 des confusions:\n")
print(head(confusions, 10))

# Visualisation des erreurs
p_erreurs <- ggplot(erreurs_par_chiffre, aes(x = reorder(as.factor(Chiffre), -Taux_Erreur), 
                                              y = Taux_Erreur, fill = Taux_Erreur)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = paste0(Taux_Erreur, "%")), vjust = -0.3, size = 4) +
  scale_fill_gradient(low = "lightgreen", high = "red") +
  theme_minimal() +
  labs(
    title = "Taux d'Erreur par Chiffre",
    subtitle = "Quel chiffre est le plus difficile à reconnaître ?",
    x = "Chiffre",
    y = "Taux d'erreur (%)"
  ) +
  theme(legend.position = "none")

ggsave(paste0(outputs_path, "Q8_erreurs_par_chiffre.png"), p_erreurs, 
       width = 10, height = 6, dpi = 150)
cat("\n✅ Figure sauvegardée: Q8_erreurs_par_chiffre.png\n")

# Afficher 16 mauvaises prédictions
png(paste0(outputs_path, "Q8_mauvaises_predictions.png"), width = 800, height = 800)
par(mfrow = c(4, 4), mar = c(1, 1, 3, 1))

if (length(wrong_idx) >= 16) {
  sample_wrong <- sample(wrong_idx, 16)
} else {
  sample_wrong <- wrong_idx
}

for (i in sample_wrong) {
  pixels <- as.numeric(X_test[i, ] * 255)
  plot_digit(pixels, 
             label = as.character(y_test[i]), 
             pred = as.character(predictions[i]),
             title = paste("✗ Réel:", y_test[i], "→ Prédit:", predictions[i]))
}

dev.off()
cat("✅ Figure sauvegardée: Q8_mauvaises_predictions.png\n")

# Afficher à l'écran
par(mfrow = c(4, 4), mar = c(1, 1, 3, 1))
for (i in sample_wrong[1:min(16, length(sample_wrong))]) {
  pixels <- as.numeric(X_test[i, ] * 255)
  plot_digit(pixels, 
             label = as.character(y_test[i]), 
             pred = as.character(predictions[i]),
             title = paste("✗", y_test[i], "→", predictions[i]))
}

# -----------------------------------------------
# 💡 ANALYSE : POURQUOI CES ERREURS ?
# -----------------------------------------------

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("💡 ANALYSE DES ERREURS\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

cat("🔍 Raisons possibles des erreurs de classification :\n\n")

cat("1. SIMILARITÉ VISUELLE :\n")
cat("   - 4 et 9 : forme similaire (boucle fermée/ouverte)\n")
cat("   - 3 et 8 : courbes similaires\n")
cat("   - 1 et 7 : traits verticaux\n")
cat("   - 5 et 6 : boucles similaires\n\n")

cat("2. QUALITÉ DE L'ÉCRITURE :\n")
cat("   - Écriture manuscrite variable\n")
cat("   - Inclinaison différente\n")
cat("   - Taille variable du chiffre\n\n")

cat("3. BRUIT DANS LES DONNÉES :\n")
cat("   - Pixels parasites\n")
cat("   - Mauvaise numérisation\n\n")

# Sauvegarder l'analyse
analyse <- list(
  accuracy = cm$overall["Accuracy"],
  confusion_matrix = cm$table,
  erreurs_par_chiffre = erreurs_par_chiffre,
  confusions_frequentes = head(confusions, 10),
  pire_chiffre = pire_chiffre
)
saveRDS(analyse, paste0(outputs_path, "analyse_erreurs.rds"))

# ===============================================
# 📊 RÉSUMÉ FINAL
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("✅ ÉVALUATION TERMINÉE !\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

cat("📊 Résumé :\n")
cat("   - Accuracy globale:", round(cm$overall["Accuracy"] * 100, 2), "%\n")
cat("   - Bonnes prédictions:", length(correct_idx), "\n")
cat("   - Mauvaises prédictions:", length(wrong_idx), "\n")
cat("   - Chiffre le plus difficile:", pire_chiffre, "\n\n")

cat("📂 Figures sauvegardées :\n")
cat("   - matrice_confusion.png\n")
cat("   - Q7_bonnes_predictions.png\n")
cat("   - Q8_mauvaises_predictions.png\n")
cat("   - Q8_erreurs_par_chiffre.png\n")
