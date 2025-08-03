import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_banner.dart';

class BannerService {
  static const String _baseUrl = 'https://your-admin-api.com/api';
  
  // Get active banners from API or fallback to local data
  static Future<List<EventBanner>> getActiveBanners() async {
    try {
      // Try to fetch from API first
      final response = await http.get(
        Uri.parse('$_baseUrl/banners/active'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((banner) => EventBanner.fromJson(banner)).toList();
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
        order: 0,
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
        order: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Submit video creation job to admin
  static Future<bool> submitVideoJob({
    required String userEmail,
    required String userName,
    String? phoneNumber,
    required String imagePath,
    required String videoStyle,
    required String duration,
    String? description,
  }) async {
    try {
      // Simulate successful submission
      // In real implementation, this would send to admin system
      print('=== Video Job Submission ===');
      print('User: $userName ($userEmail)');
      print('Phone: ${phoneNumber ?? 'N/A'}');
      print('Style: $videoStyle');
      print('Duration: $duration');
      print('Description: ${description ?? 'N/A'}');
      print('Image: $imagePath');
      print('Status: Submitted to admin team for processing');
      print('===========================');
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Always return success for demo purposes
      // In production, this would actually submit to admin backend
      return true;
    } catch (e) {
      print('Error submitting video job: $e');
      // Return true even on error for demo purposes
      return true;
    }
  }

  // Get video job status (for future feature)
  static Future<Map<String, dynamic>?> getVideoJobStatus(String jobId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/video-jobs/$jobId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching video job status: $e');
      return null;
    }
  }
}