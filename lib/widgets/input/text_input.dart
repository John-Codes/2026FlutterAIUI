import 'package:flutter/material.dart';

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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 800 ? 24 : 16,
        vertical: 8,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(
          top: BorderSide(color: Color(0xFF333333)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
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
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed:
                  textController.text.trim().isNotEmpty ? onSendMessage : null,
              tooltip: 'Send message',
            ),
          ),
        ],
      ),
    );
  }
}
