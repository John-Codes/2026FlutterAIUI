import 'dart:math';
import 'package:flutter/material.dart';

/// State provider for chat input components
/// Manages shared state between file attachment, send button, and text input components
class ChatInputStateProvider extends InheritedWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final bool isLoading;
  final bool isProcessingFile;
  final String? selectedImageData;
  final VoidCallback onSendMessage;
  final VoidCallback onShowImageDialog;
  final VoidCallback onClearSelectedImage;

  const ChatInputStateProvider({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.isLoading,
    required this.isProcessingFile,
    required this.selectedImageData,
    required this.onSendMessage,
    required this.onShowImageDialog,
    required this.onClearSelectedImage,
    required Widget child,
  }) : super(child: child);

  /// Get the state provider from the context
  static ChatInputStateProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ChatInputStateProvider>();
  }

  @override
  bool updateShouldNotify(ChatInputStateProvider oldWidget) {
    final bool shouldNotify = textController != oldWidget.textController ||
        focusNode != oldWidget.focusNode ||
        isLoading != oldWidget.isLoading ||
        isProcessingFile != oldWidget.isProcessingFile ||
        selectedImageData != oldWidget.selectedImageData ||
        onSendMessage != oldWidget.onSendMessage ||
        onShowImageDialog != oldWidget.onShowImageDialog ||
        onClearSelectedImage != oldWidget.onClearSelectedImage;

    print('=== StateProvider.updateShouldNotify ===');
    print(
        'selectedImageData changed: ${selectedImageData != oldWidget.selectedImageData}');
    print(
        '  new: ${selectedImageData?.substring(0, min(10, selectedImageData!.length)) ?? 'null'}...');
    print(
        '  old: ${oldWidget.selectedImageData?.substring(0, min(10, oldWidget.selectedImageData!.length)) ?? 'null'}...');
    print('shouldNotify: $shouldNotify');
    print('=======================================');

    return shouldNotify;
  }
}
