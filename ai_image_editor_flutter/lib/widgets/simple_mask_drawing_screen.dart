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

    // Draw mask points
    final maskPaint = Paint()
      ..color = Colors.red.withOpacity(0.7)
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
  double _brushSize = 30.0;
  ui.Image? _originalImageUI;
  bool _imageLoaded = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
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
    });
    HapticFeedback.lightImpact(); // Add haptic feedback
  }

  void _clearMask() {
    setState(() {
      _maskPoints.clear();
    });
  }

  Future<void> _processMask() async {
    if (_maskPoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng vẽ vùng cần xóa')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create mask image
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

    print('🎨 Creating mask file...');
    print('📏 Original image: ${_originalImageUI!.width}x${_originalImageUI!.height}');
    print('🔍 Mask points: ${_maskPoints.length}');

    // Create mask image with same dimensions as original
    final maskImage = img.Image(
      width: _originalImageUI!.width,
      height: _originalImageUI!.height,
    );
    
    // Fill with black (keep areas)
    img.fill(maskImage, color: img.ColorRgb8(0, 0, 0));

    // Get the canvas size for proper coordinate mapping
    final imageAspectRatio = _originalImageUI!.width / _originalImageUI!.height;
    
    // Assume typical phone screen proportions for coordinate mapping
    // This is a simplified approach - in a real app you'd get actual canvas dimensions
    const canvasWidth = 400.0;
    const canvasHeight = 600.0;
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

    // Convert screen coordinates to image coordinates and draw white circles
    for (final point in _maskPoints) {
      // Adjust for image display offset
      final adjustedX = point.dx - offsetX;
      final adjustedY = point.dy - offsetY;
      
      // Skip points outside the image area
      if (adjustedX < 0 || adjustedY < 0 || adjustedX >= displayWidth || adjustedY >= displayHeight) {
        continue;
      }
      
      // Map to original image coordinates
      final imageX = (adjustedX * _originalImageUI!.width / displayWidth).round();
      final imageY = (adjustedY * _originalImageUI!.height / displayHeight).round();
      
      // Ensure coordinates are within image bounds
      final safeX = imageX.clamp(0, _originalImageUI!.width - 1);
      final safeY = imageY.clamp(0, _originalImageUI!.height - 1);
      
      img.fillCircle(
        maskImage,
        x: safeX,
        y: safeY,
        radius: (_brushSize * _originalImageUI!.width / displayWidth / 2).round(),
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
      appBar: AppBar(
        title: const Text('Vẽ vùng cần xóa'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          if (_maskPoints.isNotEmpty)
            IconButton(
              onPressed: _clearMask,
              icon: const Icon(Icons.clear),
              tooltip: 'Xóa tất cả',
            ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Drawing area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _imageLoaded && _originalImageUI != null
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
                              'Đang tải ảnh...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          
          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              border: Border(top: BorderSide(color: Colors.white24)),
            ),
            child: Column(
              children: [
                // Brush size
                Row(
                  children: [
                    const Text('Kích thước: ', style: TextStyle(color: Colors.white)),
                    Expanded(
                      child: Slider(
                        value: _brushSize,
                        min: 10,
                        max: 60,
                        divisions: 10,
                        label: _brushSize.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            _brushSize = value;
                          });
                        },
                      ),
                    ),
                    Text('${_brushSize.round()}px', style: const TextStyle(color: Colors.white)),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Process button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processMask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: _isProcessing
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Đang xử lý...'),
                            ],
                          )
                        : const Text(
                            'Xử lý ảnh',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}