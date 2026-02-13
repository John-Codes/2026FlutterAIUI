import 'dart:convert';
import 'package:flutter/material.dart';
import '../input/chat_input_state_provider.dart';

/// File attachment section component with file logic only
/// Handles image preview, attachment button, and clear functionality
class FileAttachmentSection extends StatelessWidget {
  const FileAttachmentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stateProvider = ChatInputStateProvider.of(context);
    if (stateProvider == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Image preview when an image is selected
        if (stateProvider.selectedImageData != null)
          _buildImagePreview(stateProvider),
        // Attachment button
        _buildAttachmentButton(stateProvider),
      ],
    );
  }

  Widget _buildImagePreview(ChatInputStateProvider stateProvider) {
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
              base64Decode(stateProvider.selectedImageData!),
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
          Flexible(
            fit: FlexFit.loose,
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
            onPressed: stateProvider.isLoading || stateProvider.isProcessingFile
                ? null
                : () {
                    stateProvider.onClearSelectedImage();
                    // Also clear the text field if it contains image placeholder
                    if (stateProvider.textController.text.contains('[Image:')) {
                      stateProvider.textController.clear();
                    }
                  },
            tooltip: 'Clear image',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton(ChatInputStateProvider stateProvider) {
    return Container(
      decoration: BoxDecoration(
        color: stateProvider.isLoading || stateProvider.isProcessingFile
            ? Colors.grey[600]!
            : Colors.grey[700]!,
        borderRadius: BorderRadius.circular(25),
      ),
      child: IconButton(
        icon: const Icon(Icons.attach_file, color: Colors.white),
        onPressed: stateProvider.isLoading || stateProvider.isProcessingFile
            ? null
            : stateProvider.onShowImageDialog,
        tooltip: 'Attach image',
      ),
    );
  }
}
