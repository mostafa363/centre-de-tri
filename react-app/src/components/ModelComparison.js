import React, { useState, useEffect } from 'react';
import './ModelComparison.css';

const ModelComparison = () => {
  const [modelStats, setModelStats] = useState(null);

  useEffect(() => {
    // Load model comparison data
    const stats = {
      models: [
        {
          name: 'SVM',
          accuracy: 97.94,
          trainingTime: 355.3,
          predictions: 8400,
          color: '#8b5cf6',
          description: 'Support Vector Machine - Best overall accuracy'
        },
        {
          name: 'KNN',
          accuracy: 96.82,
          trainingTime: 539.4,
          predictions: 8400,
          color: '#06b6d4',
          description: 'K-Nearest Neighbors (k=5)'
        },
        {
          name: 'Random Forest',
          accuracy: 96.14,
          trainingTime: 544.2,
          predictions: 8400,
          color: '#10b981',
          description: 'Ensemble of decision trees'
        },
        {
          name: 'Decision Tree',
          accuracy: 78.24,
          trainingTime: 45.3,
          predictions: 8400,
          color: '#f59e0b',
          description: 'Simple tree-based classifier'
        }
      ],
      trainingData: {
        total: 42000,
        trainSize: 33600,
        testSize: 8400
      }
    };
    setModelStats(stats);
  }, []);

  if (!modelStats) {
    return <div className="loading">Loading model data...</div>;
  }

  const maxAccuracy = Math.max(...modelStats.models.map(m => m.accuracy));
  const maxTime = Math.max(...modelStats.models.map(m => m.trainingTime));

  return (
    <div className="model-comparison">
      <div className="comparison-header">
        <h1>🤖 Model Performance Comparison</h1>
        <p>Trained on {modelStats.trainingData.total.toLocaleString()} MNIST images</p>
      </div>

      {/* Best Model Highlight */}
      <div className="best-model-card">
        <div className="trophy">🏆</div>
        <h2>Best Model: SVM</h2>
        <div className="best-stats">
          <div className="stat">
            <span className="value">97.94%</span>
            <span className="label">Accuracy</span>
          </div>
          <div className="stat">
            <span className="value">355s</span>
            <span className="label">Training Time</span>
          </div>
        </div>
      </div>

      {/* Accuracy Comparison */}
      <div className="comparison-section">
        <h2>📊 Accuracy Comparison</h2>
        <div className="bar-chart">
          {modelStats.models.map((model, idx) => (
            <div key={idx} className="bar-item">
              <div className="bar-label">{model.name}</div>
              <div className="bar-container">
                <div
                  className="bar-fill"
                  style={{
                    width: `${(model.accuracy / maxAccuracy) * 100}%`,
                    backgroundColor: model.color
                  }}
                >
                  <span className="bar-value">{model.accuracy}%</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Training Time Comparison */}
      <div className="comparison-section">
        <h2>⏱️ Training Time Comparison</h2>
        <div className="bar-chart">
          {modelStats.models.map((model, idx) => (
            <div key={idx} className="bar-item">
              <div className="bar-label">{model.name}</div>
              <div className="bar-container">
                <div
                  className="bar-fill time-bar"
                  style={{
                    width: `${(model.trainingTime / maxTime) * 100}%`,
                    backgroundColor: model.color
                  }}
                >
                  <span className="bar-value">{model.trainingTime}s</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Model Cards */}
      <div className="comparison-section">
        <h2>📋 Model Details</h2>
        <div className="model-grid">
          {modelStats.models.map((model, idx) => (
            <div key={idx} className="model-card" style={{ borderColor: model.color }}>
              <div className="model-header" style={{ backgroundColor: model.color }}>
                <h3>{model.name}</h3>
              </div>
              <div className="model-body">
                <p className="model-description">{model.description}</p>
                <div className="model-metrics">
                  <div className="metric">
                    <span className="metric-label">Accuracy</span>
                    <span className="metric-value">{model.accuracy}%</span>
                  </div>
                  <div className="metric">
                    <span className="metric-label">Training Time</span>
                    <span className="metric-value">{model.trainingTime}s</span>
                  </div>
                  <div className="metric">
                    <span className="metric-label">Test Predictions</span>
                    <span className="metric-value">{model.predictions.toLocaleString()}</span>
                  </div>
                </div>
                {idx === 0 && (
                  <div className="badge best-badge">Currently Active</div>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Performance Matrix */}
      <div className="comparison-section">
        <h2>📈 Performance Matrix</h2>
        <div className="matrix-grid">
          <div className="matrix-card">
            <div className="matrix-icon">🎯</div>
            <div className="matrix-value">{modelStats.trainingData.trainSize.toLocaleString()}</div>
            <div className="matrix-label">Training Samples</div>
          </div>
          <div className="matrix-card">
            <div className="matrix-icon">✅</div>
            <div className="matrix-value">{modelStats.trainingData.testSize.toLocaleString()}</div>
            <div className="matrix-label">Test Samples</div>
          </div>
          <div className="matrix-card">
            <div className="matrix-icon">🔢</div>
            <div className="matrix-value">784</div>
            <div className="matrix-label">Features (28×28)</div>
          </div>
          <div className="matrix-card">
            <div className="matrix-icon">🎲</div>
            <div className="matrix-value">10</div>
            <div className="matrix-label">Classes (0-9)</div>
          </div>
        </div>
      </div>

      {/* Generated Visualizations */}
      <div className="comparison-section">
        <h2>📊 Generated Visualizations</h2>
        <div className="viz-grid">
          <div className="viz-card">
            <h3>Model Accuracy Comparison</h3>
            <img src="/outputs/figures/comparaison_modeles.png" alt="Model Comparison" />
          </div>
          <div className="viz-card">
            <h3>Training Time Analysis</h3>
            <img src="/outputs/figures/temps_entrainement.png" alt="Training Time" />
          </div>
        </div>
      </div>
    </div>
  );
};

export default ModelComparison;
