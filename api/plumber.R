# ===============================================
# 🚀 API REST - Digit Recognition
# Backend R avec Plumber
# ===============================================

library(plumber)
library(jsonlite)
library(e1071)  # For SVM models
library(randomForest)  # For Random Forest models
library(rpart)  # For Decision Tree models

# Charger le modèle
models_path <- "c:/Users/Me/Desktop/RH/centre-de-tri/models/"

# Prefer Random Forest for real confidence scores
if (file.exists(paste0(models_path, "model_random_forest.rds"))) {
  model <- readRDS(paste0(models_path, "model_random_forest.rds"))
  cat("✅ Random Forest chargé (donne des scores de confiance réels)\n")
} else if (file.exists(paste0(models_path, "best_model_optimized.rds"))) {
  model <- readRDS(paste0(models_path, "best_model_optimized.rds"))
  cat("✅ Modèle optimisé chargé\n")
} else if (file.exists(paste0(models_path, "best_model.rds"))) {
  model <- readRDS(paste0(models_path, "best_model.rds"))
  cat("✅ Modèle de base chargé\n")
} else {
  cat("⚠️ Aucun modèle trouvé!\n")
  model <- NULL
}

#* @apiTitle Digit Recognition API
#* @apiDescription API pour la reconnaissance de chiffres manuscrits (MNIST)

#* Enable CORS
#* @filter cors
function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  res$setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
  res$setHeader("Access-Control-Allow-Headers", "Content-Type")
  
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$status <- 200
    return(list())
  }
  
  plumber::forward()
}

#* Health check
#* @get /health
function() {
  list(
    status = "ok",
    model_loaded = !is.null(model),
    timestamp = Sys.time()
  )
}

#* Predict digit from pixel array
#* @param pixels Array of 784 pixel values (0-255)
#* @post /predict
function(req) {
  cat("\n📨 Received prediction request\n")
  tryCatch({
    # Parser le body JSON
    body <- jsonlite::fromJSON(req$postBody)
    pixels <- as.numeric(body$pixels)
    
    cat("   📊 Pixels received:", length(pixels), "\n")
    
    # Vérifier les données
    if (length(pixels) != 784) {
      cat("   ❌ Wrong number of pixels!\n")
      return(list(
        success = FALSE,
        error = paste("Expected 784 pixels, got", length(pixels))
      ))
    }
    
    # Normaliser (0-255 -> 0-1)
    pixels_normalized <- pixels / 255
    
    # Créer le dataframe pour la prédiction
    pixel_df <- as.data.frame(t(pixels_normalized))
    names(pixel_df) <- paste0("pixel", 0:783)
    
    # Log model class for debugging
    cat("   🤖 Model class:", class(model), "\n")
    
    # Prédiction selon le type de modèle
    if ("randomForest" %in% class(model)) {
      prediction <- predict(model, pixel_df)
      # Obtenir les probabilités
      probs <- predict(model, pixel_df, type = "prob")
      confidence <- max(probs) * 100
      cat("   ✅ Prediction:", prediction, "Confidence:", round(confidence, 2), "%\n")
    } else if ("svm.formula" %in% class(model) || "svm" %in% class(model)) {
      # SVM needs matrix input, not dataframe
      pixel_matrix <- as.matrix(pixel_df)
      prediction <- predict(model, pixel_matrix)
      confidence <- 85  # SVM ne donne pas de probabilités directement
    } else if ("rpart" %in% class(model)) {
      prediction <- predict(model, pixel_df, type = "class")
      probs <- predict(model, pixel_df, type = "prob")
      confidence <- max(probs) * 100
    } else if (is.list(model) && "k" %in% names(model)) {
      # KNN
      prediction <- class::knn(
        train = model$X_train,
        test = pixel_df,
        cl = model$y_train,
        k = model$k
      )
      confidence <- 80  # KNN basique ne donne pas de probabilités
    } else {
      prediction <- predict(model, pixel_df)
      confidence <- 75
    }
    
    list(
      success = TRUE,
      prediction = as.integer(as.character(prediction)),
      confidence = round(confidence, 2)
    )
    
  }, error = function(e) {
    list(
      success = FALSE,
      error = as.character(e$message)
    )
  })
}

#* Get model info
#* @get /model-info
function() {
  if (is.null(model)) {
    return(list(success = FALSE, error = "No model loaded"))
  }
  
  model_type <- class(model)[1]
  
  list(
    success = TRUE,
    model_type = model_type,
    input_size = 784,
    output_classes = 0:9
  )
}
