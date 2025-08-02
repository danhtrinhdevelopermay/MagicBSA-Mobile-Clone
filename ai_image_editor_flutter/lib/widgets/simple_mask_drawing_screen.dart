import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../services/clipdrop_service.dart';

// Simple mask painter without complex animations
class SimpleMaskPainter extends CustomPainter {
  final ui.Image originalImage;
  final List<Offset> maskPoints;
  final double brushSize;

  SimpleMaskPainter({
    required this.originalImage,
    required this.maskPoints,
    required this.brushSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate aspect ratio and positioning
    final imageAspectRatio = originalImage.width / originalImage.height;
    final canvasAspectRatio = size.width / size.height;

    double displayWidth, displayHeight, offsetX, offsetY;

    if (imageAspectRatio > canvasAspectRatio) {
      displayWidth = size.width;
      displayHeight = displayWidth / imageAspectRatio;
      offsetX = 0;
      offsetY = (size.height - displayHeight) / 2;
    } else {
      displayHeight = size.height;
      displayWidth = displayHeight * imageAspectRatio;
      offsetY = 0;
      offsetX = (size.width - displayWidth) / 2;
    }

    // Draw the original image
    final imageRect = Rect.fromLTWH(offsetX, offsetY, displayWidth, displayHeight);
    final srcRect = Rect.fromLTWH(0, 0, originalImage.width.toDouble(), originalImage.height.toDouble());
    
    final imagePaint = Paint()
      ..filterQuality = FilterQuality.high;
    canvas.drawImageRect(originalImage, srcRect, imageRect, imagePaint);

    // Draw mask points - Apple Photos style (white semi-transparent)
    final maskPaint = Paint()
      ..color = Colors.white.withOpacity(0.9) // White like Apple Photos
      ..style = PaintingStyle.fill;

    for (final point in maskPoints) {
      canvas.drawCircle(point, brushSize / 2, maskPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SimpleMaskDrawingScreen extends StatefulWidget {
  final File originalImage;
  final ProcessingOperation operation;

  const SimpleMaskDrawingScreen({
    super.key,
    required this.originalImage,
    required this.operation,
  });

  @override
  State<SimpleMaskDrawingScreen> createState() => _SimpleMaskDrawingScreenState();
}

class _SimpleMaskDrawingScreenState extends State<SimpleMaskDrawingScreen> {
  List<Offset> _maskPoints = [];
  double _brushSize = 24.0; // Apple Photos fixed brush size
  ui.Image? _originalImageUI;
  bool _imageLoaded = false;
  bool _isProcessing = false;
  final GlobalKey _drawingAreaKey = GlobalKey();
  Size? _drawingAreaSize;
  bool _showInstructions = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateDrawingAreaSize());
  }

  Future<void> _loadImage() async {
    try {
      print('🖼️ Loading image...');
      final bytes = await widget.originalImage.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      
      setState(() {
        _originalImageUI = frame.image;
        _imageLoaded = true;
      });
      print('✅ Image loaded: ${frame.image.width}x${frame.image.height}');
      // Update drawing area size after image is loaded
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateDrawingAreaSize());
    } catch (e) {
      print('❌ Error loading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải ảnh: $e')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  void _addMaskPoint(Offset point) {
    setState(() {
      _maskPoints.add(point);
      if (_showInstructions) {
        _showInstructions = false; // Hide instructions after first draw
      }
    });
    HapticFeedback.lightImpact(); // Add haptic feedback
  }

  void _updateDrawingAreaSize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox = _drawingAreaKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        _drawingAreaSize = renderBox.size;
        print('📐 Drawing area size: ${_drawingAreaSize!.width}x${_drawingAreaSize!.height}');
      }
    });
  }

  void _clearMask() {
    setState(() {
      _maskPoints.clear();
      _showInstructions = true; // Show instructions again after reset
    });
  }

  Future<void> _processMask() async {
    if (_maskPoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng vẽ vùng cần xóa')),
      );
      return;
    }

