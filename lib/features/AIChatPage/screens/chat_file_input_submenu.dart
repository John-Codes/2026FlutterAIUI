import 'package:flutter/material.dart';

class ChatFileInputSubmenu extends StatelessWidget {
  final VoidCallback onPickFromGallery;
  final VoidCallback onPickFromCamera;
  final VoidCallback onUseUrl;

  const ChatFileInputSubmenu({
    super.key,
    required this.onPickFromGallery,
    required this.onPickFromCamera,
    required this.onUseUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.image),
          title: const Text('Pick from Gallery'),
          onTap: () {
            Navigator.pop(context);
            onPickFromGallery();
          },
        ),
        ListTile(
          leading: const Icon(Icons.camera_alt),
          title: const Text('Take Photo'),
          onTap: () {
            Navigator.pop(context);
            onPickFromCamera();
          },
        ),
        ListTile(
          leading: const Icon(Icons.link),
          title: const Text('Use URL'),
          onTap: () {
            Navigator.pop(context);
            onUseUrl();
          },
        ),
      ],
    );
  }
}
