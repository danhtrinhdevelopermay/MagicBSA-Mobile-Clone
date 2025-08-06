import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/image_upload_widget.dart';
import '../widgets/interactive_button.dart';
import 'apple_photos_cleanup_screen.dart';

// Class definitions moved to top to avoid forward reference issues
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

class SimpleFeature {
  final String title;
  final IconData icon;
  final String? badge;

  const SimpleFeature({
    required this.title,
    required this.icon,
    this.badge,
  });
}


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
      backgroundColor: Color(0xFF0F1B26), // Dark background như hình mẫu
      body: SafeArea(
        child: Column(
          children: [
            // Header giống Wink Studio
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  // App name "Wink Studio" giữ nguyên như yêu cầu
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Twink', // Giữ nguyên tên app cũ
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Studio',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  
                  Spacer(),
                  
                  // Search box
                  Container(
                    width: 180,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 12),
                        Icon(Icons.search, color: Colors.white70, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Tìm kiếm',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(width: 16),
                  
                  // Diamond icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.diamond_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            
            // Banner "Wemoji" section
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage('assets/images/wemoji_banner_bg.jpg'), // Sẽ fallback nếu không có
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4A90E2),
                    Color(0xFF7B68EE),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Live',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Wemoji',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Try Now ⚪',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Nút "Mới" với gradient hồng
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFFF6B9D),
                    Color(0xFFFFB5C5),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Mới',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Grid tính năng AI - 4 cột giống hình mẫu
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  physics: BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 4 cột giống hình mẫu
                    childAspectRatio: 0.9, 
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _getSimpleFeatures().length,
                  itemBuilder: (context, index) {
                    final feature = _getSimpleFeatures()[index];
                    return _buildSimpleFeatureCard(feature);
                  },
                ),
              ),
            ),
            
            // Bottom Navigation giống hình mẫu
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomNavItem('Trang chủ', true),
                  _buildBottomNavItem('Màu', false),
                  _buildBottomNavItem('Tối', false),
                ],
              ),
            ),
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

  // Tạo danh sách các tính năng đơn giản giống hình mẫu
  List<SimpleFeature> _getSimpleFeatures() {
    return [
      SimpleFeature(title: 'Chất lượng\nHình ảnh', icon: Icons.hd_outlined, badge: 'HD+'),
      SimpleFeature(title: 'AI phục hồi', icon: Icons.auto_fix_high_outlined),
      SimpleFeature(title: 'Khôi phục\nảnh', icon: Icons.people_outline),
      SimpleFeature(title: 'Siêu phân giải', icon: Icons.settings_backup_restore_outlined),
      SimpleFeature(title: 'Hiệu ứng\nmới', icon: Icons.celebration_outlined, badge: 'NEW'),
      SimpleFeature(title: 'Xóa mờ', icon: Icons.blur_off_outlined),
      SimpleFeature(title: 'Ghép nối\nvideo', icon: Icons.video_library_outlined),
      SimpleFeature(title: 'Thêm sáng', icon: Icons.wb_sunny_outlined),
      SimpleFeature(title: 'AI làm đẹp', icon: Icons.face_retouching_natural_outlined),
      SimpleFeature(title: 'Trang điểm', icon: Icons.palette_outlined),
      SimpleFeature(title: 'Tùy chỉnh', icon: Icons.tune_outlined),
      SimpleFeature(title: 'Mở rộng', icon: Icons.expand_outlined),
    ];
  }

  // Build card đơn giản giống hình mẫu
  Widget _buildSimpleFeatureCard(SimpleFeature feature) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _navigateToUpload(feature.title.toLowerCase().replaceAll('\n', ' ').replaceAll(' ', '_'));
      },
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon với badge nếu có
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    feature.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (feature.badge != null)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: feature.badge == 'NEW' ? Colors.red : Colors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        feature.badge!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            // Title
            Text(
              feature.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Build bottom navigation item
  Widget _buildBottomNavItem(String title, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: isSelected 
        ? BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          )
        : null,
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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