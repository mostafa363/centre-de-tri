# ===============================================
# 📥 Téléchargement du dataset MNIST (format CSV)
# Source: Kaggle Competition - digit-recognizer
# ===============================================

import kagglehub
import os
import shutil

# Chemin de destination
destination = os.path.dirname(os.path.abspath(__file__))

print("=" * 50)
print("📥 Téléchargement MNIST (format CSV) depuis Kaggle...")
print("=" * 50)

try:
    # Télécharger depuis la compétition digit-recognizer
    path = kagglehub.competition_download("digit-recognizer")
    
    print(f"\n✅ Dataset téléchargé dans : {path}")
    
    # Lister et copier les fichiers
    if os.path.exists(path):
        print("\n📂 Fichiers téléchargés :")
        for f in os.listdir(path):
            print(f"   📄 {f}")
            # Copier les CSV vers data/
            if f.endswith('.csv'):
                src = os.path.join(path, f)
                dst = os.path.join(destination, f)
                shutil.copy2(src, dst)
                print(f"      ✅ Copié vers: {dst}")
        
        print("\n✅ Téléchargement et copie terminés !")
        
except Exception as e:
    print(f"\n⚠️ Erreur avec kagglehub : {e}")
    print("""
⚠️  TÉLÉCHARGEMENT MANUEL REQUIS :

1. Allez sur : https://www.kaggle.com/competitions/digit-recognizer/data
2. Connectez-vous à votre compte Kaggle
3. Cliquez sur "Download All"
4. Extrayez le ZIP téléchargé
5. Copiez les fichiers dans :
   c:\\Users\\SURFACEE\\Desktop\\CENTRE de tri\\data\\
   
   Fichiers attendus :
   - train.csv
   - test.csv
""")

print("\n" + "=" * 50)
print("✅ SCRIPT TERMINÉ !")
print("=" * 50)
