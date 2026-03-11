import 'package:flutter/material.dart';

/// Text input component that handles text input only
/// No send button - that's handled by the SendButton component
class TextInput extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback onSendMessage;

  const TextInput({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: 'Type a message...',
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      maxLines: null,
      minLines: 1,
      onChanged: (value) {
        // Trigger rebuild to update send button state
        (context as Element).markNeedsBuild();
      },
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          onSendMessage();
        }
      },
    );
  }
}
