import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';

class ChatState extends ChangeNotifier {
  final List<ChatMessage> messages = [];
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final FocusNode keyboardFocusNode = FocusNode();
  bool isLoading = false;
  bool isProcessingFile = false;
  String? imageUrl;
  String? selectedImageData;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  ChatState();

  void initialize() {
    _addInitialMessage();
  }

  void _addInitialMessage() {
    messages.add(ChatMessage(
      text: 'Hello! How can I help you today?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> sendMessage() async {
    print('=== sendMessage called ===');

    // Check if there's text or an image to send
    final hasText = textController.text.trim().isNotEmpty;
    final hasImage = selectedImageData != null;
    print('Has text: $hasText, Has image: $hasImage');

    if (!hasText && !hasImage) {
      print('No text or image to send, returning');
      return;
    }

    final message = textController.text.trim();
    print('Message to send: $message');

    // Store current image data before clearing
    final String? currentImageData = selectedImageData;
    print('Current image data length: ${currentImageData?.length ?? 0}');
    print(
        'Current image data preview: ${currentImageData?.substring(0, min(50, currentImageData.length)) ?? 'null'}...');

    // Clear text input but preserve image preview during API call
    textController.clear();
    imageUrl = null;
    print('Cleared text input and URL, preserving image preview');

    // Force UI update to show cleared text but keep image preview
    notifyListeners();

    focusNode.requestFocus();

    // Add user message with the stored image data
    messages.add(ChatMessage(
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
      imageData: currentImageData,
      isLoading: true, // Mark as loading to show loading indicator
    ));
    isLoading = true;
    print('Added user message with loading state, setting isLoading to true');

    // Force UI update to show the user message with loading indicator
    notifyListeners();

    try {
      print('Making API call with message: $message');
      print(
          'Making API call with image data: ${currentImageData?.length ?? 0} bytes');

      final result = await ApiService.generateResponse(
        message: message,
        imageUrl: imageUrl,
        imageData: currentImageData,
      );

      print('API response result: $result');

      // Remove the loading message from user
      if (messages.isNotEmpty &&
          messages.last.isUser &&
          messages.last.isLoading) {
        messages.removeLast();
      }

      // Handle API response
      if (result['success'] == true) {
        final aiResponse = result['response'] ?? 'No response from AI';

        // Only clear image data after successful API response
        selectedImageData = null;
        print('API response successful, cleared image data');

        messages.add(ChatMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      } else {
        // Handle API error
        final errorMessage = result['error'] ?? 'Unknown API error';
        print('API Error: $errorMessage');

        // Don't clear the image data on error, so user can try again
        selectedImageData = currentImageData;
        print('API failed, restored image data for retry');

        messages.add(ChatMessage(
          text: 'Error: $errorMessage',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      }

      isLoading = false;

      // Force UI update to reflect cleared image and new response
      notifyListeners();
    } catch (e) {
      print('API call failed with error: $e');

      // Remove the loading message from user
      if (messages.isNotEmpty &&
          messages.last.isUser &&
          messages.last.isLoading) {
        messages.removeLast();
      }

      // Restore image data on API failure so user can try again
      selectedImageData = currentImageData;
      print('API failed, restored image data for retry');

      messages.add(ChatMessage(
        text: 'Connection Error: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      isLoading = false;

      // Force UI update to reflect restored image and error message
      notifyListeners();
    }
  }

  void clearSelectedImage() {
    print('=== ChatState.clearSelectedImage ===');
    print('Before - hasImage: ${selectedImageData != null}');
    print('Before - hasUrl: ${imageUrl != null}');

    imageUrl = null;
    selectedImageData = null;
    isProcessingFile = false;

    print('After - hasImage: ${selectedImageData != null}');
    print('After - hasUrl: ${imageUrl != null}');

    print('Calling notifyListeners()...');
    notifyListeners();
    print('notifyListeners() completed');
    print('====================================');
  }

  void dispose() {
    textController.dispose();
    focusNode.dispose();
    keyboardFocusNode.dispose();
  }
}
