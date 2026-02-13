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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF404040)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Modern animated dots
          _buildAnimatedDots(),
          const SizedBox(width: 16),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.blue[400],
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
