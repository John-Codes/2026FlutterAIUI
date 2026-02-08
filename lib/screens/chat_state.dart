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
    print('sendMessage called');
    if (textController.text.trim().isEmpty) return;

    final message = textController.text.trim();
    print('Message to send: $message');

    // Store current image data before clearing
    final String? currentImageData = selectedImageData;
    print(
        'Current image data: ${currentImageData != null ? 'has image' : 'no image'}');

    // Clear text input and selected image immediately
    textController.clear();
    imageUrl = null;
    selectedImageData = null;
    print('Cleared image data, calling notifyListeners()');

    // Force UI update to clear image preview immediately
    notifyListeners();

    focusNode.requestFocus();

    // Add user message with the stored image data
    messages.add(ChatMessage(
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
      imageData: currentImageData,
      isLoading: false,
    ));
    isLoading = true;
    print('Added user message, setting isLoading to true');

    // Force UI update to show the user message immediately
    notifyListeners();

    try {
      final result = await ApiService.generateResponse(
        message: message,
        imageUrl: imageUrl,
        imageData: currentImageData,
      );

      // Remove the loading message from user
      if (messages.isNotEmpty &&
          messages.last.isUser &&
          messages.last.isLoading) {
        messages.removeLast();
      }

      messages.add(ChatMessage(
        text: result['response'] ?? 'No response from AI',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      isLoading = false;
    } catch (e) {
      // Remove the loading message from user
      if (messages.isNotEmpty &&
          messages.last.isUser &&
          messages.last.isLoading) {
        messages.removeLast();
      }

      messages.add(ChatMessage(
        text: 'Connection Error: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      isLoading = false;
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
