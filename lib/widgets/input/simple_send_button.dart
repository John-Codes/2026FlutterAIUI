import 'package:flutter/material.dart';

/// Simple send button component that takes required parameters directly
/// Follows SRP by only handling send button functionality
class SimpleSendButton extends StatelessWidget {
  final TextEditingController textController;
  final VoidCallback onSendMessage;
  final bool isLoading;
  final bool isProcessingFile;

  const SimpleSendButton({
    super.key,
    required this.textController,
    required this.onSendMessage,
    required this.isLoading,
    required this.isProcessingFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isLoading || isProcessingFile
            ? Colors.grey[600]!
            : (textController.text.trim().isNotEmpty
                ? Colors.blue[700]!
                : Colors.grey[600]!),
        borderRadius: BorderRadius.circular(25),
      ),
      child: IconButton(
        icon: const Icon(Icons.send, color: Colors.white),
        onPressed: (textController.text.trim().isNotEmpty &&
                !isLoading &&
                !isProcessingFile)
            ? onSendMessage
            : null,
        tooltip: 'Send message',
      ),
    );
  }
}
