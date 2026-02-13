import 'package:flutter/material.dart';

/// Chat input field component that handles text input
/// Follows SRP by only handling text input field functionality
class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onTextChanged;
  final bool isLoading;
  final bool isProcessingFile;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onTextChanged,
    required this.isLoading,
    required this.isProcessingFile,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: !isLoading && !isProcessingFile,
      textInputAction:
          TextInputAction.newline, // Allow newlines with Shift+Enter
      decoration: InputDecoration(
        hintText: isLoading || isProcessingFile
            ? 'Processing...'
            : 'Type a message...',
        hintStyle: TextStyle(
          color: isLoading || isProcessingFile
              ? Colors.grey[500]
              : Colors.grey[400],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: isLoading || isProcessingFile
            ? const Color(0xFF3A3A3A)
            : const Color(0xFF2A2A2A),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      style: const TextStyle(color: Colors.white),
      maxLines: null,
      minLines: 1,
      onChanged: (value) {
        // Trigger rebuild to update send button state
        if (context.mounted) {
          (context as Element).markNeedsBuild();
        }
      },
      // Remove onSubmitted to avoid conflicts with SendKeyboardListener
    );
  }
}
