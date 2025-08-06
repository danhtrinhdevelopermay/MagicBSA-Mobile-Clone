import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/image_provider.dart';
import '../services/clipdrop_service.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class ApplePhotosCleanupScreen extends StatefulWidget {
  const ApplePhotosCleanupScreen({super.key});

  @override
  State<ApplePhotosCleanupScreen> createState() => _ApplePhotosCleanupScreenState();
}

class _ApplePhotosCleanupScreenState extends State<ApplePhotosCleanupScreen>
    with TickerProviderStateMixin {
  
  // Current step: 1 = editing tools, 2 = cleanup mode, 3 = processing, 4 = result
  int currentStep = 1;
  
  // Drawing state
  List<Offset> maskPoints = [];
  bool isDrawing = false;
  bool showInstructions = true;
  
  // Animation controllers
  late AnimationController _processingController;
  late AnimationController _overlayController;
  late AnimationController _gradientController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _overlayAnimation;
  late Animation<double> _gradientAnimation;
  late Animation<double> _waveAnimation;
  
  // Processing state
  bool isProcessing = false;
  bool hasResult = false;
  
  // Image sizing for accurate mask generation
  Size _imageDisplaySize = const Size(400, 400);
  Size _originalImageSize = const Size(400, 400);
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }
  
  void _setupAnimations() {
    _processingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Gradient animation for smooth pastel color movement
    _gradientController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // Wave animation for AirDrop-style ripple effect
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _processingController,
      curve: Curves.easeInOut,
    ));
    
    _overlayAnimation = Tween<double>(
      begin: 0.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeInOut,
    ));
    
    // Gradient animation for horizontal/swirl movement
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.linear,
    ));
    
    // Wave animation for ripple effect
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeOut,
    ));
    
    _processingController.repeat(reverse: true);
    // Gradient và wave animations sẽ bắt đầu khi có processing
  }
  
  @override
  void dispose() {
    _processingController.dispose();
    _overlayController.dispose();
    _gradientController.dispose();
    _waveController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _buildImageArea(),
                ),
                if (currentStep == 1) _buildEditingToolsBar(),
                if (currentStep == 2) _buildCleanupControls(),
                if (currentStep == 4) _buildResultControls(),
              ],
            ),
            
            // Processing overlay
            if (isProcessing) _buildProcessingOverlay(),
            
            // Instructions overlay
            if (currentStep == 2 && showInstructions) _buildInstructionsOverlay(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          
          // Center buttons based on step
          if (currentStep == 2) ...[
            TextButton(
              onPressed: _resetMask,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'RESET',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          
          // Done/Clean Up button
          TextButton(
            onPressed: currentStep == 2 ? _startCleanup : _saveResult,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: currentStep == 2 ? Colors.orange : Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                currentStep == 2 ? 'Clean Up' : 'Done',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImageArea() {
    return Consumer<ImageEditProvider>(
      builder: (context, provider, child) {
        if (provider.originalImage == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Select a photo to start',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap to choose from your gallery',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => _selectImage(),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(0),
          child: Stack(
            children: [
              // Original or result image
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Update display size for accurate mask scaling
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _imageDisplaySize = Size(constraints.maxWidth, constraints.maxHeight);
                      }
                    });
                    
                    return Image.memory(
                      hasResult && provider.processedImage != null 
                        ? provider.processedImage!
                        : provider.originalImage!.readAsBytesSync(),
                      fit: BoxFit.contain,
                    );
                  },
                ),
              ),
              
              // Drawing canvas for step 2
              if (currentStep == 2)
                Positioned.fill(
                  child: _buildDrawingCanvas(),
                ),
              
              // Processing overlay for selected areas
              if (isProcessing && maskPoints.isNotEmpty)
                Positioned.fill(
                  child: _buildMaskOverlay(),
                ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDrawingCanvas() {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          isDrawing = true;
          showInstructions = false;
          // Add starting point
          maskPoints.add(details.localPosition);
        });
      },
      onPanUpdate: (details) {
        if (isDrawing) {
          setState(() {
            // Add interpolated points for smoother lines
            if (maskPoints.isNotEmpty) {
              final lastPoint = maskPoints.last;
              final currentPoint = details.localPosition;
              final distance = (currentPoint - lastPoint).distance;
              
              // Add intermediate points if distance is large (for smooth lines)
              if (distance > 8.0) {
                final steps = (distance / 4.0).ceil();
                for (int i = 1; i <= steps; i++) {
                  final t = i / steps;
                  final interpolatedPoint = Offset.lerp(lastPoint, currentPoint, t)!;
                  maskPoints.add(interpolatedPoint);
                }
              } else {
                maskPoints.add(currentPoint);
              }
            } else {
              maskPoints.add(details.localPosition);
            }
          });
        }
      },
      onPanEnd: (details) {
        setState(() {
          isDrawing = false;
          // Add a final filled circle at the end point for better coverage
          if (maskPoints.isNotEmpty) {
            final lastPoint = maskPoints.last;
            maskPoints.addAll(_createCircle(lastPoint, 12));
          }
        });
      },
      onTapDown: (details) {
        setState(() {
          showInstructions = false;
          // Add a filled circle for tap with better coverage
          maskPoints.addAll(_createCircle(details.localPosition, 30));
        });
      },
      child: CustomPaint(
        painter: MaskPainter(maskPoints),
        size: Size.infinite,
      ),
    );
  }
  
  Widget _buildMaskOverlay() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _gradientAnimation, _waveAnimation]),
      builder: (context, child) {
        return CustomPaint(
          painter: ProcessingOverlayPainter(
            maskPoints, 
            _pulseAnimation.value,
            _overlayAnimation.value,
            _gradientAnimation.value,
            _waveAnimation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
  
  Widget _buildEditingToolsBar() {
    return Container(
      height: 120,
      color: Colors.black,
      child: Column(
        children: [
          // Image thumbnail strip (similar to Apple Photos)
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Consumer<ImageEditProvider>(
              builder: (context, provider, child) {
                if (provider.originalImage == null) return Container();
                
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 10, // Show multiple thumbnails
                  itemBuilder: (context, index) {
                    return Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: index == 5 ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.memory(
                          provider.originalImage!.readAsBytesSync(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Editing tools
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEditingTool('Portrait', Icons.person_outline, false),
              _buildEditingTool('Live', Icons.camera_outlined, false),
              _buildEditingTool('Adjust', Icons.tune, false),
              _buildEditingTool('Filters', Icons.filter_vintage, false),
              _buildEditingTool('Crop', Icons.crop, false),
              _buildEditingTool('Clean Up', Icons.auto_fix_high, true),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildEditingTool(String title, IconData icon, bool isCleanup) {
    return GestureDetector(
      onTap: () {
        if (isCleanup) {
          setState(() {
            currentStep = 2;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCleanup ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: isCleanup ? Colors.black : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: isCleanup ? Colors.white : Colors.grey,
              fontSize: 12,
              fontWeight: isCleanup ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCleanupControls() {
    return Container(
      height: 80,
      color: Colors.black,
      child: const Center(
        child: Text(
          'Tap, brush, or circle what you want to remove',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
  
  Widget _buildResultControls() {
    return Container(
      height: 80,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFeedbackButton(Icons.thumb_down_outlined, false),
          const SizedBox(width: 40),
          _buildFeedbackButton(Icons.thumb_up_outlined, true),
        ],
      ),
    );
  }
  
  Widget _buildFeedbackButton(IconData icon, bool isPositive) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Handle feedback
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
  
  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Cleaning up...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInstructionsOverlay() {
    return Positioned(
      bottom: 200,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Text(
            'Tap, brush, or circle what you want to remove',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
  
  void _resetMask() {
    setState(() {
      maskPoints.clear();
      showInstructions = true;
    });
  }
  
  void _startCleanup() async {
    if (maskPoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng vẽ mask trên đối tượng cần xóa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      isProcessing = true;
      currentStep = 3;
    });
    
    // Start all animations for the enhanced processing effect
    _overlayController.forward();
    _gradientController.repeat();
    _waveController.repeat();
    
    // Call the actual cleanup API
    final provider = Provider.of<ImageEditProvider>(context, listen: false);
    
    try {
      // Convert mask points to image data with improved scaling
      final maskData = await _createMaskImage();
      
      // Debug info
      print('🎨 Mask created: ${maskData.length} bytes, ${maskPoints.length} mask points');
      print('📱 Original image: ${provider.originalImage?.path}');
      
      await provider.cleanupWithMask(maskData);
      
      // Simulate processing time for smooth UX
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        isProcessing = false;
        hasResult = true;
        currentStep = 4;
      });
      
      // Stop all animations with fade out effect
      _overlayController.reverse();
      _gradientController.stop();
      _waveController.stop();
      
      print('✅ Cleanup completed successfully');
      
    } catch (e) {
      print('❌ Cleanup failed: $e');
      
      setState(() {
        isProcessing = false;
        currentStep = 2;
      });
      
      // Stop animations on error
      _overlayController.reverse();
      _gradientController.stop();
      _waveController.stop();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xử lý ảnh: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _saveResult() {
    Navigator.pop(context);
  }

  void _selectImage() async {
    final provider = Provider.of<ImageEditProvider>(context, listen: false);
    await provider.pickImage(ImageSource.gallery);
    
    // Once image is selected, move to step 1 (editing tools)
    if (provider.originalImage != null) {
      setState(() {
        currentStep = 1;
      });
    }
  }
  
  Future<Uint8List> _createMaskImage() async {
    final provider = Provider.of<ImageEditProvider>(context, listen: false);
    if (provider.originalImage == null) {
      throw Exception('No original image available');
    }
    
    // Get original image dimensions
    final imageBytes = await provider.originalImage!.readAsBytes();
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frameInfo = await codec.getNextFrame();
    final originalImage = frameInfo.image;
    
    final imageWidth = originalImage.width;
    final imageHeight = originalImage.height;
    
    // Store original image size for future use
    _originalImageSize = Size(imageWidth.toDouble(), imageHeight.toDouble());
    
    // Calculate actual display size considering aspect ratio and BoxFit.contain
    final imageAspectRatio = imageWidth / imageHeight;
    final displayAspectRatio = _imageDisplaySize.width / _imageDisplaySize.height;
    
    Size actualDisplaySize;
    if (imageAspectRatio > displayAspectRatio) {
      // Image is wider - fit to width
      actualDisplaySize = Size(
        _imageDisplaySize.width,
        _imageDisplaySize.width / imageAspectRatio,
      );
    } else {
      // Image is taller - fit to height
      actualDisplaySize = Size(
        _imageDisplaySize.height * imageAspectRatio,
        _imageDisplaySize.height,
      );
    }
    
    // Calculate offset for centering
    final offsetX = (_imageDisplaySize.width - actualDisplaySize.width) / 2;
    final offsetY = (_imageDisplaySize.height - actualDisplaySize.height) / 2;
    
    // Calculate scale factors
    final scaleX = imageWidth / actualDisplaySize.width;
    final scaleY = imageHeight / actualDisplaySize.height;
    
    // Create mask with original image dimensions
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Fill with black background first
    canvas.drawRect(
      Rect.fromLTWH(0, 0, imageWidth.toDouble(), imageHeight.toDouble()),
      Paint()..color = Colors.black,
    );
    
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = math.max(24.0 * scaleX, 10.0) // Scale brush size with image
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    // Draw the mask with scaled and offset coordinates
    for (int i = 0; i < maskPoints.length - 1; i++) {
      final adjustedStart = Offset(
        (maskPoints[i].dx - offsetX) * scaleX,
        (maskPoints[i].dy - offsetY) * scaleY,
      );
      final adjustedEnd = Offset(
        (maskPoints[i + 1].dx - offsetX) * scaleX,
        (maskPoints[i + 1].dy - offsetY) * scaleY,
      );
      
      // Only draw if points are within image bounds
      if (_isPointInBounds(adjustedStart, imageWidth, imageHeight) && 
          _isPointInBounds(adjustedEnd, imageWidth, imageHeight)) {
        canvas.drawLine(adjustedStart, adjustedEnd, paint);
      }
    }
    
    // Also draw circles for tap points to ensure coverage
    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    for (final point in maskPoints) {
      final adjustedPoint = Offset(
        (point.dx - offsetX) * scaleX,
        (point.dy - offsetY) * scaleY,
      );
      
      if (_isPointInBounds(adjustedPoint, imageWidth, imageHeight)) {
        canvas.drawCircle(adjustedPoint, math.max(15.0 * math.min(scaleX, scaleY), 8.0), circlePaint);
      }
    }
    
    final picture = recorder.endRecording();
    final maskImage = await picture.toImage(imageWidth, imageHeight);
    final byteData = await maskImage.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }
  
  List<Offset> _createCircle(Offset center, double radius) {
    List<Offset> points = [];
    // Create denser circle for better coverage
    for (int i = 0; i < 360; i += 5) {
      final angle = i * 3.14159 / 180;
      points.add(Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      ));
    }
    return points;
  }
  
  bool _isPointInBounds(Offset point, int imageWidth, int imageHeight) {
    return point.dx >= 0 && 
           point.dx <= imageWidth && 
           point.dy >= 0 && 
           point.dy <= imageHeight;
  }
}

class MaskPainter extends CustomPainter {
  final List<Offset> points;
  
  MaskPainter(this.points);
  
  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    
    // Draw filled circles for each point to ensure solid coverage
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    for (final point in points) {
      canvas.drawCircle(point, 12, circlePaint);
    }
    
    // Draw connecting lines for continuous strokes
    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], strokePaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ProcessingOverlayPainter extends CustomPainter {
  final List<Offset> maskPoints;
  final double pulseValue;
  final double overlayValue;
  final double gradientValue;
  final double waveValue;
  
  ProcessingOverlayPainter(
    this.maskPoints, 
    this.pulseValue, 
    this.overlayValue, 
    this.gradientValue, 
    this.waveValue
  );
  
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
    
    // Create moving gradient
    final gradientCenter = Offset(
      centerX + math.sin(gradientValue * 2 * math.pi) * 30,
      centerY + math.cos(gradientValue * 2 * math.pi) * 20,
    );
    
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: gradientColors.map((color) => 
          color.withOpacity(0.4 * overlayValue * pulseValue)
        ).toList(),
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(
        center: gradientCenter,
        radius: maskRadius * 1.5,
      ));
    
    // Draw mask area with animated gradient
    for (final point in maskPoints) {
      canvas.drawCircle(point, 20, gradientPaint);
    }
    
    // Draw ripple wave effects (AirDrop style)
    if (waveValue > 0.1) {
      final waveCount = 3;
      for (int i = 0; i < waveCount; i++) {
        final waveOffset = i * 0.3;
        final currentWave = (waveValue + waveOffset) % 1.0;
        
        if (currentWave > 0.1) {
          final waveRadius = maskRadius * (0.5 + currentWave * 2.0);
          final waveOpacity = (1.0 - currentWave) * 0.3 * overlayValue;
          
          final wavePaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0 * (1.0 - currentWave)
            ..color = const Color(0xFFFFFFFF).withOpacity(waveOpacity);
          
          // Draw ripple circles around the mask area
          canvas.drawCircle(
            Offset(centerX, centerY),
            waveRadius,
            wavePaint,
          );
          
          // Add subtle distortion effect
          final distortionPaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0
            ..color = const Color(0xFFE6E6FA).withOpacity(waveOpacity * 0.5);
          
          // Draw smaller inner ripples
          for (int j = 1; j <= 2; j++) {
            canvas.drawCircle(
              Offset(centerX, centerY),
              waveRadius * (0.3 + j * 0.3),
              distortionPaint,
            );
          }
        }
      }
    }
    
    // Draw subtle glow effect around mask points
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFFFFF).withOpacity(0.1 * overlayValue * pulseValue);
    
    for (final point in maskPoints) {
      canvas.drawCircle(point, 35, glowPaint);
    }
    
    // Add scanning line effect
    final scanProgress = gradientValue;
    if (scanProgress > 0.1) {
      final scanY = minY + (maxY - minY) * scanProgress;
      final scanPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFFFFFFFF).withOpacity(0.6 * overlayValue),
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