import 'package:flutter/material.dart';

/// Unified dialog for image selection options
/// Follows SRP by only handling dialog UI and navigation
class UnifiedImageSelectionDialog extends StatelessWidget {
  final VoidCallback onPickFromGallery;
  final VoidCallback onPickFromCamera;
  final VoidCallback onUseUrl;

  const UnifiedImageSelectionDialog({
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
          _buildOptionTile(
            icon: Icons.image,
            title: 'Choose from Gallery',
            subtitle: 'Select an image from your device',
            onTap: () {
              Navigator.pop(context);
              onPickFromGallery();
            },
          ),
          const SizedBox(height: 8),
          _buildOptionTile(
            icon: Icons.camera_alt,
            title: 'Take Photo',
            subtitle: 'Capture a new photo with camera',
            onTap: () {
              Navigator.pop(context);
              onPickFromCamera();
            },
          ),
          const SizedBox(height: 8),
          _buildOptionTile(
            icon: Icons.link,
            title: 'Use URL',
            subtitle: 'Add image from web URL',
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

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[400]),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }
}
