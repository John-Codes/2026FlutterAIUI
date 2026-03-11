import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

/// HTTP client service for API communication
/// Follows SRP by handling only HTTP communication functionality
class ApiClientService {
  static final ApiClientService _instance = ApiClientService._internal();
  factory ApiClientService() => _instance;
  ApiClientService._internal();

  static const String _baseUrl = apiBaseUrl;
  String? _accessToken;

  /// Set access token for authenticated requests
  void setAccessToken(String token) {
    _accessToken = token;
  }

  /// Clear access token (for logout)
  void clearAccessToken() {
    _accessToken = null;
  }

  /// Make GET request
  Future<http.Response> get(String endpoint,
      {Map<String, String>? headers}) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final requestHeaders = _buildHeaders(headers);

    return await http.get(url, headers: requestHeaders);
  }

  /// Make POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    final requestHeaders = _buildHeaders(headers);
    final jsonBody = body != null ? json.encode(body) : null;

    return await http.post(
      url,
      headers: requestHeaders,
      body: jsonBody,
    );
  }

  /// Make POST request with form data (for login)
  Future<http.Response> postForm(
    String endpoint, {
    Map<String, String>? body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');

    // Build headers without Content-Type for form data
    final requestHeaders = <String, String>{
      'Accept': 'application/json',
    };

    // Add custom headers if provided
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    // Add authorization token if available
    if (_accessToken != null) {
      requestHeaders['Authorization'] = 'Bearer $_accessToken';
    }

    return await http.post(
      url,
      headers: requestHeaders,
      body: body,
    );
  }

  /// Build headers with authentication
  Map<String, String> _buildHeaders([Map<String, String>? customHeaders]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// Handle API errors
  String handleApiError(http.Response response) {
    try {
      final errorData = json.decode(response.body);
      return errorData['detail'] ?? errorData['message'] ?? 'Unknown error';
    } catch (e) {
      return 'Request failed with status ${response.statusCode}';
    }
  }

  /// Check if response indicates success
  bool isSuccessResponse(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
