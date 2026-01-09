import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './PredictionsHistory.css';

const API_BASE_URL = 'http://localhost:8000';

const PredictionsHistory = () => {
  const [history, setHistory] = useState([]);
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const loadData = async () => {
    setLoading(true);
    setError(null);
    
    try {
      const [historyRes, statsRes] = await Promise.all([
        axios.get(`${API_BASE_URL}/predictions/history?limit=100`),
        axios.get(`${API_BASE_URL}/predictions/stats`)
      ]);

      if (historyRes.data.success) {
        setHistory(historyRes.data.predictions || []);
      }
      
      if (statsRes.data.success) {
        setStats(statsRes.data);
      }
    } catch (err) {
      setError('MongoDB not connected. Start MongoDB to save predictions.');
      console.error('Error loading data:', err);
    } finally {
      setLoading(false);
    }
  };

  const clearHistory = async () => {
    if (!window.confirm('Clear all prediction history?')) return;
    
    try {
      await axios.delete(`${API_BASE_URL}/predictions/clear`);
      setHistory([]);
      setStats(null);
      alert('History cleared!');
    } catch (err) {
      alert('Error clearing history');
    }
  };

  useEffect(() => {
    loadData();
    // Refresh every 5 seconds
    const interval = setInterval(loadData, 5000);
    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return (
      <div className="predictions-history">
        <div className="loading">Loading predictions...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="predictions-history">
        <div className="error-card">
          <div className="error-icon">⚠️</div>
          <h2>MongoDB Not Connected</h2>
          <p>{error}</p>
          <a href="/MONGODB_SETUP.md" target="_blank" className="setup-link">
            📚 View Setup Instructions
          </a>
        </div>
      </div>
    );
  }

  return (
    <div className="predictions-history">
      <div className="history-header">
        <h1>📊 Predictions History</h1>
        <button onClick={clearHistory} className="clear-btn">
          🗑️ Clear History
        </button>
      </div>

      {/* Statistics Cards */}
      {stats && (
        <div className="stats-grid">
          <div className="stat-card">
            <div className="stat-icon">🎯</div>
            <div className="stat-value">{stats.total_predictions}</div>
            <div className="stat-label">Total Predictions</div>
          </div>
          
          <div className="stat-card">
            <div className="stat-icon">📈</div>
            <div className="stat-value">{stats.avg_confidence}%</div>
            <div className="stat-label">Avg Confidence</div>
          </div>
          
          <div className="stat-card">
            <div className="stat-icon">🔢</div>
            <div className="stat-value">{stats.most_predicted}</div>
            <div className="stat-label">Most Predicted</div>
          </div>
          
          <div className="stat-card">
            <div className="stat-icon">🤖</div>
            <div className="stat-value">{stats.model_type}</div>
            <div className="stat-label">Model Used</div>
          </div>
        </div>
      )}

      {/* Digit Distribution Chart */}
      {stats && stats.digit_distribution && (
        <div className="distribution-section">
          <h2>Digit Distribution</h2>
          <div className="distribution-chart">
            {Object.entries(stats.digit_distribution).map(([digit, count]) => (
              <div key={digit} className="distribution-bar">
                <div className="digit-label">{digit}</div>
                <div className="bar-container">
                  <div 
                    className="bar-fill"
                    style={{ 
                      width: `${(count / stats.total_predictions) * 100}%`,
                      backgroundColor: `hsl(${digit * 36}, 70%, 60%)`
                    }}
                  >
                    <span className="count">{count}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* History Table */}
      <div className="history-section">
        <h2>Recent Predictions</h2>
        {history.length === 0 ? (
          <div className="empty-state">
            <div className="empty-icon">📭</div>
            <p>No predictions yet. Start predicting digits!</p>
          </div>
        ) : (
          <div className="history-table">
            <table>
              <thead>
                <tr>
                  <th>Prediction</th>
                  <th>Confidence</th>
                  <th>Model</th>
                  <th>Timestamp</th>
                </tr>
              </thead>
              <tbody>
                {history.map((pred, idx) => (
                  <tr key={idx}>
                    <td>
                      <span className="prediction-digit">{pred.prediction}</span>
                    </td>
                    <td>
                      <div className="confidence-cell">
                        <div className="confidence-bar-mini">
                          <div 
                            className="confidence-fill-mini"
                            style={{ width: `${pred.confidence}%` }}
                          />
                        </div>
                        <span>{pred.confidence}%</span>
                      </div>
                    </td>
                    <td>
                      <span className="model-badge">{pred.model_type}</span>
                    </td>
                    <td className="timestamp">
                      {new Date(pred.timestamp).toLocaleString()}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
};

export default PredictionsHistory;
