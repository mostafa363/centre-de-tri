import React from 'react';

const Result = ({ prediction, confidence, loading, error }) => {
  // État de chargement
  if (loading) {
    return (
      <div className="result-box">
        <div className="loading">
          <div className="spinner"></div>
          <span>Analyse en cours...</span>
        </div>
      </div>
    );
  }

  // État d'erreur
  if (error) {
    return (
      <div className="result-box">
        <div className="error">
          <div className="error-icon">⚠️</div>
          <p>{error}</p>
        </div>
      </div>
    );
  }

  // État initial (pas de prédiction)
  if (prediction === null) {
    return (
      <div className="result-box">
        <div className="prediction-placeholder">?</div>
        <p className="confidence">Dessinez un chiffre et cliquez sur Prédire</p>
      </div>
    );
  }

  // Afficher le résultat
  return (
    <div className="result-box">
      <div className="prediction-digit">{prediction}</div>
      <p className="confidence">Confiance: {confidence.toFixed(1)}%</p>
      <div className="confidence-bar">
        <div 
          className="confidence-fill" 
          style={{ width: `${confidence}%` }}
        />
      </div>
    </div>
  );
};

export default Result;
