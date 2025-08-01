import React, { useState, useRef, useCallback, useEffect } from 'react';
import { Button } from './button';
import { Separator } from './separator';
import { cn } from '@/lib/utils';
import { 
  X, 
  Undo2, 
  Redo2, 
  ThumbsUp, 
  ThumbsDown,
  Sparkles,
  Download,
  Share
} from 'lucide-react';

interface ApplePhotosEditorProps {
  imageUrl: string;
  onCancel: () => void;
  onDone: (processedImageBlob: Blob) => void;
  onMaskComplete?: (maskData: ImageData) => void;
  className?: string;
}

type EditingTool = 'portrait' | 'live' | 'adjust' | 'filters' | 'crop' | 'cleanup';
type ProcessingState = 'idle' | 'selecting' | 'processing' | 'completed';

interface MaskPoint {
  x: number;
  y: number;
  pressure?: number;
}

interface MaskStroke {
  points: MaskPoint[];
  brushSize: number;
}

export default function ApplePhotosEditor({ 
  imageUrl, 
  onCancel, 
  onDone, 
  onMaskComplete,
  className 
}: ApplePhotosEditorProps) {
  const [selectedTool, setSelectedTool] = useState<EditingTool>('cleanup');
  const [processingState, setProcessingState] = useState<ProcessingState>('idle');
  const [maskStrokes, setMaskStrokes] = useState<MaskStroke[]>([]);
  const [currentStroke, setCurrentStroke] = useState<MaskStroke | null>(null);
  const [undoStack, setUndoStack] = useState<MaskStroke[][]>([]);
  const [redoStack, setRedoStack] = useState<MaskStroke[][]>([]);
  const [brushSize, setBrushSize] = useState(30);
  const [processedImageUrl, setProcessedImageUrl] = useState<string>('');
  const [isDrawing, setIsDrawing] = useState(false);
  
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const imageRef = useRef<HTMLImageElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  const tools: { id: EditingTool; label: string; icon?: React.ReactNode }[] = [
    { id: 'portrait', label: 'Portrait' },
    { id: 'live', label: 'Live' },
    { id: 'adjust', label: 'Adjust' },
    { id: 'filters', label: 'Filters' },
    { id: 'crop', label: 'Crop' },
    { id: 'cleanup', label: 'Clean Up', icon: <Sparkles className="w-4 h-4" /> },
  ];

  // Initialize canvas
  useEffect(() => {
    const canvas = canvasRef.current;
    const image = imageRef.current;
    if (!canvas || !image) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const resizeCanvas = () => {
      const container = containerRef.current;
      if (!container) return;

      const containerRect = container.getBoundingClientRect();
      const imageAspectRatio = image.naturalWidth / image.naturalHeight;
      const containerAspectRatio = containerRect.width / containerRect.height;

      let displayWidth, displayHeight;
      
      if (imageAspectRatio > containerAspectRatio) {
        displayWidth = containerRect.width;
        displayHeight = displayWidth / imageAspectRatio;
      } else {
        displayHeight = containerRect.height;
        displayWidth = displayHeight * imageAspectRatio;
      }

      canvas.width = displayWidth;
      canvas.height = displayHeight;
      canvas.style.width = `${displayWidth}px`;
      canvas.style.height = `${displayHeight}px`;
      
      // Redraw existing strokes
      redrawCanvas();
    };

    image.onload = resizeCanvas;
    window.addEventListener('resize', resizeCanvas);
    
    return () => {
      window.removeEventListener('resize', resizeCanvas);
    };
  }, [imageUrl]);

  const redrawCanvas = useCallback(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    // Draw all completed strokes
    maskStrokes.forEach(stroke => {
      drawStroke(ctx, stroke);
    });

    // Draw current stroke if drawing
    if (currentStroke) {
      drawStroke(ctx, currentStroke);
    }
  }, [maskStrokes, currentStroke]);

  const drawStroke = (ctx: CanvasRenderingContext2D, stroke: MaskStroke) => {
    if (stroke.points.length === 0) return;

    ctx.save();
    ctx.globalCompositeOperation = 'source-over';
    ctx.strokeStyle = processingState === 'processing' 
      ? 'rgba(0, 122, 255, 0.6)' // Blue when processing
      : 'rgba(255, 59, 48, 0.7)'; // Red when selecting
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
    ctx.lineWidth = stroke.brushSize;

    ctx.beginPath();
    
    if (stroke.points.length === 1) {
      // Single point - draw a circle
      const point = stroke.points[0];
      ctx.arc(point.x, point.y, stroke.brushSize / 2, 0, Math.PI * 2);
      ctx.fill();
    } else {
      // Multiple points - draw smooth line
      ctx.moveTo(stroke.points[0].x, stroke.points[0].y);
      
      for (let i = 1; i < stroke.points.length - 1; i++) {
        const cp1x = (stroke.points[i].x + stroke.points[i + 1].x) / 2;
        const cp1y = (stroke.points[i].y + stroke.points[i + 1].y) / 2;
        ctx.quadraticCurveTo(stroke.points[i].x, stroke.points[i].y, cp1x, cp1y);
      }
      
      if (stroke.points.length > 1) {
        const lastPoint = stroke.points[stroke.points.length - 1];
        ctx.lineTo(lastPoint.x, lastPoint.y);
      }
      
      ctx.stroke();
    }

    ctx.restore();

    // Add pulsing effect when processing
    if (processingState === 'processing') {
      ctx.save();
      ctx.globalCompositeOperation = 'source-over';
      const pulseAlpha = 0.3 + 0.2 * Math.sin(Date.now() * 0.01);
      ctx.strokeStyle = `rgba(0, 122, 255, ${pulseAlpha})`;
      ctx.lineWidth = stroke.brushSize + 4;
      ctx.stroke();
      ctx.restore();
    }
  };

  const getCanvasCoordinates = (clientX: number, clientY: number) => {
    const canvas = canvasRef.current;
    if (!canvas) return { x: 0, y: 0 };

    const rect = canvas.getBoundingClientRect();
    return {
      x: ((clientX - rect.left) / rect.width) * canvas.width,
      y: ((clientY - rect.top) / rect.height) * canvas.height,
    };
  };

  const handlePointerDown = (e: React.PointerEvent) => {
    if (selectedTool !== 'cleanup' || processingState !== 'idle') return;

    setIsDrawing(true);
    const coords = getCanvasCoordinates(e.clientX, e.clientY);
    const newStroke: MaskStroke = {
      points: [coords],
      brushSize: brushSize,
    };
    setCurrentStroke(newStroke);
    setProcessingState('selecting');
  };

  const handlePointerMove = (e: React.PointerEvent) => {
    if (!isDrawing || !currentStroke || selectedTool !== 'cleanup') return;

    const coords = getCanvasCoordinates(e.clientX, e.clientY);
    const updatedStroke = {
      ...currentStroke,
      points: [...currentStroke.points, coords],
    };
    setCurrentStroke(updatedStroke);
    redrawCanvas();
  };

  const handlePointerUp = () => {
    if (!isDrawing || !currentStroke) return;
    
    setIsDrawing(false);
    
    // Save current state for undo
    setUndoStack(prev => [...prev, maskStrokes]);
    setRedoStack([]);
    
    // Add stroke to permanent strokes
    setMaskStrokes(prev => [...prev, currentStroke]);
    setCurrentStroke(null);
  };

  const handleUndo = () => {
    if (undoStack.length === 0) return;
    
    const previousState = undoStack[undoStack.length - 1];
    setRedoStack(prev => [maskStrokes, ...prev]);
    setUndoStack(prev => prev.slice(0, -1));
    setMaskStrokes(previousState);
  };

  const handleRedo = () => {
    if (redoStack.length === 0) return;
    
    const nextState = redoStack[0];
    setUndoStack(prev => [...prev, maskStrokes]);
    setRedoStack(prev => prev.slice(1));
    setMaskStrokes(nextState);
  };

  const handleProcessCleanup = async () => {
    if (maskStrokes.length === 0) return;
    
    setProcessingState('processing');
    
    try {
      // Create mask data from strokes
      const canvas = canvasRef.current;
      const image = imageRef.current;
      if (!canvas || !image) return;
      
      // Create mask canvas at the same resolution as the original image
      const maskCanvas = document.createElement('canvas');
      maskCanvas.width = image.naturalWidth;
      maskCanvas.height = image.naturalHeight;
      const maskCtx = maskCanvas.getContext('2d');
      
      if (!maskCtx) return;
      
      // Calculate scale factors
      const scaleX = image.naturalWidth / canvas.width;
      const scaleY = image.naturalHeight / canvas.height;
      
      // Fill with black background
      maskCtx.fillStyle = 'black';
      maskCtx.fillRect(0, 0, maskCanvas.width, maskCanvas.height);
      
      // Draw white strokes for mask (scaled to original image size)
      maskCtx.globalCompositeOperation = 'source-over';
      maskCtx.fillStyle = 'white';
      maskCtx.strokeStyle = 'white';
      maskCtx.lineCap = 'round';
      maskCtx.lineJoin = 'round';
      
      maskStrokes.forEach(stroke => {
        const scaledBrushSize = stroke.brushSize * Math.max(scaleX, scaleY);
        maskCtx.lineWidth = scaledBrushSize;
        
        if (stroke.points.length === 1) {
          // Single point - draw a filled circle
          const scaledX = stroke.points[0].x * scaleX;
          const scaledY = stroke.points[0].y * scaleY;
          maskCtx.beginPath();
          maskCtx.arc(scaledX, scaledY, scaledBrushSize / 2, 0, Math.PI * 2);
          maskCtx.fill();
        } else {
          // Multiple points - draw smooth line
          maskCtx.beginPath();
          const scaledStartX = stroke.points[0].x * scaleX;
          const scaledStartY = stroke.points[0].y * scaleY;
          maskCtx.moveTo(scaledStartX, scaledStartY);
          
          for (let i = 1; i < stroke.points.length; i++) {
            const scaledX = stroke.points[i].x * scaleX;
            const scaledY = stroke.points[i].y * scaleY;
            maskCtx.lineTo(scaledX, scaledY);
          }
          maskCtx.stroke();
        }
      });
      
      // Convert original image to blob
      const originalCanvas = document.createElement('canvas');
      originalCanvas.width = image.naturalWidth;
      originalCanvas.height = image.naturalHeight;
      const originalCtx = originalCanvas.getContext('2d');
      
      if (!originalCtx) return;
      
      originalCtx.drawImage(image, 0, 0);
      
      originalCanvas.toBlob(async (imageBlob) => {
        if (!imageBlob) return;
        
        maskCanvas.toBlob(async (maskBlob) => {
          if (!maskBlob) return;
          
          try {
            // Send to actual cleanup API
            const formData = new FormData();
            formData.append('image', imageBlob);
            formData.append('mask', maskBlob);
            
            const response = await fetch('/api/cleanup', {
              method: 'POST',
              body: formData,
            });
            
            if (!response.ok) {
              throw new Error(`Cleanup failed: ${response.status}`);
            }
            
            const processedBlob = await response.blob();
            const processedUrl = URL.createObjectURL(processedBlob);
            
            setProcessedImageUrl(processedUrl);
            setProcessingState('completed');
            
            if (onMaskComplete) {
              const imageData = maskCtx.getImageData(0, 0, maskCanvas.width, maskCanvas.height);
              onMaskComplete(imageData);
            }
            
          } catch (error) {
            console.error('Cleanup API failed:', error);
            setProcessingState('idle');
            // You could add toast notification here
          }
        }, 'image/png');
      }, 'image/png');
      
    } catch (error) {
      console.error('Processing failed:', error);
      setProcessingState('idle');
    }
  };

  const handleReset = () => {
    setMaskStrokes([]);
    setCurrentStroke(null);
    setUndoStack([]);
    setRedoStack([]);
    setProcessingState('idle');
    setProcessedImageUrl('');
    redrawCanvas();
  };

  const handleFeedback = (positive: boolean) => {
    console.log('Feedback:', positive ? 'positive' : 'negative');
    // Handle feedback logic here
  };

  const handleSave = async () => {
    // Convert processed result to blob and call onDone
    if (processedImageUrl) {
      try {
        const response = await fetch(processedImageUrl);
        const blob = await response.blob();
        onDone(blob);
      } catch (error) {
        console.error('Save failed:', error);
      }
    }
  };

  useEffect(() => {
    redrawCanvas();
  }, [redrawCanvas]);

  return (
    <div className={cn("h-screen bg-black flex flex-col", className)}>
      {/* Header */}
      <div className="flex items-center justify-between p-4 bg-black text-white">
        <Button
          variant="ghost"
          size="sm"
          onClick={onCancel}
          className="text-blue-400 hover:text-blue-300"
        >
          Cancel
        </Button>
        
        <div className="flex items-center space-x-4">
          {processingState === 'completed' && (
            <>
              <Button
                variant="ghost"
                size="sm"
                className="text-white hover:text-gray-300"
              >
                <Share className="w-4 h-4 mr-2" />
                Share
              </Button>
              <Button
                variant="ghost"
                size="sm"
                onClick={handleSave}
                className="text-blue-400 hover:text-blue-300 font-medium"
              >
                Done
              </Button>
            </>
          )}
          
          {processingState === 'selecting' && (
            <Button
              variant="ghost"
              size="sm"
              onClick={handleProcessCleanup}
              className="text-blue-400 hover:text-blue-300 font-medium"
              disabled={maskStrokes.length === 0}
            >
              Clean Up
            </Button>
          )}
        </div>
      </div>

      {/* Image Container */}
      <div 
        ref={containerRef}
        className="flex-1 relative overflow-hidden bg-black flex items-center justify-center"
      >
        <img
          ref={imageRef}
          src={imageUrl}
          alt="Original"
          className="max-w-full max-h-full object-contain"
          style={{ display: processingState === 'completed' ? 'none' : 'block' }}
        />
        
        {processingState === 'completed' && processedImageUrl && (
          <img
            src={processedImageUrl}
            alt="Processed"
            className="max-w-full max-h-full object-contain"
          />
        )}
        
        {selectedTool === 'cleanup' && processingState !== 'completed' && (
          <canvas
            ref={canvasRef}
            className="absolute inset-0 cursor-crosshair mask-canvas"
            onPointerDown={handlePointerDown}
            onPointerMove={handlePointerMove}
            onPointerUp={handlePointerUp}
            onPointerLeave={handlePointerUp}
            style={{ touchAction: 'none' }}
          />
        )}

        {/* Processing Overlay */}
        {processingState === 'processing' && (
          <div className="absolute inset-0 bg-black bg-opacity-20 flex items-center justify-center">
            <div className="bg-black bg-opacity-75 rounded-lg p-6 text-white text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-400 mx-auto mb-4"></div>
              <p className="text-sm">Processing with AI...</p>
            </div>
          </div>
        )}

        {/* Instruction Text */}
        {selectedTool === 'cleanup' && processingState === 'idle' && maskStrokes.length === 0 && (
          <div className="absolute bottom-20 left-1/2 transform -translate-x-1/2 text-white text-center">
            <p className="text-sm opacity-75">Tap, brush, or circle what you want to remove.</p>
            <p className="text-xs opacity-50 mt-1">Pinch to pan and zoom.</p>
          </div>
        )}
      </div>

      {/* Bottom Tools */}
      <div className="bg-black text-white p-4">
        {/* Editing Tools */}
        <div className="flex items-center justify-center space-x-6 mb-4">
          {tools.map((tool) => (
            <button
              key={tool.id}
              onClick={() => setSelectedTool(tool.id)}
              className={cn(
                "flex flex-col items-center space-y-1 text-xs font-medium transition-colors",
                selectedTool === tool.id
                  ? "text-yellow-400"
                  : "text-gray-400 hover:text-white"
              )}
            >
              {tool.icon && (
                <div className="w-6 h-6 flex items-center justify-center">
                  {tool.icon}
                </div>
              )}
              <span>{tool.label}</span>
            </button>
          ))}
        </div>

        {/* Cleanup Controls */}
        {selectedTool === 'cleanup' && (
          <>
            <Separator className="bg-gray-700 my-4" />
            
            <div className="flex items-center justify-between">
              {/* Left side - Undo/Redo */}
              <div className="flex items-center space-x-4">
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={handleUndo}
                  disabled={undoStack.length === 0}
                  className="text-gray-400 hover:text-white disabled:opacity-30"
                >
                  <Undo2 className="w-5 h-5" />
                </Button>
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={handleRedo}
                  disabled={redoStack.length === 0}
                  className="text-gray-400 hover:text-white disabled:opacity-30"
                >
                  <Redo2 className="w-5 h-5" />
                </Button>
                
                {maskStrokes.length > 0 && (
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={handleReset}
                    className="text-gray-400 hover:text-white"
                  >
                    <X className="w-4 h-4 mr-1" />
                    Reset
                  </Button>
                )}
              </div>

              {/* Right side - Feedback */}
              {processingState === 'completed' && (
                <div className="flex items-center space-x-2">
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => handleFeedback(true)}
                    className="text-gray-400 hover:text-green-400"
                  >
                    <ThumbsUp className="w-5 h-5" />
                  </Button>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => handleFeedback(false)}
                    className="text-gray-400 hover:text-red-400"
                  >
                    <ThumbsDown className="w-5 h-5" />
                  </Button>
                </div>
              )}
            </div>
          </>
        )}
      </div>
    </div>
  );
}