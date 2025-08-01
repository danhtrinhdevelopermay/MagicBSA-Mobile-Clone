import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/image_provider.dart';
import '../widgets/image_upload_widget.dart';
import '../widgets/loading_overlay_widget.dart';
import '../widgets/audio_controls_widget.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../services/audio_service.dart';
import 'history_screen.dart';
import 'premium_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'generation_screen.dart';

// Import Feature class từ generation_screen
class Feature {
  final String title;
  final String description;
  final IconData icon;
  final String operation;
  final LinearGradient gradient;
  final String? gifPath;

  Feature({
    required this.title,
    required this.description,
    required this.icon,
    required this.operation,
    required this.gradient,
    this.gifPath,
  });
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  Map<String, bool> _isPressed = {};
  
  // Define features list
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
      title: 'Xóa vật thể',
      description: 'Loại bỏ bất kỳ vật thể nào',
      icon: Icons.auto_fix_high,
      gradient: LinearGradient(
        colors: [Color(0xFFfc4a1a), Color(0xFFf7b733)],
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToUpload(String operation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageUploadWidget(
          preSelectedFeature: operation,
        ),
      ),
    );
  }

  Widget _buildFeatureCard(Feature feature) {
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

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style for main screen
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ));
    
    return Consumer<ImageEditProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  // Generation Page - Trang chọn tính năng AI trực tiếp
                  SafeArea(
                    child: Column(
                      children: [
                        // Header đơn giản
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Row(
                            children: [
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
                        
                        // Subtitle
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
                        
                        // Grid tính năng
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.builder(
                              physics: BouncingScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.85,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: features.length,
                              itemBuilder: (context, index) {
                                final feature = features[index];
                                return AnimatedContainer(
                                  duration: Duration(milliseconds: 200 + (index * 50)),
                                  curve: Curves.easeOutQuart,
                                  child: _buildFeatureCard(feature),
                                );
                              },
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                  
                  // History Page
                  const HistoryScreen(),
                  
                  // Premium Page
                  const PremiumScreen(),
                  
                  // Profile Page
                  const ProfileScreen(),
                ],
              ),
              
              // Loading Overlay
              if (provider.currentOperation != null)
                LoadingOverlayWidget(
                  isVisible: provider.currentOperation != null,
                  message: provider.currentOperation?.toString() ?? 'Đang xử lý...',
                ),
                
              // Audio Controls
              Positioned(
                top: MediaQuery.of(context).padding.top + 20,
                right: 20,
                child: const AudioControlsWidget(),
              ),
            ],
          ),
          // ✅ CRITICAL FIX: Use bottomNavigationBar instead of Column
          bottomNavigationBar: BottomNavigationWidget(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          ),
        );
      },
    );
  }


}