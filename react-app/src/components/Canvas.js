import React, { useRef, useEffect, useState } from 'react';

const Canvas = ({ onCanvasReady }) => {
  const canvasRef = useRef(null);
  const [isDrawing, setIsDrawing] = useState(false);
  const [lastPos, setLastPos] = useState({ x: 0, y: 0 });

  // Configuration du canvas
  const canvasSize = 280; // 280x280 pour un meilleur dessin (10x MNIST)
  const lineWidth = 20; // Thicker line for better MNIST-like digits
  const lineColor = 'white';

  useEffect(() => {
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');

    // Fond noir
    ctx.fillStyle = 'black';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    // Configuration du trait
    ctx.strokeStyle = lineColor;
    ctx.lineWidth = lineWidth;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';

    // Passer la référence au parent
    if (onCanvasReady) {
      onCanvasReady(canvas);
    }
  }, [onCanvasReady]);

  // Obtenir la position relative au canvas
  const getPosition = (e) => {
    const canvas = canvasRef.current;
    const rect = canvas.getBoundingClientRect();
    
    // Support tactile
    if (e.touches) {
      return {
        x: e.touches[0].clientX - rect.left,
        y: e.touches[0].clientY - rect.top
      };
    }
    
    return {
      x: e.clientX - rect.left,
      y: e.clientY - rect.top
    };
  };

  // Commencer à dessiner
  const startDrawing = (e) => {
    e.preventDefault();
    const pos = getPosition(e);
    setIsDrawing(true);
    setLastPos(pos);

    // Dessiner un point
    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    ctx.beginPath();
    ctx.arc(pos.x, pos.y, lineWidth / 2, 0, Math.PI * 2);
    ctx.fillStyle = lineColor;
    ctx.fill();
  };

  // Dessiner
  const draw = (e) => {
    if (!isDrawing) return;
    e.preventDefault();

    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    const pos = getPosition(e);

    ctx.beginPath();
    ctx.moveTo(lastPos.x, lastPos.y);
    ctx.lineTo(pos.x, pos.y);
    ctx.stroke();

    setLastPos(pos);
  };

  // Arrêter de dessiner
  const stopDrawing = () => {
    setIsDrawing(false);
  };

  return (
    <div className="canvas-wrapper">
      <canvas
        ref={canvasRef}
        width={canvasSize}
        height={canvasSize}
        onMouseDown={startDrawing}
        onMouseMove={draw}
        onMouseUp={stopDrawing}
        onMouseLeave={stopDrawing}
        onTouchStart={startDrawing}
        onTouchMove={draw}
        onTouchEnd={stopDrawing}
      />
    </div>
  );
};

export default Canvas;
