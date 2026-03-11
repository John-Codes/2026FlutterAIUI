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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF404040)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Modern adaptive CircularProgressIndicator
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
