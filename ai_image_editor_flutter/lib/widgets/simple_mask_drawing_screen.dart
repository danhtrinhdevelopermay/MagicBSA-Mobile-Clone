import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
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

class _SimpleMaskDrawingScreenState extends State<SimpleMaskDrawingScreen> 
    with TickerProviderStateMixin {
  List<Offset> _maskPoints = [];
  double _brushSize = 24.0; // Apple Photos fixed brush size
  ui.Image? _originalImageUI;
  bool _imageLoaded = false;
  bool _isProcessing = false;
  final GlobalKey _drawingAreaKey = GlobalKey();
  Size? _drawingAreaSize;
  bool _showInstructions = true;
  
  // Animation controllers for enhanced processing effects
  late AnimationController _gradientController;
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late Animation<double> _gradientAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadImage();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateDrawingAreaSize());
  }
  
  void _setupAnimations() {
    // Gradient animation for smooth pastel color movement (3 seconds)
    _gradientController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // Wave animation for AirDrop-style ripple effect (2 seconds)
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Pulse animation for subtle breathing effect (1.5 seconds)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.linear,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _gradientController.dispose();
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
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
    
    // Start enhanced processing animations
    _gradientController.repeat();
    _waveController.repeat();

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
        // Stop animations with fade out effect
        _gradientController.stop();
        _waveController.stop();
        
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
                  
                  // Enhanced processing overlay with gradient and wave effects
                  if (_isProcessing)
                    Stack(
                      children: [
                        // Semi-transparent overlay
                        Container(
                          color: Colors.black.withOpacity(0.3),
                        ),
                        
                        // Gradient and wave effects over mask areas
                        AnimatedBuilder(
                          animation: Listenable.merge([_gradientAnimation, _waveAnimation, _pulseAnimation]),
                          builder: (context, child) {
                            return CustomPaint(
                              painter: EnhancedProcessingPainter(
                                maskPoints: _maskPoints,
                                gradientValue: _gradientAnimation.value,
                                waveValue: _waveAnimation.value,
                                pulseValue: _pulseAnimation.value,
                              ),
                              size: Size.infinite,
                            );
                          },
                        ),
                        
                        // Processing message at bottom
                        Positioned(
                          bottom: 120,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Cleaning up...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced processing painter with gradient and wave effects
class EnhancedProcessingPainter extends CustomPainter {
  final List<Offset> maskPoints;
  final double gradientValue;
  final double waveValue;
  final double pulseValue;
  
  EnhancedProcessingPainter({
    required this.maskPoints,
    required this.gradientValue,
    required this.waveValue,
    required this.pulseValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (maskPoints.isEmpty) return;
    
    // Find the bounding box of mask points
    double minX = maskPoints.first.dx;
    double maxX = maskPoints.first.dx;
    double minY = maskPoints.first.dy;
    double maxY = maskPoints.first.dy;
    
    for (final point in maskPoints) {
      minX = math.min(minX, point.dx);
      maxX = math.max(maxX, point.dx);
      minY = math.min(minY, point.dy);
      maxY = math.max(maxY, point.dy);
    }
    
    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;
    final maskRadius = math.max((maxX - minX) / 2, (maxY - minY) / 2) + 40;
    
    // Create animated gradient with pastel colors
    final gradientColors = [
      Color.lerp(
        const Color(0xFFFFB6C1), // Light pink
        const Color(0xFFE6E6FA), // Lavender
        (math.sin(gradientValue * 2 * math.pi) + 1) / 2,
      )!,
      Color.lerp(
        const Color(0xFFB0E0E6), // Powder blue
        const Color(0xFFF0F8FF), // Alice blue
        (math.sin(gradientValue * 2 * math.pi + math.pi / 2) + 1) / 2,
      )!,
      Color.lerp(
        const Color(0xFFF5F5DC), // Beige
        const Color(0xFFFFE4E1), // Misty rose
        (math.sin(gradientValue * 2 * math.pi + math.pi) + 1) / 2,
      )!,
    ];
    
    // Create moving gradient center
    final gradientCenter = Offset(
      centerX + math.sin(gradientValue * 2 * math.pi) * 30,
      centerY + math.cos(gradientValue * 2 * math.pi) * 20,
    );
    
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: gradientColors.map((color) => 
          color.withOpacity(0.6 * pulseValue)
        ).toList(),
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(
        center: gradientCenter,
        radius: maskRadius * 1.5,
      ));
    
    // Draw mask area with animated gradient
    for (final point in maskPoints) {
      canvas.drawCircle(point, 25, gradientPaint);
    }
    
    // Draw AirDrop-style ripple wave effects
    if (waveValue > 0.1) {
      final waveCount = 3;
      for (int i = 0; i < waveCount; i++) {
        final waveOffset = i * 0.3;
        final currentWave = (waveValue + waveOffset) % 1.0;
        
        if (currentWave > 0.1) {
          final waveRadius = maskRadius * (0.5 + currentWave * 2.5);
          final waveOpacity = (1.0 - currentWave) * 0.4;
          
          final wavePaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0 * (1.0 - currentWave)
            ..color = const Color(0xFFFFFFFF).withOpacity(waveOpacity);
          
          // Draw main ripple circles
          canvas.drawCircle(
            Offset(centerX, centerY),
            waveRadius,
            wavePaint,
          );
          
          // Add subtle inner distortion rings
          final distortionPaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = const Color(0xFFE6E6FA).withOpacity(waveOpacity * 0.6);
          
          // Draw smaller inner ripples
          for (int j = 1; j <= 2; j++) {
            canvas.drawCircle(
              Offset(centerX, centerY),
              waveRadius * (0.3 + j * 0.25),
              distortionPaint,
            );
          }
        }
      }
    }
    
    // Add subtle glow effect around mask points
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFFFFF).withOpacity(0.15 * pulseValue);
    
    for (final point in maskPoints) {
      canvas.drawCircle(point, 40, glowPaint);
    }
    
    // Add horizontal scanning line effect
    final scanProgress = gradientValue;
    if (scanProgress > 0.1 && maskPoints.isNotEmpty) {
      final scanY = minY + (maxY - minY) * scanProgress;
      final scanPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFFFFFFFF).withOpacity(0.8),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(minX - 20, scanY - 10, maxX - minX + 40, 20));
      
      canvas.drawLine(
        Offset(minX - 20, scanY),
        Offset(maxX + 20, scanY),
        scanPaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}