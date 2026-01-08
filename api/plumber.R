# ===============================================
# 🚀 API REST - Digit Recognition
# Backend R avec Plumber
# ===============================================

library(plumber)
library(jsonlite)

# Charger le modèle
models_path <- "c:/Users/SURFACEE/Desktop/CENTRE  de tri/models/"

# Charger le meilleur modèle disponible
if (file.exists(paste0(models_path, "best_model_optimized.rds"))) {
  model <- readRDS(paste0(models_path, "best_model_optimized.rds"))
  cat("✅ Modèle optimisé chargé\n")
} else if (file.exists(paste0(models_path, "best_model.rds"))) {
  model <- readRDS(paste0(models_path, "best_model.rds"))
  cat("✅ Modèle de base chargé\n")
} else if (file.exists(paste0(models_path, "model_random_forest.rds"))) {
  model <- readRDS(paste0(models_path, "model_random_forest.rds"))
  cat("✅ Random Forest chargé\n")
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
  tryCatch({
    # Parser le body JSON
    body <- jsonlite::fromJSON(req$postBody)
    pixels <- as.numeric(body$pixels)
    
    # Vérifier les données
    if (length(pixels) != 784) {
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
    
    # Prédiction selon le type de modèle
    if ("randomForest" %in% class(model)) {
      prediction <- predict(model, pixel_df)
      # Obtenir les probabilités
      probs <- predict(model, pixel_df, type = "prob")
      confidence <- max(probs) * 100
    } else if ("svm" %in% class(model)) {
      prediction <- predict(model, as.matrix(pixel_df))
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
