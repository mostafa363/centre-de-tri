import React, { useState } from 'react';
import Canvas from './components/Canvas';
import Result from './components/Result';
import { predictDigit } from './services/api';

function App() {
  const [prediction, setPrediction] = useState(null);
  const [confidence, setConfidence] = useState(0);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [previewImage, setPreviewImage] = useState(null);
  const [canvasRef, setCanvasRef] = useState(null);

  // Fonction pour obtenir les pixels du canvas et prédire
  const handlePredict = async () => {
    if (!canvasRef) return;

    setLoading(true);
    setError(null);

    try {
      // Obtenir le contexte du canvas
      const canvas = canvasRef;
      const ctx = canvas.getContext('2d');

      // Créer un canvas 28x28 pour le redimensionnement
      const smallCanvas = document.createElement('canvas');
      smallCanvas.width = 28;
      smallCanvas.height = 28;
      const smallCtx = smallCanvas.getContext('2d');

      // Dessiner l'image redimensionnée
      smallCtx.fillStyle = 'black';
      smallCtx.fillRect(0, 0, 28, 28);
      smallCtx.drawImage(canvas, 0, 0, canvas.width, canvas.height, 0, 0, 28, 28);

      // Obtenir les données de pixels
      const imageData = smallCtx.getImageData(0, 0, 28, 28);
      const pixels = [];

      // Convertir en niveaux de gris (784 valeurs)
      for (let i = 0; i < imageData.data.length; i += 4) {
        // Utiliser le canal rouge (ou faire une moyenne)
        const gray = imageData.data[i]; // Canal rouge
        pixels.push(gray);
      }

      // Créer l'image de prévisualisation
      setPreviewImage(smallCanvas.toDataURL());

      // Appeler l'API
      const result = await predictDigit(pixels);

      if (result.success) {
        setPrediction(result.prediction);
        setConfidence(result.confidence);
      } else {
        setError(result.error || 'Erreur de prédiction');
      }
    } catch (err) {
      console.error('Erreur:', err);
      setError('Erreur de connexion à l\'API. Vérifiez que le serveur R est lancé.');
    } finally {
      setLoading(false);
    }
  };

  // Effacer le canvas
  const handleClear = () => {
    if (canvasRef) {
      const ctx = canvasRef.getContext('2d');
      ctx.fillStyle = 'black';
      ctx.fillRect(0, 0, canvasRef.width, canvasRef.height);
    }
    setPrediction(null);
    setConfidence(0);
    setError(null);
    setPreviewImage(null);
  };

  return (
    <div className="app">
      {/* Header */}
      <header className="header">
        <h1>🔢 Digit Recognition</h1>
        <p>Centre de Tri Postal - Reconnaissance de chiffres manuscrits</p>
      </header>

      {/* Main Container */}
      <main className="main-container">
        {/* Canvas Section */}
        <section className="canvas-section">
          <h2>✏️ Dessinez un chiffre</h2>
          <Canvas onCanvasReady={setCanvasRef} />
          
          <div className="buttons">
            <button 
              className="btn btn-primary" 
              onClick={handlePredict}
              disabled={loading}
            >
              {loading ? '⏳ Analyse...' : '🔍 Prédire'}
            </button>
            <button 
              className="btn btn-secondary" 
              onClick={handleClear}
            >
              🗑️ Effacer
            </button>
          </div>

          {/* Preview 28x28 */}
          {previewImage && (
            <div className="preview-section">
              <h3>Image envoyée (28x28):</h3>
              <img 
                src={previewImage} 
                alt="Preview 28x28" 
                className="preview-image"
              />
            </div>
          )}
        </section>

        {/* Result Section */}
        <section className="result-section">
          <h2>🎯 Résultat</h2>
          <Result 
            prediction={prediction}
            confidence={confidence}
            loading={loading}
            error={error}
          />
        </section>
      </main>

      {/* Info Section */}
      <section className="info-section">
        <h3>📊 À propos</h3>
        <div className="info-grid">
          <div className="info-card">
            <div className="icon">🧠</div>
            <div className="label">Modèle</div>
            <div className="value">Random Forest</div>
          </div>
          <div className="info-card">
            <div className="icon">📚</div>
            <div className="label">Dataset</div>
            <div className="value">MNIST</div>
          </div>
          <div className="info-card">
            <div className="icon">🔢</div>
            <div className="label">Classes</div>
            <div className="value">0-9</div>
          </div>
          <div className="info-card">
            <div className="icon">📐</div>
            <div className="label">Input</div>
            <div className="value">28×28 px</div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="footer">
        <p>TP Machine Learning - Améliorer l'efficacité du centre de tri</p>
      </footer>
    </div>
  );
}

export default App;
