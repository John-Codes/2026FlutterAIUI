import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imageData; // Base64 encoded image data
  final bool isLoading; // For loading states

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageData,
    this.isLoading = false,
  });
}
