import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/image_upload_widget.dart';
import '../widgets/interactive_button.dart';
import 'apple_photos_cleanup_screen.dart';


class GenerationScreen extends StatefulWidget {
  const GenerationScreen({Key? key}) : super(key: key);

  @override
  State<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends State<GenerationScreen> with TickerProviderStateMixin {
  Map<String, bool> _isPressed = {};
  
  final List<Feature> features = [
    Feature(
      title: 'Xóa nền ảnh',
      description: 'Loại bỏ hoàn toàn nền ảnh',
      icon: Icons.layers_clear_outlined,
      gradient: LinearGradient(
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      operation: 'removeBackground',
      gifPath: 'assets/gifs/remove-background.gif',
    ),
    Feature(
      title: 'Mở rộng ảnh',
      description: 'Thêm không gian',
      icon: Icons.open_in_full,
      gradient: LinearGradient(
        colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      operation: 'uncrop',
      gifPath: 'assets/gifs/expand-image.gif',
    ),
    Feature(
      title: 'Nâng cấp độ phân giải',
      description: 'Tăng chất lượng ảnh',
      icon: Icons.high_quality,
      gradient: LinearGradient(
        colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      operation: 'imageUpscaling',
      gifPath: 'assets/gifs/upscaling.gif',
    ),
    Feature(
      title: 'Clean Up',
      description: 'Apple Photos-style object removal',
      icon: Icons.auto_fix_high,
      gradient: LinearGradient(
        colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      operation: 'cleanup',
      gifPath: 'assets/gifs/cleanup.gif',
    ),
    Feature(
      title: 'Xóa chữ khỏi ảnh',
      description: 'Loại bỏ văn bản',
      icon: Icons.text_fields_outlined,
      gradient: LinearGradient(
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      operation: 'removeText',
      gifPath: 'assets/gifs/remove-text.gif',
    ),
    Feature(
      title: 'Tái tạo ảnh AI',
      description: 'Biến đổi phong cách',
      icon: Icons.auto_awesome,
      gradient: LinearGradient(
        colors: [Color(0xFF8360c3), Color(0xFF2ebf91)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      operation: 'reimagine',
      gifPath: 'assets/gifs/reimagine.gif',
    ),
    Feature(
      title: 'Tạo ảnh từ văn bản',
      description: 'Biến ý tưởng thành hình ảnh',
      icon: Icons.create,
      gradient: LinearGradient(
        colors: [Color(0xFF00d2ff), Color(0xFF3a7bd5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      operation: 'textToImage',
      gifPath: 'assets/gifs/text-to-image.gif',
    ),
    Feature(
      title: 'Chụp ảnh sản phẩm',
      description: 'Tạo ảnh sản phẩm chuyên nghiệp',
      icon: Icons.camera_alt,
      gradient: LinearGradient(
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      operation: 'productPhotography',
      gifPath: 'assets/gifs/product-photography.gif',
    ),

  ];

  @override
  void initState() {
    super.initState();
    // GIF system doesn't need initialization like videos
  }
  
  @override
  void dispose() {
    // GIF system doesn't need disposal like videos
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Minimal Header - chỉ tập trung vào chọn tính năng
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  InteractiveButton(
                    onTap: () => Navigator.of(context).pop(),
                    pressedOpacity: 0.6,
                    borderRadius: BorderRadius.circular(8),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xFF2C2C2C),
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Chọn tính năng AI',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C2C2C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF8B7CE8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Subtitle nhẹ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Khám phá các công cụ AI mạnh mẽ',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            SizedBox(height: 24),
            
            // Grid tính năng - tối ưu cho trải nghiệm chọn
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  physics: BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85, // Tỷ lệ tối ưu cho thiết kế mới
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: features.length,
                  itemBuilder: (context, index) {
                    final feature = features[index];
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 200 + (index * 50)),
                      curve: Curves.easeOutQuart,
                      child: _buildGifFeatureCard(feature),
                    );
                  },
                ),
              ),
            ),
            
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGifFeatureCard(Feature feature) {
    final isPressed = _isPressed[feature.operation] ?? false;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      transform: Matrix4.identity()
        ..scale(isPressed ? 0.95 : 1.0),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _isPressed[feature.operation] = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            _isPressed[feature.operation] = false;
          });
          HapticFeedback.lightImpact();
          _navigateToUpload(feature.operation);
        },
        onTapCancel: () {
          setState(() {
            _isPressed[feature.operation] = false;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            // Gradient background giống hình mẫu - soft purple
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE6E1FF), // Light purple như trong hình
                Color(0xFFF2EFFF), // Lighter purple
                Color(0xFFECE8FF), // Medium light purple
              ],
              stops: [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(20), // Bo góc như hình mẫu
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: Offset(0, 6),
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: EdgeInsets.all(16), // Padding nhỏ hơn để match hình mẫu
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header với Free badge giống hình mẫu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF8B7CE8), // Màu tím của Free badge
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Free',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Demo image section với split effect như hình mẫu
                  Expanded(
                    flex: 5, // Tăng tỷ lệ để hình lớn hơn
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            // Background với hình demo hoặc gradient
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              child: feature.gifPath != null
                                  ? Image.asset(
                                      feature.gifPath!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                Color(0xFF4A4A4A), // Dark left side
                                                Color(0xFF6A6A6A), // Light right side
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Color(0xFF4A4A4A), // Dark left side (trước)
                                            Color(0xFF6A6A6A), // Light right side (sau)
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                            
                            // Vertical split line giống hình mẫu
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: Row(
                                children: [
                                  Expanded(child: SizedBox()), // Left side
                                  Container(
                                    width: 1.5,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(child: SizedBox()), // Right side
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Title section giống hình mẫu
                  Text(
                    feature.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C2C2C), // Dark color như hình mẫu
                      height: 1.2,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 6),
                  
                  // Description giống hình mẫu
                  Text(
                    feature.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF888888), // Light gray như hình mẫu
                      height: 1.3,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToUpload(String operation) {
    if (operation == 'cleanup') {
      // Navigate to Apple Photos style cleanup screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ApplePhotosCleanupScreen(),
        ),
      );
    } else {
      // Navigate to normal upload widget for all other features
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImageUploadWidget(
            preSelectedFeature: operation,
          ),
        ),
      );
    }
  }
}

class Feature {
  final String title;
  final String description;
  final IconData icon;
  final LinearGradient gradient;
  final String operation;
  final String? gifPath;

  const Feature({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.operation,
    this.gifPath,
  });
}