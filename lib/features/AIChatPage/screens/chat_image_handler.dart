import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/unified_image_picker_service.dart';
import '../widgets/dialogs/unified_image_selection_dialog.dart';
import '../widgets/dialogs/url_dialog.dart';

/// Unified handler for image selection operations
/// Follows SRP by only handling image selection coordination
class ChatImageHandler {
  final Function(String?) onImageSelected;
  final Function() onShowImageDialog;
  final Function() onClearSelectedImage;
  final Function(bool) onProcessingStateChanged;
  final BuildContext context;

  final UnifiedImagePickerService _imagePickerService =
      UnifiedImagePickerService();

  ChatImageHandler({
    required this.onImageSelected,
    required this.onShowImageDialog,
    required this.onClearSelectedImage,
    required this.onProcessingStateChanged,
    required this.context,
  });

  Future<void> pickImage() async {
    // Start processing - show loading indicator
    onProcessingStateChanged(true);

    try {
      final imageData = await _imagePickerService.pickImageFromGallery(context);

      if (imageData != null) {
        // Processing complete - hide loading indicator and set image
        onProcessingStateChanged(false);
        onImageSelected(imageData);
      } else {
        // User cancelled - hide loading indicator
        onProcessingStateChanged(false);
      }
    } catch (e) {
      // Processing failed - hide loading indicator
      onProcessingStateChanged(false);

      // Add error message to chat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> pickImageFromCamera() async {
    // Start processing - show loading indicator
    onProcessingStateChanged(true);

    try {
      final imageData = await _imagePickerService.pickImageFromCamera(context);

      if (imageData != null) {
        // Processing complete - hide loading indicator and set image
        onProcessingStateChanged(false);
        onImageSelected(imageData);
      } else {
        // User cancelled - hide loading indicator
        onProcessingStateChanged(false);
      }
    } catch (e) {
      // Processing failed - hide loading indicator
      onProcessingStateChanged(false);

      // Add error message to chat
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing photo: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showImageDialog() {
    showDialog(
      context: context,
      builder: (context) => UnifiedImageSelectionDialog(
        onPickFromGallery: pickImage,
        onPickFromCamera: pickImageFromCamera,
        onUseUrl: showUrlDialog,
      ),
    );
  }

  void showUrlDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => UrlDialog(
        controller: controller,
        onConfirm: () {
          final url = controller.text.trim();
          if (url.isNotEmpty) {
            onImageSelected(null); // Clear local image when using URL
            // Note: The URL handling should be managed by the parent component
          }
        },
      ),
    );
  }

  void dispose() {
    _imagePickerService.dispose();
  }
}
