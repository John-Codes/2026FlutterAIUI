import 'package:flutter/material.dart';

class UrlDialog extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onConfirm;

  const UrlDialog({
    super.key,
    required this.controller,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Image URL'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Paste image URL here',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final url = controller.text.trim();
            if (url.isNotEmpty) {
              onConfirm();
            }
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
