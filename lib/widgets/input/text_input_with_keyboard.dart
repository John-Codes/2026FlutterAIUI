import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextInputWithKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSendMessage;
  final bool isLoading;
  final String? hintText;

  const TextInputWithKeyboard({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSendMessage,
    required this.isLoading,
    this.hintText,
  });

  @override
  State<TextInputWithKeyboard> createState() => _TextInputWithKeyboardState();
}

class _TextInputWithKeyboardState extends State<TextInputWithKeyboard> {
  late final FocusNode _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _internalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: !widget.isLoading,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'Type a message...',
        hintStyle: TextStyle(
          color: widget.isLoading ? Colors.grey[500] : Colors.grey[400],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: widget.isLoading
            ? const Color(0xFF3A3A3A)
            : const Color(0xFF2A2A2A),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      maxLines: null,
      minLines: 1,
      onChanged: (value) {
        setState(() {});
      },
      onSubmitted: (value) {
        // Handle Enter key (without Shift) to send message
        if (!widget.isLoading) {
          widget.onSendMessage();
        }
      },
    );
  }
}
