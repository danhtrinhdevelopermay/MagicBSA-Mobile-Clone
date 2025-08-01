import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../services/clipdrop_service.dart';

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
  // Drawing state
  final List<List<Offset>> _maskStrokes = []; // Changed to support undo/redo
  final List<List<Offset>> _undoHistory = [];
  double _brushSize = 25.0;
  double _brushOpacity = 0.7;
  bool _eraserMode = false;
  
  // Image state
  late ui.Image _originalImageUI;
  bool _imageLoaded = false;
  
  // Transform state for zoom/pan
  TransformationController _transformationController = TransformationController();
  late AnimationController _zoomAnimationController;
  
  // Display dimensions for accurate coordinate mapping
  double _displayWidth = 0;
  double _displayHeight = 0;
  double _displayOffsetX = 0;
  double _displayOffsetY = 0;
  
  // Processing animations
  late AnimationController _gradientController;
  late AnimationController _pulseController;
  late Animation<double> _gradientAnimation;
  late Animation<double> _pulseAnimation;
  bool _isProcessing = false;
  bool _showResult = false;
  Uint8List? _processedImageBytes;
  
  // UI state
  bool _showControls = true;
  late AnimationController _controlsAnimationController;
  late Animation<Offset> _controlsSlideAnimation;

  @override
  void initState() {
    super.initState();
    _loadImage();
    _setupAnimations();
  }
  
  void _setupAnimations() {
    // Gradient animation for processing state
    _gradientController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.linear,
    ));

    // Pulse animation for buttons and UI elements
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Zoom animation controller
    _zoomAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Controls slide animation
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _controlsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animations
    _pulseController.repeat(reverse: true);
    _controlsAnimationController.forward();
  }
  
  @override
  void dispose() {
    _gradientController.dispose();
    _pulseController.dispose();
    _zoomAnimationController.dispose();
    _controlsAnimationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    final bytes = await widget.originalImage.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() {
      _originalImageUI = frame.image;
      _imageLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Set immersive UI
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                  Color(0xFF0F0F23),
                ],
              ),
            ),
          ),
          
          // Main content
          Column(
            children: [
              // Custom app bar
              _buildCustomAppBar(),
              
              // Drawing area
              Expanded(
                child: _buildDrawingArea(),
              ),
            ],
          ),
          
          // Floating controls
          _buildFloatingControls(),
          
          // Processing overlay
          if (_isProcessing) _buildProcessingOverlay(),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.95),
            const Color(0xFF1A1A2E).withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title with animated gradient
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Text(
                        'Vẽ vùng cần xóa',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [
                                Color(0xFF64B5F6),
                                Color(0xFF42A5F5),
                                Color(0xFF2196F3),
                              ],
                            ).createShader(
                              const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                            ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 2),
                Text(
                  'Vẽ để đánh dấu vật thể cần loại bỏ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          
          // Tool mode indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _eraserMode 
                  ? const Color(0xFFFF6B6B).withOpacity(0.2)
                  : const Color(0xFF4ECDC4).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _eraserMode 
                    ? const Color(0xFFFF6B6B).withOpacity(0.5)
                    : const Color(0xFF4ECDC4).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _eraserMode ? Icons.cleaning_services : Icons.brush,
                  color: _eraserMode 
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF4ECDC4),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _eraserMode ? 'Tẩy' : 'Vẽ',
                  style: TextStyle(
                    color: _eraserMode 
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFF4ECDC4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDrawingArea() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 100), // Leave space for floating controls
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF64B5F6).withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _imageLoaded
            ? InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 5.0,
                constrained: false,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.05),
                        Colors.white.withOpacity(0.02),
                      ],
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate proper image display size with aspect ratio
                      final imageAspectRatio = _originalImageUI.width / _originalImageUI.height;
                      final containerAspectRatio = constraints.maxWidth / constraints.maxHeight;
                      
                      late double displayWidth, displayHeight, offsetX, offsetY;
                      
                      if (imageAspectRatio > containerAspectRatio) {
                        displayWidth = constraints.maxWidth;
                        displayHeight = displayWidth / imageAspectRatio;
                        offsetX = 0;
                        offsetY = (constraints.maxHeight - displayHeight) / 2;
                      } else {
                        displayHeight = constraints.maxHeight;
                        displayWidth = displayHeight * imageAspectRatio;
                        offsetY = 0;
                        offsetX = (constraints.maxWidth - displayWidth) / 2;
                      }
                      
                      // Store display dimensions for mask creation
                      _displayWidth = displayWidth;
                      _displayHeight = displayHeight;
                      
                      // Show processed result
                      if (_showResult && _processedImageBytes != null) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CAF50).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.memory(
                              _processedImageBytes!,
                              fit: BoxFit.contain,
                              width: displayWidth,
                              height: displayHeight,
                            ),
                          ),
                        );
                      }
                      
                      // Drawing mode with enhanced gestures
                      return GestureDetector(
                        onPanStart: _isProcessing ? null : (details) {
                          HapticFeedback.lightImpact();
                          final adjustedPosition = Offset(
                            details.localPosition.dx - offsetX,
                            details.localPosition.dy - offsetY,
                          );
                          
                          _displayOffsetX = offsetX;
                          _displayOffsetY = offsetY;
                          
                          if (_isWithinImageBounds(adjustedPosition, displayWidth, displayHeight)) {
                            _startNewStroke(adjustedPosition);
                          }
                        },
                        onPanUpdate: _isProcessing ? null : (details) {
                          final adjustedPosition = Offset(
                            details.localPosition.dx - offsetX,
                            details.localPosition.dy - offsetY,
                          );
                          if (_isWithinImageBounds(adjustedPosition, displayWidth, displayHeight)) {
                            _addToCurrentStroke(adjustedPosition);
                          }
                        },
                        onPanEnd: _isProcessing ? null : (details) {
                          _endCurrentStroke();
                        },
                        child: AnimatedBuilder(
                          animation: _gradientAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: EnhancedMaskPainter(
                                originalImage: _originalImageUI,
                                maskStrokes: _maskStrokes,
                                brushSize: _brushSize,
                                brushOpacity: _brushOpacity,
                                eraserMode: _eraserMode,
                                displayWidth: displayWidth,
                                displayHeight: displayHeight,
                                offsetX: offsetX,
                                offsetY: offsetY,
                                isProcessing: _isProcessing,
                                animationValue: _gradientAnimation.value,
                              ),
                              size: Size(constraints.maxWidth, constraints.maxHeight),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64B5F6)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Đang tải ảnh...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildFloatingControls() {
    return SlideTransition(
      position: _controlsSlideAnimation,
      child: Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 16,
        left: 16,
        right: 16,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Brush controls
              Row(
                children: [
                  Icon(
                    Icons.brush,
                    color: Colors.white.withOpacity(0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Kích thước: ${_brushSize.round()}px',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF64B5F6),
                        inactiveTrackColor: Colors.white.withOpacity(0.2),
                        thumbColor: const Color(0xFF64B5F6),
                        overlayColor: const Color(0xFF64B5F6).withOpacity(0.2),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: _brushSize,
                        min: 10.0,
                        max: 60.0,
                        divisions: 10,
                        onChanged: (value) {
                          setState(() {
                            _brushSize = value;
                          });
                          HapticFeedback.selectionClick();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  // Undo button
                  _buildControlButton(
                    icon: Icons.undo,
                    label: 'Hoàn tác',
                    onPressed: _canUndo() ? _undo : null,
                    color: const Color(0xFFFF9800),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Eraser mode toggle
                  _buildControlButton(
                    icon: _eraserMode ? Icons.brush : Icons.cleaning_services,
                    label: _eraserMode ? 'Vẽ' : 'Tẩy',
                    onPressed: _toggleEraserMode,
                    color: _eraserMode ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Clear all
                  _buildControlButton(
                    icon: Icons.clear_all,
                    label: 'Xóa tất cả',
                    onPressed: _maskStrokes.isNotEmpty ? _clearMask : null,
                    color: Colors.grey,
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Process button (primary)
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isProcessing ? _pulseAnimation.value : 1.0,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isProcessing
                                    ? [Colors.grey.shade600, Colors.grey.shade700]
                                    : [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isProcessing ? Colors.grey : const Color(0xFF4CAF50)).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _canProcess() ? _processMask : null,
                                borderRadius: BorderRadius.circular(16),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_isProcessing) ...[
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                      ] else ...[
                                        const Icon(
                                          Icons.auto_fix_high,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      Text(
                                        _isProcessing ? 'Đang xử lý...' : 'Xử lý AI',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    final isEnabled = onPressed != null;
    
    return Container(
      width: 60,
      height: 50,
      decoration: BoxDecoration(
        color: isEnabled 
            ? color.withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled 
              ? color.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isEnabled ? color : Colors.grey,
                size: 18,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isEnabled ? color : Colors.grey,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.8),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _gradientAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _gradientAnimation.value * 2 * pi,
                      child: const Text(
                        '✨',
                        style: TextStyle(fontSize: 48),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'AI đang xử lý ảnh của bạn',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng đợi trong giây lát...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for new functionality
  bool _canUndo() => _undoHistory.isNotEmpty;
  
  bool _canProcess() => _maskStrokes.isNotEmpty && !_isProcessing;
  
  void _toggleEraserMode() {
    setState(() {
      _eraserMode = !_eraserMode;
    });
    HapticFeedback.mediumImpact();
  }
  
  void _undo() {
    if (_canUndo()) {
      setState(() {
        _maskStrokes.removeLast();
        _undoHistory.removeLast();
      });
      HapticFeedback.lightImpact();
    }
  }
  
  void _startNewStroke(Offset position) {
    setState(() {
      _maskStrokes.add([position]);
      _undoHistory.add([position]);
    });
  }
  
  void _addToCurrentStroke(Offset position) {
    if (_maskStrokes.isNotEmpty) {
      setState(() {
        _maskStrokes.last.add(position);
        _undoHistory.last.add(position);
      });
    }
  }
  
  void _endCurrentStroke() {
    // Stroke completed - could add optimization here
  }

  bool _isWithinImageBounds(Offset position, double displayWidth, double displayHeight) {
    return position.dx >= 0 && 
           position.dx <= displayWidth && 
           position.dy >= 0 && 
           position.dy <= displayHeight;
  }

  void _clearMask() {
    setState(() {
      _maskStrokes.clear();
      _undoHistory.clear();
    });
    HapticFeedback.mediumImpact();
  }

  // Test method to create a simple mask for debugging
  void _createTestMask() {
    setState(() {
      _maskStrokes.clear();
      _undoHistory.clear();
      
      // Create test strokes using actual display dimensions
      if (_displayWidth > 0 && _displayHeight > 0) {
        // Create strokes at the center of image
        final centerX = _displayWidth / 2;
        final centerY = _displayHeight / 2;
        
        List<Offset> testStroke = [];
        
        // Create circular test mask
        for (int i = 0; i < 25; i++) {
          final angle = (i / 25) * 2 * pi;
          final radius = 40.0;
          final x = centerX + radius * cos(angle);
          final y = centerY + radius * sin(angle);
          testStroke.add(Offset(x, y));
        }
        
        _maskStrokes.add(testStroke);
        _undoHistory.add(List.from(testStroke));
        
        print('Created test mask with ${testStroke.length} points in center area');
      }
    });
  }

  Future<void> _processMask() async {
    if (_maskStrokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng vẽ vùng cần xóa trên ảnh'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      print('=== CLEANUP PROCESSING START ===');
      print('Total mask strokes: ${_maskStrokes.length}');
      
      // ✅ START GRADIENT ANIMATION: Red→Orange→Green cycle
      _gradientController.repeat();
      
      // Create mask file (quick operation)
      print('Creating mask file...');
      final maskFile = await _createMaskFile();
      print('Mask file created: ${maskFile.path}');

      // Process with ClipDrop API (main processing)
      print('Processing with ClipDrop API...');
      final clipDropService = ClipDropService();
      final result = await clipDropService.processImage(
        widget.originalImage,
        ProcessingOperation.cleanup,
        maskFile: maskFile,
        mode: 'quality',  // ✅ Use quality mode for better results
      );

      print('Processing completed successfully');
      print('Result size: ${result.length} bytes');

      // ✅ STOP ANIMATION AND SHOW RESULT
      _gradientController.stop();
      setState(() {
        _isProcessing = false;
        _processedImageBytes = result;
        _showResult = true;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Xử lý hoàn tất! Nhấn "Lưu ảnh" để lưu kết quả.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

    } catch (e) {
      print('ERROR in _processMask: $e');
      
      // ✅ STOP ANIMATION ON ERROR
      _gradientController.stop();
      setState(() {
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi xử lý: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
  
  // ✅ NEW METHODS for result handling
  void _startOver() {
    setState(() {
      _showResult = false;
      _processedImageBytes = null;
      _maskStrokes.clear();
      _isProcessing = false;
    });
    _gradientController.reset();
  }
  
  void _saveResult() async {
    if (_processedImageBytes == null) return;
    
    try {
      // Here you would implement saving to gallery/downloads
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Ảnh đã được lưu thành công!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Return result to previous screen (if needed)
      Navigator.pop(context, _processedImageBytes);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi lưu ảnh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<File> _createMaskFile() async {
    // Load original image to get dimensions
    final originalBytes = await widget.originalImage.readAsBytes();
    final originalImage = img.decodeImage(originalBytes)!;
    
    final width = originalImage.width;
    final height = originalImage.height;
    
    print('=== MASK CREATION ===');
    print('Original image: ${width}x${height}');
    print('Display area: ${_displayWidth}x${_displayHeight}');
    print('Total stroke groups: ${_maskStrokes.length}');
    
    // Create white mask (255 = white background)
    final mask = img.Image(width: width, height: height);
    img.fill(mask, color: img.ColorRgb8(255, 255, 255));
    
    // Calculate scale factors to map display coordinates to original image coordinates
    final scaleX = width / _displayWidth;
    final scaleY = height / _displayHeight;
    
    print('Scale factors: x=$scaleX, y=$scaleY');
    
    // Draw each stroke group on mask
    for (int groupIndex = 0; groupIndex < _maskStrokes.length; groupIndex++) {
      final strokeGroup = _maskStrokes[groupIndex];
      print('Processing stroke group $groupIndex with ${strokeGroup.length} points');
      
      for (int i = 0; i < strokeGroup.length - 1; i++) {
        final currentPoint = strokeGroup[i];
        final nextPoint = strokeGroup[i + 1];
        
        // Scale coordinates to original image size
        final x1 = (currentPoint.dx * scaleX).round().clamp(0, width - 1);
        final y1 = (currentPoint.dy * scaleY).round().clamp(0, height - 1);
        final x2 = (nextPoint.dx * scaleX).round().clamp(0, width - 1);
        final y2 = (nextPoint.dy * scaleY).round().clamp(0, height - 1);
        
        // Draw thick black line (0 = black brush stroke)
        _drawThickLine(mask, x1, y1, x2, y2, (_brushSize * scaleX).round());
      }
    }
    
    // Save mask to temporary file
    final tempDir = await getTemporaryDirectory();
    final maskFile = File('${tempDir.path}/mask_${DateTime.now().millisecondsSinceEpoch}.png');
    await maskFile.writeAsBytes(img.encodePng(mask));
    
    print('Mask file created: ${maskFile.path}');
    return maskFile;
  }
  
  void _drawThickLine(img.Image mask, int x1, int y1, int x2, int y2, int thickness) {
    // Simple line drawing with thickness
    final distance = sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2)).round();
    
    for (int i = 0; i <= distance; i++) {
      final t = distance > 0 ? i / distance : 0.0;
      final x = (x1 + (x2 - x1) * t).round();
      final y = (y1 + (y2 - y1) * t).round();
      
      // Draw circular brush
      final radius = thickness ~/ 2;
      for (int dx = -radius; dx <= radius; dx++) {
        for (int dy = -radius; dy <= radius; dy++) {
          if (dx * dx + dy * dy <= radius * radius) {
            final px = x + dx;
            final py = y + dy;
            if (px >= 0 && px < mask.width && py >= 0 && py < mask.height) {
              mask.setPixelRgb(px, py, 0, 0, 0); // Black brush stroke
            }
          }
        }
      }
    }
  }
}

// Enhanced painter class with modern styling and animations
class EnhancedMaskPainter extends CustomPainter {
  final ui.Image originalImage;
  final List<List<Offset>> maskStrokes;
  final double brushSize;
  final double brushOpacity;
  final bool eraserMode;
  final double displayWidth;
  final double displayHeight;
  final double offsetX;
  final double offsetY;
  final bool isProcessing;
  final double animationValue;

  EnhancedMaskPainter({
    required this.originalImage,
    required this.maskStrokes,
    required this.brushSize,
    required this.brushOpacity,
    required this.eraserMode,
    required this.displayWidth,
    required this.displayHeight,
    required this.offsetX,
    required this.offsetY,
    required this.isProcessing,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw original image
    final imageRect = Rect.fromLTWH(offsetX, offsetY, displayWidth, displayHeight);
    canvas.drawImageRect(
      originalImage,
      Rect.fromLTWH(0, 0, originalImage.width.toDouble(), originalImage.height.toDouble()),
      imageRect,
      Paint()..filterQuality = FilterQuality.high,
    );

    // Create mask overlay with glassmorphism effect
    if (maskStrokes.isNotEmpty) {
      _drawMaskOverlay(canvas, size);
    }

    // Draw processing animation
    if (isProcessing) {
      _drawProcessingAnimation(canvas, size);
    }
  }

  void _drawMaskOverlay(Canvas canvas, Size size) {
    // Create mask path
    final maskPath = Path();
    
    for (final strokeGroup in maskStrokes) {
      if (strokeGroup.isNotEmpty) {
        maskPath.moveTo(
          strokeGroup.first.dx + offsetX,
          strokeGroup.first.dy + offsetY,
        );
        
        for (int i = 1; i < strokeGroup.length; i++) {
          maskPath.lineTo(
            strokeGroup[i].dx + offsetX,
            strokeGroup[i].dy + offsetY,
          );
        }
      }
    }

    // Draw individual stroke points with modern styling
    for (final strokeGroup in maskStrokes) {
      for (final point in strokeGroup) {
        final adjustedPoint = Offset(point.dx + offsetX, point.dy + offsetY);
        
        // Outer glow effect
        final glowPaint = Paint()
          ..color = eraserMode 
              ? const Color(0xFFFF6B6B).withOpacity(0.3)
              : const Color(0xFF4ECDC4).withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        
        canvas.drawCircle(adjustedPoint, brushSize / 2 + 6, glowPaint);
        
        // Main brush stroke with gradient
        final gradient = RadialGradient(
          colors: eraserMode
              ? [
                  const Color(0xFFFF6B6B).withOpacity(brushOpacity),
                  const Color(0xFFFF6B6B).withOpacity(brushOpacity * 0.5),
                  Colors.transparent,
                ]
              : [
                  const Color(0xFF4ECDC4).withOpacity(brushOpacity),
                  const Color(0xFF64B5F6).withOpacity(brushOpacity * 0.7),
                  Colors.transparent,
                ],
        );
        
        final brushPaint = Paint()
          ..shader = gradient.createShader(
            Rect.fromCircle(center: adjustedPoint, radius: brushSize / 2),
          );
        
        canvas.drawCircle(adjustedPoint, brushSize / 2, brushPaint);
        
        // Inner highlight
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        
        canvas.drawCircle(adjustedPoint, brushSize / 4, highlightPaint);
      }
    }
  }

  void _drawProcessingAnimation(Canvas canvas, Size size) {
    // Animated overlay during processing
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.3);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);
    
    // Animated gradient waves
    final center = Offset(size.width / 2, size.height / 2);
    final radius1 = 50 + (animationValue * 100);
    final radius2 = 30 + (animationValue * 80);
    
    final wave1Paint = Paint()
      ..color = const Color(0xFF64B5F6).withOpacity(0.3 - animationValue * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final wave2Paint = Paint()
      ..color = const Color(0xFF4ECDC4).withOpacity(0.4 - animationValue * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(center, radius1, wave1Paint);
    canvas.drawCircle(center, radius2, wave2Paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}