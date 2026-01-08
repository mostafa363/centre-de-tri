# ===============================================
# 🔧 OPTIMISATION DES HYPERPARAMÈTRES (GridSearch)
# Projet : Digit Recognition - Centre de Tri Postal
# Langage : R
# ===============================================

# -----------------------------------------------
# 📦 CHARGEMENT DES PACKAGES
# -----------------------------------------------

cat("=" , rep("=", 49), "\n", sep = "")
cat("🔧 OPTIMISATION DES HYPERPARAMÈTRES\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

library(caret)
library(rpart)
library(randomForest)
library(e1071)
library(ggplot2)
library(doParallel)

# Activer le calcul parallèle
n_cores <- detectCores() - 1
cl <- makeCluster(n_cores)
registerDoParallel(cl)
cat("🖥️  Calcul parallèle activé:", n_cores, "coeurs\n\n")

# -----------------------------------------------
# 📂 CHARGEMENT DES DONNÉES
# -----------------------------------------------

data_path <- "c:/Users/SURFACEE/Desktop/CENTRE  de tri/data/"
models_path <- "c:/Users/SURFACEE/Desktop/CENTRE  de tri/models/"
outputs_path <- "c:/Users/SURFACEE/Desktop/CENTRE  de tri/outputs/figures/"

cat("📥 Chargement des données...\n")
train_full <- read.csv(paste0(data_path, "train.csv"))

# Prétraitement
X_full <- train_full[, -1] / 255
y_full <- as.factor(train_full[, 1])

# Échantillon pour l'optimisation (plus petit pour la vitesse)
SAMPLE_SIZE <- 3000

set.seed(42)
indices <- sample(1:nrow(X_full), SAMPLE_SIZE)
X_sample <- X_full[indices, ]
y_sample <- y_full[indices]

# Créer le dataframe pour caret
train_df <- data.frame(label = y_sample, X_sample)

cat("✅ Données préparées:", SAMPLE_SIZE, "images\n\n")

# -----------------------------------------------
# ⚙️ CONFIGURATION DE LA VALIDATION CROISÉE
# -----------------------------------------------

# 5-fold cross-validation
ctrl <- trainControl(
  method = "cv",
  number = 5,
  verboseIter = TRUE,
  allowParallel = TRUE
)

# ===============================================
# 🌳 OPTIMISATION DECISION TREE
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("🌳 OPTIMISATION DECISION TREE\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Grille des hyperparamètres
grid_dt <- expand.grid(
  cp = c(0.001, 0.005, 0.01, 0.02)  # Complexity parameter
)

cat("📊 Grille de recherche:\n")
print(grid_dt)
cat("\n")

# GridSearch
cat("🔄 GridSearch en cours...\n")
start_time <- Sys.time()

tune_dt <- train(
  label ~ .,
  data = train_df,
  method = "rpart",
  trControl = ctrl,
  tuneGrid = grid_dt
)

end_time <- Sys.time()
cat("⏱️  Temps:", round(difftime(end_time, start_time, units = "mins"), 2), "minutes\n\n")

cat("📊 Résultats:\n")
print(tune_dt$results)
cat("\n🏆 Meilleurs paramètres:\n")
print(tune_dt$bestTune)
cat("\n✅ Meilleure Accuracy:", round(max(tune_dt$results$Accuracy) * 100, 2), "%\n")

# Sauvegarder
saveRDS(tune_dt, paste0(models_path, "tuned_decision_tree.rds"))

# ===============================================
# 🌲 OPTIMISATION RANDOM FOREST
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("🌲 OPTIMISATION RANDOM FOREST\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Grille des hyperparamètres
grid_rf <- expand.grid(
  mtry = c(14, 28, 42)  # Nombre de features par split
)

cat("📊 Grille de recherche:\n")
print(grid_rf)
cat("\n")

# GridSearch
cat("🔄 GridSearch en cours (peut prendre plusieurs minutes)...\n")
start_time <- Sys.time()

tune_rf <- train(
  label ~ .,
  data = train_df,
  method = "rf",
  trControl = ctrl,
  tuneGrid = grid_rf,
  ntree = 50  # Réduit pour la vitesse
)

end_time <- Sys.time()
cat("⏱️  Temps:", round(difftime(end_time, start_time, units = "mins"), 2), "minutes\n\n")

cat("📊 Résultats:\n")
print(tune_rf$results)
cat("\n🏆 Meilleurs paramètres:\n")
print(tune_rf$bestTune)
cat("\n✅ Meilleure Accuracy:", round(max(tune_rf$results$Accuracy) * 100, 2), "%\n")

# Sauvegarder
saveRDS(tune_rf, paste0(models_path, "tuned_random_forest.rds"))

# ===============================================
# 🎯 OPTIMISATION SVM
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("🎯 OPTIMISATION SVM\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Grille des hyperparamètres (réduite pour la vitesse)
grid_svm <- expand.grid(
  C = c(1, 10),           # Paramètre de régularisation
  sigma = c(0.01, 0.02)   # Paramètre du kernel RBF
)

cat("📊 Grille de recherche:\n")
print(grid_svm)
cat("\n")

# GridSearch
cat("🔄 GridSearch en cours (peut prendre plusieurs minutes)...\n")
start_time <- Sys.time()

tune_svm <- train(
  label ~ .,
  data = train_df,
  method = "svmRadial",
  trControl = ctrl,
  tuneGrid = grid_svm
)

end_time <- Sys.time()
cat("⏱️  Temps:", round(difftime(end_time, start_time, units = "mins"), 2), "minutes\n\n")

cat("📊 Résultats:\n")
print(tune_svm$results)
cat("\n🏆 Meilleurs paramètres:\n")
print(tune_svm$bestTune)
cat("\n✅ Meilleure Accuracy:", round(max(tune_svm$results$Accuracy) * 100, 2), "%\n")

# Sauvegarder
saveRDS(tune_svm, paste0(models_path, "tuned_svm.rds"))

# ===============================================
# 🔢 OPTIMISATION KNN
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("🔢 OPTIMISATION KNN\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Grille des hyperparamètres
grid_knn <- expand.grid(
  k = c(1, 3, 5, 7, 9)
)

cat("📊 Grille de recherche:\n")
print(grid_knn)
cat("\n")

# GridSearch
cat("🔄 GridSearch en cours...\n")
start_time <- Sys.time()

tune_knn <- train(
  label ~ .,
  data = train_df,
  method = "knn",
  trControl = ctrl,
  tuneGrid = grid_knn
)

end_time <- Sys.time()
cat("⏱️  Temps:", round(difftime(end_time, start_time, units = "mins"), 2), "minutes\n\n")

cat("📊 Résultats:\n")
print(tune_knn$results)
cat("\n🏆 Meilleurs paramètres:\n")
print(tune_knn$bestTune)
cat("\n✅ Meilleure Accuracy:", round(max(tune_knn$results$Accuracy) * 100, 2), "%\n")

# Sauvegarder
saveRDS(tune_knn, paste0(models_path, "tuned_knn.rds"))

# ===============================================
# 📊 COMPARAISON FINALE
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("📊 COMPARAISON FINALE DES MODÈLES OPTIMISÉS\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Compiler les résultats
resultats_opt <- data.frame(
  Modele = c("Decision Tree", "Random Forest", "SVM", "KNN"),
  Accuracy = c(
    max(tune_dt$results$Accuracy),
    max(tune_rf$results$Accuracy),
    max(tune_svm$results$Accuracy),
    max(tune_knn$results$Accuracy)
  ),
  Meilleur_Param = c(
    paste("cp =", tune_dt$bestTune$cp),
    paste("mtry =", tune_rf$bestTune$mtry),
    paste("C =", tune_svm$bestTune$C, ", sigma =", tune_svm$bestTune$sigma),
    paste("k =", tune_knn$bestTune$k)
  )
)

resultats_opt <- resultats_opt[order(-resultats_opt$Accuracy), ]
resultats_opt$Accuracy_Pct <- paste0(round(resultats_opt$Accuracy * 100, 2), "%")

cat("🏆 CLASSEMENT FINAL:\n\n")
print(resultats_opt[, c("Modele", "Accuracy_Pct", "Meilleur_Param")])

# Visualisation
p_opt <- ggplot(resultats_opt, aes(x = reorder(Modele, Accuracy), y = Accuracy * 100, fill = Modele)) +
  geom_bar(stat = "identity", width = 0.7) +
  geom_text(aes(label = Accuracy_Pct), hjust = -0.1, size = 4) +
  coord_flip() +
  theme_minimal() +
  labs(
    title = "Comparaison des Modèles Optimisés (GridSearch)",
    subtitle = "Validation croisée 5-fold",
    x = "",
    y = "Accuracy (%)"
  ) +
  theme(legend.position = "none") +
  ylim(0, 100)

ggsave(paste0(outputs_path, "comparaison_modeles_optimises.png"), p_opt, 
       width = 10, height = 6, dpi = 150)
cat("\n✅ Figure sauvegardée: comparaison_modeles_optimises.png\n")

# Sauvegarder les résultats
write.csv(resultats_opt, paste0(outputs_path, "resultats_optimisation.csv"), row.names = FALSE)
cat("✅ Résultats sauvegardés: resultats_optimisation.csv\n")

# ===============================================
# 💾 ENTRAÎNER ET SAUVEGARDER LE MEILLEUR MODÈLE FINAL
# ===============================================

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("💾 ENTRAÎNEMENT DU MODÈLE FINAL\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

meilleur_modele <- resultats_opt[1, ]
cat("🏆 Meilleur modèle:", meilleur_modele$Modele, "\n")
cat("   Accuracy:", meilleur_modele$Accuracy_Pct, "\n")
cat("   Paramètres:", meilleur_modele$Meilleur_Param, "\n\n")

# Entraîner sur l'ensemble complet avec les meilleurs paramètres
cat("🔄 Entraînement sur données complètes...\n")

# Utiliser plus de données pour le modèle final
FINAL_SIZE <- 10000
set.seed(42)
final_indices <- sample(1:nrow(X_full), FINAL_SIZE)
X_final <- X_full[final_indices, ]
y_final <- y_full[final_indices]

if (meilleur_modele$Modele == "Random Forest") {
  best_model_final <- randomForest(
    x = X_final,
    y = y_final,
    ntree = 100,
    mtry = tune_rf$bestTune$mtry
  )
} else if (meilleur_modele$Modele == "SVM") {
  best_model_final <- svm(
    x = as.matrix(X_final),
    y = y_final,
    type = "C-classification",
    kernel = "radial",
    cost = tune_svm$bestTune$C,
    gamma = tune_svm$bestTune$sigma
  )
} else if (meilleur_modele$Modele == "KNN") {
  best_model_final <- list(
    X_train = X_final,
    y_train = y_final,
    k = tune_knn$bestTune$k
  )
} else {
  best_model_final <- rpart(
    y_final ~ .,
    data = data.frame(y_final = y_final, X_final),
    method = "class",
    control = rpart.control(cp = tune_dt$bestTune$cp)
  )
}

saveRDS(best_model_final, paste0(models_path, "best_model_optimized.rds"))
cat("✅ Modèle final sauvegardé: best_model_optimized.rds\n")

# Arrêter le cluster parallèle
stopCluster(cl)

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("✅ OPTIMISATION TERMINÉE !\n")
cat("=" , rep("=", 49), "\n")
