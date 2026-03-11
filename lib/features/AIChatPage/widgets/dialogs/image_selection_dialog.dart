import 'package:flutter/material.dart';

class ImageSelectionDialog extends StatelessWidget {
  final VoidCallback onPickFromGallery;
  final VoidCallback onPickFromCamera;
  final VoidCallback onUseUrl;

  const ImageSelectionDialog({
    super.key,
    required this.onPickFromGallery,
    required this.onPickFromCamera,
    required this.onUseUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Image'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(context);
              onPickFromGallery();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo from Camera'),
            onTap: () {
              Navigator.pop(context);
              onPickFromCamera();
            },
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Use Image URL'),
            onTap: () {
              Navigator.pop(context);
              onUseUrl();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
