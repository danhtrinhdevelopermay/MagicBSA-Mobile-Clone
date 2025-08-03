# 📱 Tích hợp Flutter App với Render Backend

## 🌐 Backend URL
**Production Backend**: https://web-backend_0787twink.onrender.com

## 🔧 Cập nhật Flutter Services

### 1. Video Service (lib/services/video_service.dart)

```dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VideoService {
  static const String baseUrl = 'https://web-backend_0787twink.onrender.com';
  
  /// Submit video creation request
  static Future<Map<String, dynamic>> submitVideoJob({
    required String userName,
    required String userEmail,
    String? userPhone,
    required String videoStyle,
    required int videoDuration,
    required File imageFile,
    String? description,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/api/video-jobs');
      var request = http.MultipartRequest('POST', uri);
      
      // Add form fields
      request.fields['userName'] = userName;
      request.fields['userEmail'] = userEmail;
      request.fields['videoStyle'] = videoStyle;
      request.fields['videoDuration'] = videoDuration.toString();
      if (userPhone != null && userPhone.isNotEmpty) {
        request.fields['userPhone'] = userPhone;
      }
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
      }
      
      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path)
      );
      
      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to submit video job: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error submitting video job: $e');
    }
  }
  
  /// Check video job status
  static Future<Map<String, dynamic>> getVideoJobStatus(String jobId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/video-jobs/$jobId'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get job status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting job status: $e');
    }
  }
}
```

### 2. Banner Service (lib/services/banner_service.dart)

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/event_banner.dart';

class BannerService {
  static const String baseUrl = 'https://web-backend_0787twink.onrender.com';
  
  /// Get active event banners
  static Future<List<EventBanner>> getEventBanners() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/event-banners'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((banner) => EventBanner.fromJson(banner))
              .toList();
        }
      }
      
      // Fallback to empty list if API fails
      return [];
    } catch (e) {
      print('Error fetching banners: $e');
      
      // Fallback to local/default banners if needed
      return _getDefaultBanners();
    }
  }
  
  /// Default banners for fallback
  static List<EventBanner> _getDefaultBanners() {
    return [
      EventBanner(
        id: 'default-1',
        title: 'AI Video Creation',
        description: 'Tạo video AI từ ảnh',
        imageUrl: 'assets/images/default_banner.png',
        actionText: 'Khám phá ngay',
        isActive: true,
        priority: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
```

### 3. API Client Helper (lib/services/api_client.dart)

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClient {
  static const String baseUrl = 'https://web-backend_0787twink.onrender.com';
  static const Duration timeoutDuration = Duration(seconds: 30);
  
  /// Health check
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
      ).timeout(timeoutDuration);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'ok';
      }
      return false;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }
  
  /// Check if backend is available
  static Future<bool> isBackendAvailable() async {
    return await checkHealth();
  }
}
```

## 🔄 Error Handling Strategy

### 1. Network Error Handling

```dart
class NetworkService {
  static Future<T?> safeApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on SocketException {
      print('No internet connection');
      return null;
    } on TimeoutException {
      print('Request timeout');
      return null;
    } on HttpException {
      print('HTTP error');
      return null;
    } catch (e) {
      print('Unknown error: $e');
      return null;
    }
  }
}
```

### 2. Usage trong UI

```dart
// In your video creation screen
Future<void> _submitVideoRequest() async {
  setState(() => _isLoading = true);
  
  try {
    final result = await VideoService.submitVideoJob(
      userName: _nameController.text,
      userEmail: _emailController.text,
      userPhone: _phoneController.text,
      videoStyle: _selectedStyle,
      videoDuration: _selectedDuration,
      imageFile: _selectedImage!,
      description: _descriptionController.text,
    );
    
    if (result['success'] == true) {
      // Navigate to success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VideoRequestSuccessScreen(
            jobId: result['jobId'],
          ),
        ),
      );
    }
  } catch (e) {
    // Show error dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lỗi: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

## 🎯 Testing Integration

### Test URLs trong browser:
- Health: https://web-backend_0787twink.onrender.com/api/health
- Banners: https://web-backend_0787twink.onrender.com/api/event-banners

### Test trong Flutter app:
1. Build app với updated services
2. Test banner loading trên main screen
3. Test video job submission
4. Verify email notifications

## ⚡ Performance Tips

1. **Caching**: Cache banner data locally
2. **Timeouts**: Set appropriate timeouts for requests
3. **Retry Logic**: Implement retry for failed requests
4. **Offline Mode**: Provide fallback content when offline

Backend integration đã sẵn sàng cho production!