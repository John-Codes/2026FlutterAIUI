import 'package:flutter/material.dart';
import '../widgets/input/image_input.dart';

class ChatImageInput extends StatelessWidget {
  final String? selectedImageData;
  final VoidCallback onShowImageDialog;
  final VoidCallback onClearSelectedImage;

  const ChatImageInput({
    super.key,
    required this.selectedImageData,
    required this.onShowImageDialog,
    required this.onClearSelectedImage,
  });

  @override
  Widget build(BuildContext context) {
    return ImageInput(
      selectedImageData: selectedImageData,
      onShowImageDialog: onShowImageDialog,
      onClearSelectedImage: onClearSelectedImage,
    );
  }
}
