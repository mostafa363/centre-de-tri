# ===============================================
# 🤖 ENTRAÎNEMENT DES MODÈLES DE CLASSIFICATION
# Projet : Digit Recognition - Centre de Tri Postal
# Langage : R
# ===============================================

# -----------------------------------------------
# 📦 INSTALLATION ET CHARGEMENT DES PACKAGES
# -----------------------------------------------

cat("=" , rep("=", 49), "\n", sep = "")
cat("📦 CHARGEMENT DES PACKAGES\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

packages_requis <- c(
  "caret",         # Machine Learning framework
  "rpart",         # Decision Tree
  "rpart.plot",    # Visualisation Decision Tree
  "randomForest",  # Random Forest
  "e1071",         # SVM
  "class",         # KNN
  "nnet",          # Neural Network
  "MLmetrics",     # Métriques
  "ggplot2",       # Visualisation
  "reshape2",      # Manipulation données
  "doParallel"     # Calcul parallèle
)

for (pkg in packages_requis) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("📥 Installation de", pkg, "...\n")
    install.packages(pkg, quiet = TRUE, repos = "https://cran.r-project.org")
    library(pkg, character.only = TRUE)
  } else {
    cat("✅", pkg, "\n")
  }
}

# -----------------------------------------------
# 📂 CHARGEMENT DES DONNÉES
# -----------------------------------------------

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("📂 CHARGEMENT DES DONNÉES\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

data_path <- "c:/Users/Me/Desktop/RH/centre-de-tri/data/"
models_path <- "c:/Users/Me/Desktop/RH/centre-de-tri/models/"
outputs_path <- "c:/Users/Me/Desktop/RH/centre-de-tri/outputs/figures/"

# Créer les dossiers si nécessaire
dir.create(models_path, recursive = TRUE, showWarnings = FALSE)
dir.create(outputs_path, recursive = TRUE, showWarnings = FALSE)

# Charger les données
cat("📥 Chargement du dataset train.csv...\n")
train_full <- read.csv(paste0(data_path, "train.csv"))
cat("   ✅ Dimensions:", nrow(train_full), "x", ncol(train_full), "\n")

# -----------------------------------------------
# 🔧 PRÉTRAITEMENT DES DONNÉES
# -----------------------------------------------

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("🔧 PRÉTRAITEMENT DES DONNÉES\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Séparer features et labels
X_full <- train_full[, -1]  # Pixels (colonnes 2 à 785)
y_full <- train_full[, 1]   # Labels (colonne 1)

# Convertir le label en facteur
y_full <- as.factor(y_full)

# Normalisation des pixels (0-255 -> 0-1)
cat("📊 Normalisation des pixels (0-1)...\n")
X_full <- X_full / 255

# Use the FULL dataset for better accuracy
cat("📊 Utilisation du DATASET COMPLET (42,000 images)\n")
cat("   ⏱️  Ceci prendra plus de temps mais donnera de meilleurs résultats\n\n")

# Split 80% train, 20% test
set.seed(42)
train_size <- floor(0.8 * nrow(X_full))
indices <- sample(1:nrow(X_full))
train_indices <- indices[1:train_size]
test_indices <- indices[(train_size + 1):length(indices)]

X_train <- X_full[train_indices, ]
y_train <- y_full[train_indices]
X_test <- X_full[test_indices, ]
y_test <- y_full[test_indices]

cat("\n📊 Dimensions finales:\n")
cat("   X_train:", nrow(X_train), "x", ncol(X_train), "\n")
cat("   X_test:", nrow(X_test), "x", ncol(X_test), "\n")

# Distribution des classes
cat("\n📊 Distribution des classes (train):\n")
print(table(y_train))

# -----------------------------------------------
# 📊 STOCKAGE DES RÉSULTATS
# -----------------------------------------------

resultats <- data.frame(
  Modele = character(),
  Accuracy = numeric(),
  Temps_Entrainement = numeric(),
  stringsAsFactors = FALSE
)

# ===============================================
# 🌳 MODÈLE 1 : DECISION TREE
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("🌳 MODÈLE 1 : DECISION TREE (rpart)\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Entraînement
cat("🔄 Entraînement en cours...\n")
start_time <- Sys.time()

model_dt <- rpart(
  y_train ~ .,
  data = data.frame(y_train = y_train, X_train),
  method = "class",
  control = rpart.control(
    maxdepth = 20,
    minsplit = 20,
    cp = 0.001
  )
)

end_time <- Sys.time()
temps_dt <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("   ⏱️  Temps:", round(temps_dt, 2), "secondes\n")

# Prédiction
cat("🔮 Prédiction sur le test set...\n")
pred_dt <- predict(model_dt, data.frame(X_test), type = "class")

# Évaluation
accuracy_dt <- sum(pred_dt == y_test) / length(y_test)
cat("   ✅ Accuracy:", round(accuracy_dt * 100, 2), "%\n")

# Matrice de confusion
cat("\n📊 Matrice de confusion:\n")
cm_dt <- confusionMatrix(pred_dt, y_test)
print(cm_dt$table)

# Sauvegarder le modèle
saveRDS(model_dt, paste0(models_path, "model_decision_tree.rds"))
cat("\n💾 Modèle sauvegardé: model_decision_tree.rds\n")

# Ajouter aux résultats
resultats <- rbind(resultats, data.frame(
  Modele = "Decision Tree",
  Accuracy = accuracy_dt,
  Temps_Entrainement = temps_dt
))

# ===============================================
# 🌲 MODÈLE 2 : RANDOM FOREST
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("🌲 MODÈLE 2 : RANDOM FOREST\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Entraînement
cat("🔄 Entraînement en cours (peut prendre quelques minutes)...\n")
start_time <- Sys.time()

model_rf <- randomForest(
  x = X_train,
  y = y_train,
  ntree = 100,      # Nombre d'arbres
  mtry = 28,        # sqrt(784) ≈ 28
  nodesize = 5,
  importance = TRUE
)

end_time <- Sys.time()
temps_rf <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("   ⏱️  Temps:", round(temps_rf, 2), "secondes\n")

# Prédiction
cat("🔮 Prédiction sur le test set...\n")
pred_rf <- predict(model_rf, X_test)

# Évaluation
accuracy_rf <- sum(pred_rf == y_test) / length(y_test)
cat("   ✅ Accuracy:", round(accuracy_rf * 100, 2), "%\n")

# Matrice de confusion
cat("\n📊 Matrice de confusion:\n")
cm_rf <- confusionMatrix(pred_rf, y_test)
print(cm_rf$table)

# Sauvegarder le modèle
saveRDS(model_rf, paste0(models_path, "model_random_forest.rds"))
cat("\n💾 Modèle sauvegardé: model_random_forest.rds\n")

# Ajouter aux résultats
resultats <- rbind(resultats, data.frame(
  Modele = "Random Forest",
  Accuracy = accuracy_rf,
  Temps_Entrainement = temps_rf
))

# ===============================================
# 🎯 MODÈLE 3 : SUPPORT VECTOR MACHINE (SVM)
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("🎯 MODÈLE 3 : SVM (Support Vector Machine)\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Entraînement
cat("🔄 Entraînement en cours (peut prendre plusieurs minutes)...\n")
start_time <- Sys.time()

model_svm <- svm(
  x = as.matrix(X_train),
  y = y_train,
  type = "C-classification",
  kernel = "radial",
  cost = 10,
  gamma = 0.01,
  scale = FALSE
)

end_time <- Sys.time()
temps_svm <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("   ⏱️  Temps:", round(temps_svm, 2), "secondes\n")

# Prédiction
cat("🔮 Prédiction sur le test set...\n")
pred_svm <- predict(model_svm, as.matrix(X_test))

# Évaluation
accuracy_svm <- sum(pred_svm == y_test) / length(y_test)
cat("   ✅ Accuracy:", round(accuracy_svm * 100, 2), "%\n")

# Matrice de confusion
cat("\n📊 Matrice de confusion:\n")
cm_svm <- confusionMatrix(pred_svm, y_test)
print(cm_svm$table)

# Sauvegarder le modèle
saveRDS(model_svm, paste0(models_path, "model_svm.rds"))
cat("\n💾 Modèle sauvegardé: model_svm.rds\n")

# Ajouter aux résultats
resultats <- rbind(resultats, data.frame(
  Modele = "SVM",
  Accuracy = accuracy_svm,
  Temps_Entrainement = temps_svm
))

# ===============================================
# 🔢 MODÈLE 4 : K-NEAREST NEIGHBORS (KNN)
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("🔢 MODÈLE 4 : KNN (K-Nearest Neighbors)\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Entraînement et prédiction (KNN n'a pas de phase d'entraînement séparée)
cat("🔄 Classification KNN en cours...\n")
start_time <- Sys.time()

pred_knn <- knn(
  train = X_train,
  test = X_test,
  cl = y_train,
  k = 5
)

end_time <- Sys.time()
temps_knn <- as.numeric(difftime(end_time, start_time, units = "secs"))
cat("   ⏱️  Temps:", round(temps_knn, 2), "secondes\n")

# Évaluation
accuracy_knn <- sum(pred_knn == y_test) / length(y_test)
cat("   ✅ Accuracy:", round(accuracy_knn * 100, 2), "%\n")

# Matrice de confusion
cat("\n📊 Matrice de confusion:\n")
cm_knn <- confusionMatrix(pred_knn, y_test)
print(cm_knn$table)

# Note: KNN ne se sauvegarde pas comme un modèle traditionnel
# On sauvegarde les données d'entraînement
knn_data <- list(X_train = X_train, y_train = y_train, k = 5)
saveRDS(knn_data, paste0(models_path, "model_knn.rds"))
cat("\n💾 Données KNN sauvegardées: model_knn.rds\n")

# Ajouter aux résultats
resultats <- rbind(resultats, data.frame(
  Modele = "KNN (k=5)",
  Accuracy = accuracy_knn,
  Temps_Entrainement = temps_knn
))

# ===============================================
# 📊 COMPARAISON DES MODÈLES
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("📊 COMPARAISON DES MODÈLES\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Trier par accuracy
resultats <- resultats[order(-resultats$Accuracy), ]
resultats$Accuracy_Pct <- paste0(round(resultats$Accuracy * 100, 2), "%")
resultats$Temps <- paste0(round(resultats$Temps_Entrainement, 1), "s")

print(resultats[, c("Modele", "Accuracy_Pct", "Temps")])

# Meilleur modèle
meilleur <- resultats[1, ]
cat("\n🏆 MEILLEUR MODÈLE:", meilleur$Modele, "\n")
cat("   Accuracy:", meilleur$Accuracy_Pct, "\n")

# ===============================================
# 📈 VISUALISATION DES RÉSULTATS
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("📈 GÉNÉRATION DES VISUALISATIONS\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Graphique de comparaison des accuracy
p_accuracy <- ggplot(resultats, aes(x = reorder(Modele, Accuracy), y = Accuracy * 100, fill = Modele)) +
  geom_bar(stat = "identity", width = 0.7) +
  geom_text(aes(label = Accuracy_Pct), hjust = -0.1, size = 4) +
  coord_flip() +
  theme_minimal() +
  labs(
    title = "Comparaison des Modèles - Accuracy",
    subtitle = paste("Dataset: MNIST (", SAMPLE_SIZE, "train /", TEST_SIZE, "test)"),
    x = "",
    y = "Accuracy (%)"
  ) +
  theme(legend.position = "none") +
  ylim(0, 100)

ggsave(paste0(outputs_path, "comparaison_modeles.png"), p_accuracy, 
       width = 10, height = 6, dpi = 150)
cat("✅ Figure sauvegardée: comparaison_modeles.png\n")

# Graphique des temps d'entraînement
p_temps <- ggplot(resultats, aes(x = reorder(Modele, -Temps_Entrainement), 
                                  y = Temps_Entrainement, fill = Modele)) +
  geom_bar(stat = "identity", width = 0.7) +
  geom_text(aes(label = Temps), vjust = -0.3, size = 4) +
  theme_minimal() +
  labs(
    title = "Temps d'Entraînement par Modèle",
    x = "",
    y = "Temps (secondes)"
  ) +
  theme(legend.position = "none")

ggsave(paste0(outputs_path, "temps_entrainement.png"), p_temps, 
       width = 10, height = 6, dpi = 150)
cat("✅ Figure sauvegardée: temps_entrainement.png\n")

# ===============================================
# 💾 SAUVEGARDER LE MEILLEUR MODÈLE
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("💾 SAUVEGARDE DU MEILLEUR MODÈLE\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Déterminer et sauvegarder le meilleur modèle
if (meilleur$Modele == "Random Forest") {
  best_model <- model_rf
} else if (meilleur$Modele == "SVM") {
  best_model <- model_svm
} else if (meilleur$Modele == "Decision Tree") {
  best_model <- model_dt
} else {
  best_model <- knn_data
}

saveRDS(best_model, paste0(models_path, "best_model.rds"))
cat("✅ Meilleur modèle sauvegardé: best_model.rds\n")
cat("   Type:", meilleur$Modele, "\n")
cat("   Accuracy:", meilleur$Accuracy_Pct, "\n")

# Sauvegarder les résultats
saveRDS(resultats, paste0(outputs_path, "resultats_modeles.rds"))
write.csv(resultats, paste0(outputs_path, "resultats_modeles.csv"), row.names = FALSE)
cat("✅ Résultats sauvegardés: resultats_modeles.csv\n")

# ===============================================
# 📊 RÉSUMÉ FINAL
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("✅ ENTRAÎNEMENT TERMINÉ !\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

cat("📂 Modèles sauvegardés dans:", models_path, "\n")
cat("   - model_decision_tree.rds\n")
cat("   - model_random_forest.rds\n")
cat("   - model_svm.rds\n")
cat("   - model_knn.rds\n")
cat("   - best_model.rds (", meilleur$Modele, ")\n\n")

cat("📊 Figures sauvegardées dans:", outputs_path, "\n")
cat("   - comparaison_modeles.png\n")
cat("   - temps_entrainement.png\n")
cat("   - resultats_modeles.csv\n\n")

cat("🏆 Récapitulatif:\n")
for (i in 1:nrow(resultats)) {
  cat(sprintf("   %d. %s: %s\n", i, resultats$Modele[i], resultats$Accuracy_Pct[i]))
}

cat("\n💡 Prochaines étapes:\n")
cat("   1. Optimiser les hyperparamètres (GridSearch)\n")
cat("   2. Augmenter SAMPLE_SIZE pour de meilleurs résultats\n")
cat("   3. Créer l'application Shiny\n")
