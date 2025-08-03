import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

class VideoService {
  static const String _baseUrl = 'https://web-backend_0787twink.onrender.com/api';
  static const Duration _timeoutDuration = Duration(seconds: 30);

  /// Submit video creation job to backend
  static Future<Map<String, dynamic>?> submitVideoJob({
    required String userEmail,
    required String userName,
    String? userPhone,
    required String imagePath,
    required String videoStyle,
    required int videoDuration,
    String? description,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/video-jobs'),
      );

      // Add form fields to match backend schema
      request.fields.addAll({
        'userEmail': userEmail,
        'userName': userName,
        'videoStyle': videoStyle,
        'videoDuration': videoDuration.toString(),
      });

      // Add optional fields
      if (userPhone != null && userPhone.isNotEmpty) {
        request.fields['userPhone'] = userPhone;
      }
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
      }

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath('image', imagePath),
      );

      // Send request with timeout
      final streamedResponse = await request.send().timeout(_timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        print('Video job submission error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } on TimeoutException {
      print('Video job submission timeout');
      return null;
    } on SocketException {
      print('No internet connection');
      return null;
    } catch (e) {
      print('Error submitting video job: $e');
      return null;
    }
  }

  /// Get video job status by ID
  static Future<Map<String, dynamic>?> getVideoJobStatus(String jobId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/video-jobs/$jobId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        }
      }
      return null;
    } on TimeoutException {
      print('Get video job status timeout');
      return null;
    } on SocketException {
      print('No internet connection');
      return null;
    } catch (e) {
      print('Error fetching video job status: $e');
      return null;
    }
  }

  /// Health check to verify backend connectivity
  static Future<bool> checkBackendHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['status'] == 'ok';
      }
      return false;
    } on TimeoutException {
      print('Backend health check timeout');
      return false;
    } on SocketException {
      print('No internet connection for health check');
      return false;
    } catch (e) {
      print('Backend health check failed: $e');
      return false;
    }
  }

  /// Test connectivity to backend on app start
  static Future<Map<String, dynamic>> testBackendConnectivity() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final isHealthy = await checkBackendHealth();
      stopwatch.stop();
      
      return {
        'isConnected': isHealthy,
        'responseTime': stopwatch.elapsedMilliseconds,
        'message': isHealthy 
          ? 'Backend connected successfully'
          : 'Backend health check failed',
      };
    } catch (e) {
      stopwatch.stop();
      return {
        'isConnected': false,
        'responseTime': stopwatch.elapsedMilliseconds,
        'message': 'Connection test failed: $e',
      };
    }
  }
}