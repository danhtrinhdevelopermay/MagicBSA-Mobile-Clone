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
  late Animation<double> _pulseAnimation;
  late Animation<double> _overlayAnimation;
  
  // Processing state
  bool isProcessing = false;
  bool hasResult = false;
  
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
    
    _processingController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _processingController.dispose();
    _overlayController.dispose();
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
                child: Image.memory(
                  hasResult && provider.processedImage != null 
                    ? provider.processedImage!
                    : provider.originalImage!.readAsBytesSync(),
                  fit: BoxFit.contain,
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
          maskPoints.add(details.localPosition);
        });
      },
      onPanUpdate: (details) {
        if (isDrawing) {
          setState(() {
            maskPoints.add(details.localPosition);
          });
        }
      },
      onPanEnd: (details) {
        setState(() {
          isDrawing = false;
        });
      },
      onTapDown: (details) {
        setState(() {
          showInstructions = false;
          // Add a small circle for tap
          maskPoints.addAll(_createCircle(details.localPosition, 24));
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
      animation: _pulseAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ProcessingOverlayPainter(
            maskPoints, 
            _pulseAnimation.value,
            _overlayAnimation.value,
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
    if (maskPoints.isEmpty) return;
    
    setState(() {
      isProcessing = true;
      currentStep = 3;
    });
    
    _overlayController.forward();
    
    // Call the actual cleanup API
    final provider = Provider.of<ImageEditProvider>(context, listen: false);
    
    try {
      // Convert mask points to image data
      final maskData = await _createMaskImage();
      await provider.cleanupWithMask(maskData);
      
      // Simulate processing time for smooth UX
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        isProcessing = false;
        hasResult = true;
        currentStep = 4;
      });
      
      _overlayController.reverse();
      
    } catch (e) {
      setState(() {
        isProcessing = false;
        currentStep = 2;
      });
      
      _overlayController.reverse();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to process image. Please try again.'),
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
    // Create a mask image from the drawn points
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    // Draw the mask
    for (int i = 0; i < maskPoints.length - 1; i++) {
      canvas.drawLine(maskPoints[i], maskPoints[i + 1], paint);
    }
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(400, 400);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }
  
  List<Offset> _createCircle(Offset center, double radius) {
    List<Offset> points = [];
    for (int i = 0; i < 360; i += 10) {
      final angle = i * 3.14159 / 180;
      points.add(Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      ));
    }
    return points;
  }
}

class MaskPainter extends CustomPainter {
  final List<Offset> points;
  
  MaskPainter(this.points);
  
  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ProcessingOverlayPainter extends CustomPainter {
  final List<Offset> maskPoints;
  final double pulseValue;
  final double overlayValue;
  
  ProcessingOverlayPainter(this.maskPoints, this.pulseValue, this.overlayValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    if (maskPoints.isEmpty) return;
    
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.6 * overlayValue * pulseValue)
      ..strokeWidth = 32
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < maskPoints.length - 1; i++) {
      canvas.drawLine(maskPoints[i], maskPoints[i + 1], paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}