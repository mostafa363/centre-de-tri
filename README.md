# 🔢 Digit Recognition - Centre de Tri Postal

## 📋 Description du Projet

Application de reconnaissance de chiffres manuscrits (OCR) utilisant le dataset MNIST.
Développée en **R** avec **Shiny** pour la WebApp.

### 🎯 Objectifs
- Reconnaître automatiquement les chiffres manuscrits (0-9)
- Application : Tri automatique du courrier postal (codes postaux)
- WebApp interactive permettant de dessiner et classifier des chiffres

---

## 📁 Structure du Projet

```
CENTRE de tri/
│
├── 📂 data/                    ← DONNÉES MNIST
│   ├── mnist_train.csv         ← ⚠️ À AJOUTER
│   ├── mnist_test.csv          ← ⚠️ À AJOUTER
│   └── images/                 ← Images MNIST (optionnel)
│
├── 📂 notebooks/               ← Notebooks R Markdown
│   └── exploration_mnist.Rmd
│
├── 📂 scripts/                 ← Scripts R
│   ├── 01_exploration.R
│   ├── 02_preprocessing.R
│   ├── 03_train_models.R
│   ├── 04_evaluation.R
│   └── 05_select_best.R
│
├── 📂 models/                  ← Modèles sauvegardés (.rds)
│   ├── model_decision_tree.rds
│   ├── model_random_forest.rds
│   ├── model_svm.rds
│   └── best_model.rds
│
├── 📂 shiny_app/              ← Application Web Shiny
│   ├── app.R
│   ├── www/
│   │   ├── style.css
│   │   └── canvas.js
│   └── model/
│
├── 📂 outputs/                ← Résultats et figures
│   ├── figures/
│   └── reports/
│
└── README.md
```

---

## 🚀 Installation

### Prérequis
- R (version >= 4.0)
- RStudio (recommandé)

### Packages R requis
```r
install.packages(c(
  "tidyverse",      # Manipulation de données
  "ggplot2",        # Visualisations
  "caret",          # Machine Learning
  "randomForest",   # Random Forest
  "e1071",          # SVM
  "rpart",          # Decision Tree
  "class",          # KNN
  "shiny",          # WebApp
  "shinydashboard", # Dashboard
  "keras",          # Deep Learning (optionnel)
  "MLmetrics"       # Métriques
))
```

---

## 📊 Modèles Entraînés

| Modèle | Description | Accuracy |
|--------|-------------|----------|
| Decision Tree | Arbre de décision | - |
| Random Forest | Forêt aléatoire | - |
| SVM | Support Vector Machine | - |
| KNN | K-Nearest Neighbors | - |
| CNN | Réseau de neurones convolutif | - |

---

## 🌐 WebApp

L'application Shiny permet de :
- ✏️ Dessiner un chiffre sur un canvas
- 🔮 Obtenir la prédiction du modèle
- 📊 Voir le niveau de confiance
- 🧹 Effacer et recommencer

### Lancer l'application
```r
shiny::runApp("shiny_app")
```

---

## 👥 Équipe

- [Nom 1]
- [Nom 2]
- ...

---

## 📎 Liens Utiles

- [MNIST Dataset](http://yann.lecun.com/exdb/mnist/)
- [MNIST CSV Format](https://pjreddie.com/projects/mnist-in-csv/)
- [Trello du projet](lien_trello)
- [Présentation](lien_slides)

---

## 📅 Date de rendu

Janvier 2026
