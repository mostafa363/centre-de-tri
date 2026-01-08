# 🔢 Digit Recognition - Application React + API R

Application web pour la reconnaissance de chiffres manuscrits utilisant React JS et une API R (Plumber).

## 📁 Structure du Projet

```
CENTRE de tri/
├── api/                    # API Backend (R Plumber)
│   ├── plumber.R          # Définition de l'API
│   └── run_api.R          # Script pour lancer l'API
│
├── react-app/             # Frontend React
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── components/
│   │   │   ├── Canvas.js  # Composant canvas pour dessiner
│   │   │   └── Result.js  # Affichage du résultat
│   │   ├── services/
│   │   │   └── api.js     # Communication avec l'API R
│   │   ├── App.js         # Composant principal
│   │   ├── index.js       # Point d'entrée
│   │   └── index.css      # Styles
│   └── package.json
│
├── scripts/               # Scripts R pour ML
│   ├── 01_exploration.R
│   ├── 02_train_models.R
│   ├── 03_optimization.R
│   └── 04_evaluation.R
│
├── models/                # Modèles sauvegardés (.rds)
└── data/                  # Dataset MNIST
```

## 🚀 Installation et Lancement

### 1. Prérequis

**R (Backend):**
```r
install.packages(c("plumber", "jsonlite", "randomForest", "e1071", "rpart", "class"))
```

**Node.js (Frontend):**
- Node.js 18+ : https://nodejs.org/

### 2. Entraîner le Modèle (si pas encore fait)

```r
# Dans R/RStudio
setwd("c:/Users/SURFACEE/Desktop/CENTRE  de tri")
source("scripts/02_train_models.R")
```

### 3. Lancer l'API R

```r
# Dans R/RStudio
source("c:/Users/SURFACEE/Desktop/CENTRE  de tri/api/run_api.R")
```

L'API sera disponible sur: **http://localhost:8000**
Documentation Swagger: **http://localhost:8000/__docs__/**

### 4. Lancer l'Application React

```bash
# Dans un terminal
cd "c:\Users\SURFACEE\Desktop\CENTRE  de tri\react-app"
npm install
npm start
```

L'application sera disponible sur: **http://localhost:3000**

## 📡 Endpoints API

| Méthode | Endpoint      | Description                    |
|---------|---------------|--------------------------------|
| GET     | /health       | Vérifier l'état de l'API       |
| POST    | /predict      | Prédire un chiffre             |
| GET     | /model-info   | Informations sur le modèle     |

### Exemple de requête `/predict`

```json
POST /predict
Content-Type: application/json

{
  "pixels": [0, 0, 0, ..., 255, ...] // 784 valeurs (0-255)
}
```

### Réponse

```json
{
  "success": true,
  "prediction": 7,
  "confidence": 94.5
}
```

## 🎨 Fonctionnalités

- ✏️ **Canvas interactif** : Dessinez un chiffre avec la souris ou le doigt (tactile)
- 🔍 **Prédiction en temps réel** : Envoi à l'API R pour classification
- 📊 **Indicateur de confiance** : Affichage de la probabilité de prédiction
- 👀 **Prévisualisation** : Voir l'image 28x28 envoyée au modèle
- 📱 **Responsive** : Fonctionne sur mobile et desktop

## 🛠️ Technologies

**Frontend:**
- React 18
- Axios (requêtes HTTP)
- CSS3 (animations, gradients)

**Backend:**
- R + Plumber (API REST)
- randomForest / SVM / Decision Tree
- MNIST Dataset (28x28 pixels)

## 📝 Notes

- L'API R doit être lancée **avant** d'utiliser l'application React
- Le modèle est chargé au démarrage de l'API depuis le dossier `models/`
- Les images sont redimensionnées de 280x280 à 28x28 côté client
