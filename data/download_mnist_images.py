# ===============================================
# 📥 Téléchargement du dataset MNIST (format images)
# Source: Kaggle - scolianni/mnistasjpg
# ===============================================

import kagglehub
import shutil
import os

# Chemin de destination
destination = os.path.dirname(os.path.abspath(__file__))
images_folder = os.path.join(destination, "images")

print("=" * 50)
print("📥 Téléchargement MNIST (format images) depuis Kaggle...")
print("=" * 50)

# Télécharger le dataset
path = kagglehub.dataset_download("scolianni/mnistasjpg")

print(f"\n✅ Dataset téléchargé dans : {path}")
print(f"📁 Destination finale : {images_folder}")

# Copier les fichiers vers le dossier images/
print("\n📋 Copie des fichiers vers le projet...")

if os.path.exists(path):
    # Lister le contenu téléchargé
    print("\n📂 Contenu téléchargé :")
    for item in os.listdir(path):
        item_path = os.path.join(path, item)
        if os.path.isdir(item_path):
            print(f"   📁 {item}/")
        else:
            print(f"   📄 {item}")
    
    # Copier vers images/
    try:
        if os.path.exists(images_folder):
            # Supprimer l'ancien contenu sauf README
            for item in os.listdir(images_folder):
                if item != "README.txt":
                    item_path = os.path.join(images_folder, item)
                    if os.path.isdir(item_path):
                        shutil.rmtree(item_path)
                    else:
                        os.remove(item_path)
        
        # Copier le nouveau contenu
        for item in os.listdir(path):
            src = os.path.join(path, item)
            dst = os.path.join(images_folder, item)
            if os.path.isdir(src):
                shutil.copytree(src, dst)
            else:
                shutil.copy2(src, dst)
        
        print(f"\n✅ Fichiers copiés avec succès dans : {images_folder}")
        
    except Exception as e:
        print(f"\n⚠️ Erreur lors de la copie : {e}")
        print(f"💡 Les fichiers sont disponibles ici : {path}")

print("\n" + "=" * 50)
print("✅ TERMINÉ !")
print("=" * 50)
print("""
📋 Prochaines étapes :
1. Ajouter mnist_train.csv dans data/
2. Ajouter mnist_test.csv dans data/
3. Lancer le script d'exploration R
""")
