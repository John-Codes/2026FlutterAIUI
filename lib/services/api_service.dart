import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static const int _maxRetries = 2;
  static const Duration _timeout = Duration(seconds: 30);

  static Future<Map<String, dynamic>> generateResponse({
    required String message,
    String? imageUrl,
    String? imageData,
  }) async {
    int attempt = 0;

    while (attempt <= _maxRetries) {
      attempt++;
      try {
        print('=== API Attempt $attempt of ${_maxRetries + 1} ===');

        final prefs = await SharedPreferences.getInstance();
        final apiKey = prefs.getString('apiKey') ?? '';
        final modelName = prefs.getString('modelName') ?? '';

        print('API Key configured: ${apiKey.isNotEmpty}');
        print('Model Name: $modelName');

        final requestBody = {
          'text': message,
          'api_key': apiKey,
          'model_name': modelName,
        };

        // Add image_url if it's not null and not empty
        if (imageUrl?.isNotEmpty == true) {
          requestBody['image_url'] = imageUrl!;
          print('Added image_url to request');
        }

        // Add image_data if it's not null and not empty
        if (imageData?.isNotEmpty == true) {
          requestBody['image_data'] = imageData!;
          print('Image data added to request, length: ${imageData!.length}');

          // Validate image data format
          if (!isValidBase64(imageData)) {
            return {
              'success': false,
              'error': 'Invalid image data format',
            };
          }

          // Check image size (max 5MB)
          final imageSizeInBytes = base64Decode(imageData).length;
          final maxSizeInBytes = 5 * 1024 * 1024; // 5MB
          if (imageSizeInBytes > maxSizeInBytes) {
            return {
              'success': false,
              'error': 'Image too large. Maximum size is 5MB.',
            };
          }
        } else {
          print('No image data added to request');
        }

        print('API Request body: $requestBody');

        final response = await http
            .post(
              Uri.parse('$apiBaseUrl/generate'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(requestBody),
            )
            .timeout(_timeout)
            .catchError((error) {
          throw Exception('Network error: ${error.toString()}');
        });

        print('API Response status: ${response.statusCode}');
        print('API Response body: ${response.body}');

        if (response.statusCode == 200) {
          final responseBody = json.decode(response.body);

          // The backend returns {"response": "content"} format
          if (responseBody.containsKey('response')) {
            print('API call successful');
            return {
              'success': true,
              'response': responseBody['response'] ?? 'No response from AI',
            };
          } else {
            return {
              'success': false,
              'error': 'API Response Error: ${responseBody.toString()}',
            };
          }
        } else {
          // If this is the last attempt or not a retryable error, return the error
          if (attempt > _maxRetries || !isRetryableError(response.statusCode)) {
            return {
              'success': false,
              'error': 'API Error: ${response.statusCode} - ${response.body}',
            };
          }

          // Wait before retrying
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      } catch (e) {
        print('API attempt $attempt failed: $e');

        if (attempt > _maxRetries) {
          return {
            'success': false,
            'error':
                'Connection Error after ${_maxRetries + 1} attempts: ${e.toString()}',
          };
        }

        // Wait before retrying
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }

    return {
      'success': false,
      'error': 'All retry attempts failed',
    };
  }

  static bool isValidBase64(String? data) {
    if (data == null || data.isEmpty) return false;

    try {
      base64Decode(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool isRetryableError(int statusCode) {
    return statusCode >= 500 || statusCode == 429 || statusCode == 408;
  }
}
