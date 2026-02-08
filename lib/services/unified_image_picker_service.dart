import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:file_selector/file_selector.dart';

/// Unified service that handles all image selection logic
/// Follows SRP by only handling image selection and processing
class UnifiedImagePickerService {
  final ImagePicker _picker = ImagePicker();
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  /// Clean up resources
  void dispose() {
    _cameraController?.dispose();
    _isCameraInitialized = false;
  }

  /// Pick image from gallery with fallback mechanisms
  Future<String?> pickImageFromGallery(BuildContext context) async {
    try {
      XFile? pickedFile;

      // Try using file_selector first (works on both web and mobile)
      try {
        const typeGroup = XTypeGroup(
          label: 'Images',
          extensions: <String>['jpg', 'jpeg', 'png'],
          mimeTypes: <String>['image/jpeg', 'image/png'],
        );

        pickedFile = await openFile(
          acceptedTypeGroups: <XTypeGroup>[typeGroup],
          initialDirectory: '/',
        );
      } catch (e) {
        // Fallback to image_picker for mobile platforms
        pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1024,
          maxHeight: 1024,
        );
      }

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        return base64Encode(bytes);
      }
      return null;
    } catch (e) {
      throw Exception('Error picking image from gallery: $e');
    }
  }

  /// Pick image from camera with proper initialization
  Future<String?> pickImageFromCamera(BuildContext context) async {
    try {
      // Initialize camera if not already done
      if (!_isCameraInitialized) {
        final cameras = await availableCameras();
        if (cameras.isEmpty) {
          throw Exception('No cameras available');
        }

        _cameraController = CameraController(
          cameras[0],
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        _isCameraInitialized = true;
      }

      // Show camera dialog and capture image
      final XFile? photo = await _showCameraDialog(context);

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        return base64Encode(bytes);
      }
      return null;
    } catch (e) {
      throw Exception('Error capturing photo: $e');
    }
  }

  /// Show camera dialog for image capture
  Future<XFile?> _showCameraDialog(BuildContext context) async {
    if (_cameraController == null || !_isCameraInitialized) {
      throw Exception('Camera not initialized');
    }

    return await showDialog<XFile>(
      context: context,
      builder: (context) => _CameraDialog(controller: _cameraController!),
    );
  }

  /// Check if camera is initialized
  bool get isCameraInitialized => _isCameraInitialized;
}

/// Camera dialog widget - moved here to be co-located with service
class _CameraDialog extends StatefulWidget {
  final CameraController controller;

  const _CameraDialog({required this.controller});

  @override
  State<_CameraDialog> createState() => _CameraDialogState();
}

class _CameraDialogState extends State<_CameraDialog> {
  @override
  void dispose() {
    // Don't dispose here - the service will handle it
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Camera preview
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            child: CameraPreview(widget.controller),
          ),
          const SizedBox(height: 20),
          // Capture button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final XFile image = await widget.controller.takePicture();
                    Navigator.pop(context, image);
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Failed to capture image: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.camera),
                label: const Text('Capture'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
              const SizedBox(width: 20),
              // Cancel button
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
