import 'package:flutter/material.dart';
import 'image_preview.dart';
import 'file_attachment_button.dart';
import 'chat_input_field.dart';
import 'send_button.dart';
import '../../widgets/simple_loading_line.dart';

/// Chat input row component that coordinates all input elements
/// Follows SRP by only coordinating the layout and state management
class ChatInputRow extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback onSendMessage;
  final VoidCallback onShowImageDialog;
  final VoidCallback onClearSelectedImage;
  final String? selectedImageData;
  final bool isLoading;
  final bool isProcessingFile;

  const ChatInputRow({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.onSendMessage,
    required this.onShowImageDialog,
    required this.onClearSelectedImage,
    required this.selectedImageData,
    required this.isLoading,
    required this.isProcessingFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 800 ? 24 : 16,
        vertical: 8,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(
          top: BorderSide(color: Color(0xFF333333)),
        ),
      ),
      child: Column(
        children: [
          // Ultra-thin loading line (appears above input text box)
          if (isLoading) const SimpleLoadingLine(),
          // Image preview when an image is selected
          ImagePreview(
            selectedImageData: selectedImageData,
            onClearImage: onClearSelectedImage,
          ),
          // Input row
          _buildInputRow(),
        ],
      ),
    );
  }

  Widget _buildInputRow() {
    return Row(
      children: [
        // File attachment button on the left
        FileAttachmentButton(
          onPressed: onShowImageDialog,
        ),
        const SizedBox(width: 12),
        // Text input in the middle with keyboard handling
        Expanded(
          child: SendKeyboardListener(
            child: ChatInputField(
              controller: textController,
              focusNode: focusNode,
              onTextChanged: () {
                // The send button will update automatically when the text changes
                // as the parent widget rebuilds
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Send button on the right
        SendButton(),
      ],
    );
  }
}
