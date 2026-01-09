# ===============================================
# 🚀 Lancer l'API Plumber
# ===============================================

library(plumber)

# Chemin vers l'API
api_path <- "c:/Users/Me/Desktop/RH/centre-de-tri/api/plumber.R"

# Créer et lancer l'API
pr <- plumber::plumb(api_path)

cat("\n")
cat("=" , rep("=", 49), "\n", sep = "")
cat("🚀 API Digit Recognition\n")
cat("=" , rep("=", 49), "\n\n", sep = "")
cat("📡 URL: http://localhost:8000\n")
cat("📚 Documentation: http://localhost:8000/__docs__/\n\n")
cat("Endpoints disponibles:\n")
cat("  GET  /health      - Vérifier le statut\n")
cat("  POST /predict     - Prédire un chiffre\n")
cat("  GET  /model-info  - Info sur le modèle\n")
cat("\n")
cat("Appuyez sur Ctrl+C pour arrêter\n")
cat("=" , rep("=", 49), "\n\n", sep = "")

# Lancer sur le port 8000
pr$run(host = "0.0.0.0", port = 8000)
