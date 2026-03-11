import 'package:flutter/material.dart';

class ChatFileInputButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ChatFileInputButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.attach_file),
      onPressed: onPressed,
      tooltip: 'Add image or file',
    );
  }
}
