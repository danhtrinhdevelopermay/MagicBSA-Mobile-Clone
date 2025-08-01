import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/image_provider.dart';
import '../screens/editor_screen.dart';
import 'text_to_image_widget.dart';
import 'image_to_video_widget.dart';

class ImageUploadWidget extends StatefulWidget {
  final String? preSelectedFeature;
  final String? selectedOperation;
  
  const ImageUploadWidget({
    super.key, 
    this.preSelectedFeature,
    this.selectedOperation,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  
  @override
  void initState() {
    super.initState();
    // Handle special cases first
    final selectedFeature = widget.preSelectedFeature ?? widget.selectedOperation;
    
    // Check for special features that don't need image upload widget
    if (selectedFeature == 'textToImage') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => TextToImageWidget()),
        );
      });
      return;
    }
    
    if (selectedFeature == 'imageToVideo') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ImageToVideoWidget()),
        );
      });
      return;
    }
    
    // Clear any existing callback - we'll handle navigation manually via "Bắt đầu xử lý" button
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ImageEditProvider>(context, listen: false);
      provider.setOnImagePickedCallback(null); // Clear auto-navigation
    });
  }
  
  @override
  void dispose() {
    // Clear callback when widget is disposed
    try {
      final provider = Provider.of<ImageEditProvider>(context, listen: false);
      provider.setOnImagePickedCallback(null);
    } catch (e) {
      // Handle case where provider is no longer available
    }
    super.dispose();
  }
  
  Future<void> _handleImageSelection(ImageSource source) async {
    final provider = Provider.of<ImageEditProvider>(context, listen: false);
    
    try {
      await provider.pickImage(source);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ImageEditProvider>(context);
    final selectedFeature = widget.preSelectedFeature ?? widget.selectedOperation;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _getFeatureTitle(selectedFeature),
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            // Feature description header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366f1).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    _getFeatureIcon(selectedFeature),
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getFeatureTitle(selectedFeature) ?? 'Chọn tính năng AI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getFeatureDescription(selectedFeature),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Main content based on feature type
            if (provider.selectedImage != null) 
              _buildImageProcessingSection(context, provider, selectedFeature)
            else 
              _buildUploadSection(context),
              
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFF6366f1).withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => _showImageSourceDialog(context),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                // Animated upload icon with gradient
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366f1).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.cloud_upload_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Kéo thả hoặc chọn ảnh',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1e293b),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366f1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'JPG, PNG, WEBP • Tối đa 10MB',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6366f1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366f1).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_photo_alternate_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Chọn Ảnh',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageProcessingSection(BuildContext context, ImageEditProvider provider, String? selectedFeature) {
    return Column(
      children: [
        // Show selected image
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              provider.selectedImage!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Process button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _startProcessing(context, provider, selectedFeature),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366f1).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_fix_high,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Bắt đầu xử lý',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Change image button
        TextButton.icon(
          onPressed: () => _showImageSourceDialog(context),
          icon: Icon(Icons.refresh, color: Color(0xFF6366f1)),
          label: Text(
            'Chọn ảnh khác',
            style: TextStyle(
              color: Color(0xFF6366f1),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _startProcessing(BuildContext context, ImageEditProvider provider, String? selectedFeature) {
    if (provider.selectedImage != null && selectedFeature != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditorScreen(
            originalImage: provider.selectedImage!,
            preSelectedFeature: selectedFeature,
          ),
        ),
      );
    }
  }

  String _getFeatureTitle(String? feature) {
    final titles = {
      'removeBackground': 'Xóa nền ảnh',
      'uncrop': 'Mở rộng ảnh',
      'imageUpscaling': 'Nâng cấp độ phân giải',
      'cleanup': 'Xóa vật thể',
      'removeText': 'Xóa chữ khỏi ảnh',
      'reimagine': 'Tái tạo ảnh AI',
      'textToImage': 'Tạo ảnh từ văn bản',
      'productPhotography': 'Chụp ảnh sản phẩm',
    };
    return titles[feature] ?? 'Chọn tính năng AI';
  }

  IconData _getFeatureIcon(String? feature) {
    final icons = {
      'removeBackground': Icons.layers_clear_outlined,
      'uncrop': Icons.open_in_full,
      'imageUpscaling': Icons.high_quality,
      'cleanup': Icons.auto_fix_high,
      'removeText': Icons.text_fields_outlined,
      'reimagine': Icons.auto_awesome,
      'textToImage': Icons.create,
      'productPhotography': Icons.camera_alt,
    };
    return icons[feature] ?? Icons.auto_awesome;
  }

  String _getFeatureDescription(String? feature) {
    final descriptions = {
      'removeBackground': 'Loại bỏ hoàn toàn nền ảnh một cách tự động',
      'uncrop': 'Mở rộng không gian ảnh với AI',
      'imageUpscaling': 'Tăng chất lượng và độ phân giải ảnh',
      'cleanup': 'Xóa bất kỳ vật thể không mong muốn',
      'removeText': 'Loại bỏ văn bản khỏi ảnh',
      'reimagine': 'Biến đổi phong cách ảnh với AI',
      'textToImage': 'Tạo ảnh từ mô tả văn bản',
      'productPhotography': 'Tạo ảnh sản phẩm chuyên nghiệp',
    };
    return descriptions[feature] ?? 'Khám phá sức mạnh trí tuệ nhân tạo';
  }
  
  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Chọn nguồn ảnh',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSourceOption(
                            context,
                            Icons.camera_alt,
                            'Camera',
                            () => _handleImageSelection(ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSourceOption(
                            context,
                            Icons.photo_library,
                            'Thư viện',
                            () => _handleImageSelection(ImageSource.gallery),
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
      ),
    );
  }

  Widget _buildSourceOption(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: const Color(0xFF6366f1)),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}