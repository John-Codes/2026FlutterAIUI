import 'package:flutter/material.dart';

/// File attachment button component that handles image selection
/// Follows SRP by only handling file attachment button functionality
class FileAttachmentButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FileAttachmentButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[700]!,
        borderRadius: BorderRadius.circular(25),
      ),
      child: IconButton(
        icon: const Icon(Icons.attach_file, color: Colors.white),
        onPressed: onPressed,
        tooltip: 'Attach image',
      ),
    );
  }
}
