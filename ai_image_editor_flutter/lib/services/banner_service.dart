import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_banner.dart';

class BannerService {
  static const String _baseUrl = 'https://web-backend_0787twink.onrender.com/api';
  
  // Get active banners from API or fallback to local data
  static Future<List<EventBanner>> getActiveBanners() async {
    try {
      // Try to fetch from API first
      final response = await http.get(
        Uri.parse('$_baseUrl/event-banners'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          return data.map((banner) => EventBanner.fromJson(banner)).toList();
        }
        return _getLocalBanners();
      } else {
        // Fallback to local banners if API fails
        return _getLocalBanners();
      }
    } catch (e) {
      // Fallback to local banners if network error
      print('Error fetching banners from API: $e');
      return _getLocalBanners();
    }
  }

  // Local banner data as fallback
  static List<EventBanner> _getLocalBanners() {
    return [
      EventBanner(
        id: '1',
        title: 'AI Tạo Video Từ Ảnh',
        description: 'Biến ảnh của bạn thành video sống động với AI',
        imageUrl: '',
        actionUrl: '/ai-video-creation',
        isActive: true,
        priority: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      EventBanner(
        id: '2',
        title: 'Nâng Cấp Chất Lượng Ảnh',
        description: 'Tăng độ phân giải lên 4K với AI',
        imageUrl: '',
        actionUrl: '/upscaling',
        isActive: true,
        priority: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Submit video creation job to admin
  static Future<Map<String, dynamic>?> submitVideoJob({
    required String userEmail,
    required String userName,
    String? phoneNumber,
    required String imagePath,
    required String videoStyle,
    required int videoDuration, // Changed to int to match backend
    String? description,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/video-jobs'),
      );

      // Add form fields
      request.fields.addAll({
        'userEmail': userEmail,
        'userName': userName,
        'userPhone': phoneNumber ?? '',
        'videoStyle': videoStyle,
        'videoDuration': videoDuration.toString(),
        'description': description ?? '',
      });

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath('image', imagePath),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error submitting video job: $e');
      return null;
    }
  }

  // Get video job status
  static Future<Map<String, dynamic>?> getVideoJobStatus(String jobId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/video-jobs/$jobId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        }
      }
      return null;
    } catch (e) {
      print('Error fetching video job status: $e');
      return null;
    }
  }

  // Health check to verify backend connectivity
  static Future<bool> checkBackendHealth() async {
    try {
      final response = await http.get(
        Uri.parse('https://web-backend_0787twink.onrender.com/api/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['status'] == 'ok';
      }
      return false;
    } catch (e) {
      print('Backend health check failed: $e');
      return false;
    }
  }
}