    // Ensure drawing area size is available before processing
    if (_drawingAreaSize == null) {
      _updateDrawingAreaSize();
      await Future.delayed(const Duration(milliseconds: 100)); // Wait for size update
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create mask image with accurate coordinate mapping
      final maskBytes = await _createMaskFile();
      
      // Save mask to temporary file
      final tempDir = await getTemporaryDirectory();
      final maskFile = File('${tempDir.path}/mask_${DateTime.now().millisecondsSinceEpoch}.png');
      await maskFile.writeAsBytes(maskBytes);
      
      // Process with ClipDrop API
      final clipDropService = ClipDropService();
      final result = await clipDropService.cleanup(
        widget.originalImage,
        maskFile,
        mode: 'fast',
      );

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      print('❌ Error processing mask: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xử lý: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<Uint8List> _createMaskFile() async {
    if (_originalImageUI == null || _maskPoints.isEmpty) {
      throw Exception('Original image not loaded or no mask points');
    }

    if (_drawingAreaSize == null) {
      throw Exception('Drawing area size not available');
    }

    print('🎨 Creating mask file...');
    print('📏 Original image: ${_originalImageUI!.width}x${_originalImageUI!.height}');
    print('📐 Drawing area: ${_drawingAreaSize!.width}x${_drawingAreaSize!.height}');
    print('🔍 Mask points: ${_maskPoints.length}');

    // Create mask image with same dimensions as original
    final maskImage = img.Image(
      width: _originalImageUI!.width,
      height: _originalImageUI!.height,
    );
    
    // Fill with black (keep areas)
    img.fill(maskImage, color: img.ColorRgb8(0, 0, 0));

    // Use REAL drawing area size for accurate coordinate mapping
    final imageAspectRatio = _originalImageUI!.width / _originalImageUI!.height;
    final canvasWidth = _drawingAreaSize!.width;
    final canvasHeight = _drawingAreaSize!.height;
    final canvasAspectRatio = canvasWidth / canvasHeight;

    double displayWidth, displayHeight, offsetX, offsetY;
    
    if (imageAspectRatio > canvasAspectRatio) {
      displayWidth = canvasWidth;
      displayHeight = displayWidth / imageAspectRatio;
      offsetX = 0;
      offsetY = (canvasHeight - displayHeight) / 2;
    } else {
      displayHeight = canvasHeight;
      displayWidth = displayHeight * imageAspectRatio;
      offsetY = 0;
      offsetX = (canvasWidth - displayWidth) / 2;
    }

    print('🎯 Coordinate mapping info:');
    print('   Canvas: ${canvasWidth}x${canvasHeight}');
    print('   Display: ${displayWidth}x${displayHeight}');
    print('   Offset: (${offsetX}, ${offsetY})');
    print('   Scale: ${_originalImageUI!.width / displayWidth}, ${_originalImageUI!.height / displayHeight}');

    // Convert screen coordinates to image coordinates and draw white circles
    for (int i = 0; i < _maskPoints.length; i++) {
      final point = _maskPoints[i];
      
      // Adjust for image display offset
      final adjustedX = point.dx - offsetX;
      final adjustedY = point.dy - offsetY;
      
      // Skip points outside the image area
      if (adjustedX < 0 || adjustedY < 0 || adjustedX >= displayWidth || adjustedY >= displayHeight) {
        print('⚠️ Point $i (${point.dx}, ${point.dy}) -> (${adjustedX}, ${adjustedY}) SKIPPED (outside image area)');
        continue;
      }
      
      // Map to original image coordinates
      final imageX = (adjustedX * _originalImageUI!.width / displayWidth).round();
      final imageY = (adjustedY * _originalImageUI!.height / displayHeight).round();
      
      // Ensure coordinates are within image bounds
      final safeX = imageX.clamp(0, _originalImageUI!.width - 1);
      final safeY = imageY.clamp(0, _originalImageUI!.height - 1);
      
      print('✅ Point $i: Screen(${point.dx.toStringAsFixed(1)}, ${point.dy.toStringAsFixed(1)}) -> Adjusted(${adjustedX.toStringAsFixed(1)}, ${adjustedY.toStringAsFixed(1)}) -> Image($safeX, $safeY)');
      
      img.fillCircle(
        maskImage,
        x: safeX,
        y: safeY,
        radius: (_brushSize * _originalImageUI!.width / displayWidth / 2).round().clamp(1, 20),
        color: img.ColorRgb8(255, 255, 255), // White = remove
      );
    }

    final pngBytes = img.encodePng(maskImage);
    print('✅ Mask created: ${pngBytes.length} bytes');
    return Uint8List.fromList(pngBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Full black like Apple Photos
      body: SafeArea(
        child: Column(
          children: [
            // Apple Photos style header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cancel button
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  
                  // Reset button - center like Apple Photos
                  if (_maskPoints.isNotEmpty && !_isProcessing)
                    TextButton(
                      onPressed: _clearMask,
                      child: const Text(
                        'RESET',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  
                  // Clean Up button
                  if (_maskPoints.isNotEmpty && !_isProcessing)
                    TextButton(
                      onPressed: _processMask,
                      child: const Text(
                        'Clean Up',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 70), // Maintain spacing
                ],
              ),
            ),
            
            // Main drawing area - full screen
            Expanded(
              child: Stack(
                children: [
                  // Image and drawing area - full screen like Apple Photos
                  _imageLoaded && _originalImageUI != null
                      ? GestureDetector(
                          onTapDown: (details) {
                            if (!_isProcessing) {
                              _addMaskPoint(details.localPosition);
                            }
                          },
                          onPanUpdate: (details) {
                            if (!_isProcessing) {
                              _addMaskPoint(details.localPosition);
                            }
                          },
                          child: CustomPaint(
                            key: _drawingAreaKey,
                            painter: SimpleMaskPainter(
                              originalImage: _originalImageUI!,
                              maskPoints: _maskPoints,
                              brushSize: _brushSize,
                            ),
                            size: Size.infinite,
                          ),
                        )
                      : const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Colors.blue),
                              SizedBox(height: 16),
                              Text(
                                'Loading...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                  
                  // Apple Photos style instruction overlay
                  if (_showInstructions && _imageLoaded && !_isProcessing)
                    Positioned(
                      bottom: 120,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Tap, brush, or circle what you want to remove.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Pinch to pan and zoom.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                  // Processing overlay - Apple Photos style
                  if (_isProcessing)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: Container(
                          padding: EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: CircularProgressIndicator(
                                  color: Colors.blue,
                                  strokeWidth: 3,
                                ),
                              ),
                              SizedBox(height: 24),
                              Text(
                                'Cleaning up...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'AI is removing the selected object',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}