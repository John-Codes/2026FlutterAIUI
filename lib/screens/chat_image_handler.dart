import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:camera/camera.dart';
import '../widgets/dialogs/camera_dialog.dart';
import '../widgets/dialogs/image_selection_dialog.dart';
import '../widgets/dialogs/url_dialog.dart';

class ChatImageHandler {
  final Function(String?) onImageSelected;
  final Function() onShowImageDialog;
  final Function() onClearSelectedImage;
  final Function(bool) onProcessingStateChanged;
  final BuildContext context;

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
      XFile? pickedFile;

      // Use file_selector for both web and mobile (it has better web support)
      const typeGroup = XTypeGroup(
        label: 'Images',
        extensions: <String>['jpg', 'jpeg', 'png'],
        mimeTypes: <String>['image/jpeg', 'image/png'],
      );

      try {
        // Try using file_selector first (works on both web and mobile)
        pickedFile = await openFile(
          acceptedTypeGroups: <XTypeGroup>[typeGroup],
          initialDirectory: '/',
        );
      } catch (e) {
        // Fallback to image_picker for mobile platforms
        final picker = ImagePicker();
        pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1024,
          maxHeight: 1024,
        );
      }

      if (pickedFile != null) {
        // Read file bytes
        final bytes = await pickedFile.readAsBytes();

        // Convert to base64
        String base64Image = base64Encode(bytes);

        // Processing complete - hide loading indicator and set image
        onProcessingStateChanged(false);
        onImageSelected(base64Image);
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
      // Initialize camera
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      // Use the first available camera (usually back camera)
      final camera = cameras.first;

      // Get a specific controller
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      // Initialize the controller
      await controller.initialize();

      // Show camera dialog
      final XFile? photo = await showDialog<XFile>(
        context: context,
        builder: (context) => CameraDialog(controller: controller),
      );

      // Dispose controller
      await controller.dispose();

      if (photo != null) {
        // Read file bytes
        final bytes = await photo.readAsBytes();

        // Convert to base64
        String base64Image = base64Encode(bytes);

        // Processing complete - hide loading indicator and set image
        onProcessingStateChanged(false);
        onImageSelected(base64Image);
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
      builder: (context) => ImageSelectionDialog(
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
}
