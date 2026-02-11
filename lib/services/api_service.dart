import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static Future<Map<String, dynamic>> generateResponse({
    required String message,
    String? imageUrl,
    String? imageData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString('apiKey') ?? '';
      final modelName = prefs.getString('modelName') ?? '';

      final requestBody = {
        'text': message,
        'api_key': apiKey,
        'model_name': modelName,
      };

      // Add image_url if it's not null and not empty
      if (imageUrl?.isNotEmpty == true) {
        requestBody['image_url'] = imageUrl!;
      }

      // Add image_data if it's not null and not empty
      if (imageData?.isNotEmpty == true) {
        requestBody['image_data'] = imageData!;
        print('Image data added to request, length: ${imageData!.length}');
      } else {
        print('No image data added to request');
      }

      print('API Request body: $requestBody');

      final response = await http.post(
        Uri.parse('$apiBaseUrl/generate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      print('API Response status: ${response.statusCode}');
      print('API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // The backend returns {"response": "content"} format
        if (responseBody.containsKey('response')) {
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
        return {
          'success': false,
          'error': 'API Error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection Error: ${e.toString()}',
      };
    }
  }
}
