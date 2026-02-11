import 'package:flutter/material.dart';

/// File attachment button component that handles image selection
/// Follows SRP by only handling file attachment button functionality
class FileAttachmentButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isProcessingFile;

  const FileAttachmentButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.isProcessingFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isLoading || isProcessingFile
            ? Colors.grey[600]!
            : Colors.grey[700]!,
        borderRadius: BorderRadius.circular(25),
      ),
      child: IconButton(
        icon: const Icon(Icons.attach_file, color: Colors.white),
        onPressed: isLoading || isProcessingFile ? null : onPressed,
        tooltip: 'Attach image',
      ),
    );
  }
}
