import 'package:flutter/material.dart';

/// General loading indicator that shows appropriate messages based on context
/// Follows SRP by only handling loading display logic
class GeneralLoadingIndicator extends StatelessWidget {
  final bool isLoading;
  final bool isProcessingFile;
  final String? customMessage;

  const GeneralLoadingIndicator({
    super.key,
    required this.isLoading,
    required this.isProcessingFile,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    // Only show if either loading state is true
    if (!isLoading && !isProcessingFile) {
      return const SizedBox.shrink();
    }

    // Determine the appropriate message
    String message;
    if (customMessage != null) {
      message = customMessage!;
    } else if (isProcessingFile) {
      message = 'Processing image...';
    } else if (isLoading) {
      message = 'Sending message...';
    } else {
      message = 'Loading...';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              shape: BoxShape.circle,
            ),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
