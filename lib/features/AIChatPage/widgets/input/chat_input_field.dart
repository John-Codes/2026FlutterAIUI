import 'package:flutter/material.dart';

/// Chat input field component that handles text input
/// Follows SRP by only handling text input field functionality
class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onTextChanged;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: true,
      textInputAction:
          TextInputAction.newline, // Allow newlines with Shift+Enter
      decoration: InputDecoration(
        hintText: 'Type a message...',
        hintStyle: TextStyle(
          color: Colors.grey[400],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
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
