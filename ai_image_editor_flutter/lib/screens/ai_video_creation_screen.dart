import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/video_job.dart';
import '../services/video_service.dart';

class AIVideoCreationScreen extends StatefulWidget {
  const AIVideoCreationScreen({Key? key}) : super(key: key);

  @override
  State<AIVideoCreationScreen> createState() => _AIVideoCreationScreenState();
}

class _AIVideoCreationScreenState extends State<AIVideoCreationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _userEmailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _selectedImage;
  String _selectedStyle = '';
  String _selectedDuration = '';
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _videoStyles = [
    {
      'value': 'cinematic',
      'title': 'Điện ảnh',
      'description': 'Phong cách Hollywood chuyên nghiệp',
      'icon': Icons.movie_outlined,
      'gradient': [Color(0xFF667eea), Color(0xFF764ba2)],
    },
    {
      'value': 'anime',
      'title': 'Anime',
      'description': 'Phong cách hoạt hình Nhật Bản',
      'icon': Icons.face_retouching_natural,
      'gradient': [Color(0xFFf093fb), Color(0xFFf5576c)],
    },
    {
      'value': 'realistic',
      'title': 'Thực tế',
      'description': 'Chuyển động tự nhiên',
      'icon': Icons.camera_alt_outlined,
      'gradient': [Color(0xFF11998e), Color(0xFF38ef7d)],
    },
    {
      'value': 'artistic',
      'title': 'Nghệ thuật',
      'description': 'Phong cách sáng tạo độc đáo',
      'icon': Icons.palette_outlined,
      'gradient': [Color(0xFF8360c3), Color(0xFF2ebf91)],
    },
    {
      'value': 'vintage',
      'title': 'Cổ điển',
      'description': 'Phong cách retro nostalgic',
      'icon': Icons.camera_outlined,
      'gradient': [Color(0xFFfc4a1a), Color(0xFFf7b733)],
    },
    {
      'value': 'futuristic',
      'title': 'Tương lai',
      'description': 'Phong cách sci-fi hiện đại',
      'icon': Icons.rocket_launch_outlined,
      'gradient': [Color(0xFF4facfe), Color(0xFF00f2fe)],
    },
  ];

  final List<Map<String, dynamic>> _durations = [
    {'value': '3s', 'title': '3 giây', 'description': 'Nhanh gọn'},
    {'value': '5s', 'title': '5 giây', 'description': 'Chuẩn'},
    {'value': '10s', 'title': '10 giây', 'description': 'Dài'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _userNameController.dispose();
    _userEmailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showSnackBar('Lỗi khi chọn ảnh: ${e.toString()}', isError: true);
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      _showSnackBar('Vui lòng điền đầy đủ thông tin và chọn ảnh', isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await VideoService.submitVideoJob(
        userEmail: _userEmailController.text,
        userName: _userNameController.text,
        userPhone: _phoneController.text.isEmpty ? null : _phoneController.text,
        imagePath: _selectedImage!.path,
        videoStyle: _selectedStyle,
        videoDuration: int.parse(_selectedDuration), // Convert to int
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );

      if (result != null && result['success'] == true) {
        setState(() {
          _isSubmitted = true;
        });
        final message = result['message'] ?? 'Yêu cầu đã được gửi thành công!';
        _showSnackBar(message);
      } else {
        final errorMessage = result?['message'] ?? 'Không thể gửi yêu cầu. Vui lòng thử lại.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('FormatException')) {
        errorMessage = 'Lỗi định dạng dữ liệu. Vui lòng kiểm tra lại thông tin.';
      } else if (errorMessage.contains('TimeoutException')) {
        errorMessage = 'Kết nối timeout. Vui lòng kiểm tra mạng và thử lại.';
      }
      _showSnackBar('Có lỗi xảy ra: $errorMessage', isError: true);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _isSubmitted = false;
      _selectedImage = null;
      _selectedStyle = '';
      _selectedDuration = '';
    });
    _formKey.currentState?.reset();
    _userNameController.clear();
    _userEmailController.clear();
    _phoneController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Tạo Video Từ Ảnh',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isSubmitted ? _buildSuccessScreen() : _buildFormScreen(),
    );
  }

  Widget _buildSuccessScreen() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Yêu cầu đã được gửi!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chúng tôi đã nhận được yêu cầu tạo video của bạn.\nĐội ngũ admin sẽ xử lý và gửi kết quả qua email trong vòng 24-48 giờ.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _resetForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Tạo video khác',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormScreen() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 24),
                  _buildImageUploadSection(),
                  const SizedBox(height: 24),
                  _buildUserInfoSection(),
                  const SizedBox(height: 24),
                  _buildVideoStyleSection(),
                  const SizedBox(height: 24),
                  _buildDurationSection(),
                  const SizedBox(height: 24),
                  _buildDescriptionSection(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.video_camera_back_rounded,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Biến ảnh thành video sống động',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sử dụng công nghệ AI tiên tiến',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return _buildSection(
      title: 'Tải ảnh lên',
      subtitle: 'Chọn ảnh bạn muốn chuyển thành video',
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedImage != null
                  ? const Color(0xFF667eea)
                  : Colors.grey.withOpacity(0.3),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 48,
                      color: Colors.grey.withOpacity(0.6),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nhấn để chọn ảnh',
                      style: TextStyle(
                        color: Colors.grey.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PNG, JPG, WEBP (tối đa 10MB)',
                      style: TextStyle(
                        color: Colors.grey.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return _buildSection(
      title: 'Thông tin liên hệ',
      subtitle: 'Để chúng tôi có thể gửi video hoàn thành cho bạn',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _userNameController,
                  label: 'Họ và tên *',
                  hint: 'Nguyễn Văn A',
                  validator: (value) =>
                      value?.isEmpty == true ? 'Vui lòng nhập tên' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _userEmailController,
                  label: 'Email *',
                  hint: 'email@example.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Vui lòng nhập email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value!)) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Số điện thoại (tùy chọn)',
            hint: '0123456789',
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoStyleSection() {
    return _buildSection(
      title: 'Phong cách video',
      subtitle: 'Chọn phong cách bạn muốn cho video',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _videoStyles.length,
        itemBuilder: (context, index) {
          final style = _videoStyles[index];
          final isSelected = _selectedStyle == style['value'];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedStyle = style['value'];
              });
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: style['gradient'],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    style['icon'],
                    color: isSelected ? Colors.white : Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    style['title'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[300],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    style['description'],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey.withOpacity(0.6),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDurationSection() {
    return _buildSection(
      title: 'Thời lượng video',
      subtitle: 'Chọn độ dài video phù hợp',
      child: Row(
        children: _durations.map((duration) {
          final isSelected = _selectedDuration == duration['value'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDuration = duration['value'];
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF667eea)
                      : const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF667eea)
                        : Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      duration['title'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[300],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      duration['description'],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : Colors.grey.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return _buildSection(
      title: 'Mô tả thêm (tùy chọn)',
      subtitle: 'Mô tả chi tiết về hiệu ứng bạn muốn',
      child: _buildTextField(
        controller: _descriptionController,
        label: 'Mô tả',
        hint: 'Ví dụ: Tôi muốn video có hiệu ứng zoom in, background mờ...',
        maxLines: 4,
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isFormValid = _selectedImage != null &&
        _selectedStyle.isNotEmpty &&
        _selectedDuration.isNotEmpty &&
        _userNameController.text.isNotEmpty &&
        _userEmailController.text.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isFormValid && !_isSubmitting ? _submitRequest : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667eea),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: isFormValid ? 8 : 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_rounded, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Gửi yêu cầu tạo video',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.grey.withOpacity(0.8)),
        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
        filled: true,
        fillColor: const Color(0xFF161B22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}