import 'dart:convert';
import 'package:flutter/material.dart';

/// Image preview component that displays selected image with clear functionality
/// Follows SRP by only handling image preview display and management
class ImagePreview extends StatelessWidget {
  final String? selectedImageData;
  final VoidCallback onClearImage;

  const ImagePreview({
    super.key,
    required this.selectedImageData,
    required this.onClearImage,
  });

  @override
  Widget build(BuildContext context) {
    // Show image preview if image is selected
    if (selectedImageData == null) {
      return const SizedBox.shrink();
    }

    return _buildImagePreview();
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Image preview
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              base64Decode(selectedImageData!),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[800],
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.white70),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Image info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Image Selected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Click send to attach with message',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Clear button
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: onClearImage,
            tooltip: 'Clear image',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
