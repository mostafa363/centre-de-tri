import React, { useState } from 'react';
import Canvas from './components/Canvas';
import Result from './components/Result';
import ModelComparison from './components/ModelComparison';
import PredictionsHistory from './components/PredictionsHistory';
import { predictDigit } from './services/api';

function App() {
  const [currentPage, setCurrentPage] = useState('home');
  const [prediction, setPrediction] = useState(null);
  const [confidence, setConfidence] = useState(0);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [previewImage, setPreviewImage] = useState(null);
  const [canvasRef, setCanvasRef] = useState(null);

  if (currentPage === 'comparison') {
    return (
      <div className="app">
        <header className="header">
          <h1>🔢 Digit Recognition</h1>
          <button 
            className="nav-btn"
            onClick={() => setCurrentPage('home')}
          >
            ← Back to Predictor
          </button>
        </header>
        <ModelComparison />
      </div>
    );
  }

  if (currentPage === 'history') {
    return (
      <div className="app">
        <header className="header">
          <h1>🔢 Digit Recognition</h1>
          <button 
            className="nav-btn"
            onClick={() => setCurrentPage('home')}
          >
            ← Back to Predictor
          </button>
        </header>
        <PredictionsHistory />
      </div>
    );
  }

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

      // Better preprocessing like MNIST
      // 1. Find bounding box of the drawing
      const srcData = ctx.getImageData(0, 0, canvas.width, canvas.height);
      let minX = canvas.width, minY = canvas.height, maxX = 0, maxY = 0;
      
      for (let y = 0; y < canvas.height; y++) {
        for (let x = 0; x < canvas.width; x++) {
          const i = (y * canvas.width + x) * 4;
          if (srcData.data[i] > 0) { // If pixel is not black
            minX = Math.min(minX, x);
            minY = Math.min(minY, y);
            maxX = Math.max(maxX, x);
            maxY = Math.max(maxY, y);
          }
        }
      }
      
      // 2. Add padding (20% of bounding box)
      const padding = 20;
      minX = Math.max(0, minX - padding);
      minY = Math.max(0, minY - padding);
      maxX = Math.min(canvas.width, maxX + padding);
      maxY = Math.min(canvas.height, maxY + padding);
      
      const width = maxX - minX;
      const height = maxY - minY;
      
      // 3. Create centered 28x28 image
      smallCtx.fillStyle = 'black';
      smallCtx.fillRect(0, 0, 28, 28);
      
      // Calculate scale to fit in 20x20 (leaving 4px border like MNIST)
      const scale = Math.min(20 / width, 20 / height);
      const scaledWidth = width * scale;
      const scaledHeight = height * scale;
      
      // Center it
      const offsetX = (28 - scaledWidth) / 2;
      const offsetY = (28 - scaledHeight) / 2;
      
      smallCtx.drawImage(
        canvas,
        minX, minY, width, height,
        offsetX, offsetY, scaledWidth, scaledHeight
      );

      // Obtenir les données de pixels
      const imageData = smallCtx.getImageData(0, 0, 28, 28);
      const pixels = [];

      // Convertir en niveaux de gris (784 valeurs)
      for (let i = 0; i < imageData.data.length; i += 4) {
        // Proper grayscale conversion
        const r = imageData.data[i];
        const g = imageData.data[i + 1];
        const b = imageData.data[i + 2];
        const gray = Math.round(0.299 * r + 0.587 * g + 0.114 * b);
        pixels.push(gray);
      }

      // Créer l'image de prévisualisation
      setPreviewImage(smallCanvas.toDataURL());

      // Debug: check pixel statistics
      const nonZero = pixels.filter(p => p > 0).length;
      const avg = pixels.reduce((a, b) => a + b, 0) / pixels.length;
      const max = Math.max(...pixels);
      console.log('Pixel stats:', { nonZero, avg: avg.toFixed(1), max });

      // Appeler l'API
      const result = await predictDigit(pixels);
      
      console.log('API Response:', result);

      if (result.success) {
        console.log('Prediction:', result.prediction);
        console.log('Confidence:', result.confidence);
        setPrediction(result.prediction);
        setConfidence(result.confidence || 0);
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
        <button 
          className="nav-btn"
          onClick={() => setCurrentPage('comparison')}
        >
          📊 Compare Models
        </button>
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
        
        {/* Navigation Buttons */}
        <div style={{ marginTop: '30px', display: 'flex', gap: '15px', justifyContent: 'center' }}>
          <button 
            className="nav-btn"
            onClick={() => setCurrentPage('comparison')}
          >
            📊 View Model Comparison
          </button>
          <button 
            className="nav-btn"
            onClick={() => setCurrentPage('history')}
          >
            📜 View Predictions History
          </button>
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
