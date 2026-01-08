import axios from 'axios';

// URL de l'API R (Plumber)
const API_BASE_URL = 'http://localhost:8000';

/**
 * Prédire un chiffre à partir des pixels
 * @param {number[]} pixels - Tableau de 784 valeurs (0-255)
 * @returns {Promise<{success: boolean, prediction?: number, confidence?: number, error?: string}>}
 */
export const predictDigit = async (pixels) => {
  try {
    const response = await axios.post(`${API_BASE_URL}/predict`, {
      pixels: pixels
    }, {
      headers: {
        'Content-Type': 'application/json'
      }
    });

    return response.data;
  } catch (error) {
    console.error('API Error:', error);
    
    if (error.response) {
      // Erreur du serveur
      return {
        success: false,
        error: error.response.data.error || `Erreur serveur: ${error.response.status}`
      };
    } else if (error.request) {
      // Pas de réponse du serveur
      return {
        success: false,
        error: 'Impossible de contacter le serveur. Vérifiez que l\'API R est lancée sur http://localhost:8000'
      };
    } else {
      return {
        success: false,
        error: error.message
      };
    }
  }
};

/**
 * Vérifier l'état de l'API
 * @returns {Promise<{status: string, model_loaded: boolean}>}
 */
export const checkHealth = async () => {
  try {
    const response = await axios.get(`${API_BASE_URL}/health`);
    return response.data;
  } catch (error) {
    return {
      status: 'error',
      model_loaded: false
    };
  }
};

/**
 * Obtenir les informations sur le modèle
 * @returns {Promise<Object>}
 */
export const getModelInfo = async () => {
  try {
    const response = await axios.get(`${API_BASE_URL}/model-info`);
    return response.data;
  } catch (error) {
    return {
      success: false,
      error: 'Impossible de récupérer les infos du modèle'
    };
  }
};
