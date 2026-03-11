import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Service class that handles all image picking logic
/// Follows SRP by only handling image selection and processing
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  /// Clean up resources
  void dispose() {
    _cameraController?.dispose();
  }

  /// Pick image from gallery
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        return base64Encode(bytes);
      }
      return null;
    } catch (e) {
      throw Exception('Error picking image from gallery: $e');
    }
  }

  /// Pick image from camera
  Future<String?> pickImageFromCamera(BuildContext context) async {
    try {
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

      if (_isCameraInitialized && _cameraController!.value.isInitialized) {
        final XFile? photo = await showDialog<XFile>(
          context: context,
          builder: (context) => _CameraDialog(controller: _cameraController!),
        );

        if (photo != null) {
          final bytes = await photo.readAsBytes();
          return base64Encode(bytes);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error capturing photo: $e');
    }
  }

  /// Initialize camera without capturing
  Future<void> initializeCamera() async {
    if (!_isCameraInitialized) {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras[0],
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        _isCameraInitialized = true;
      }
    }
  }

  /// Check if camera is initialized
  bool get isCameraInitialized => _isCameraInitialized;
}

/// Camera dialog widget (moved from separate file to be co-located with service)
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
