import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/unified_image_picker_service.dart';
import '../../widgets/dialogs/unified_image_selection_dialog.dart';

/// Consolidated file attachment component that handles image preview, attachment button, and clear functionality
/// Follows SRP by only handling file attachment logic and UI
class ConsolidatedFileAttachmentButton extends StatefulWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback onSendMessage;
  final VoidCallback onShowImageDialog;
  final String? selectedImageData;
  final VoidCallback onClearSelectedImage;
  final bool isLoading;
  final bool isProcessingFile;

  const ConsolidatedFileAttachmentButton({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.onSendMessage,
    required this.onShowImageDialog,
    required this.selectedImageData,
    required this.onClearSelectedImage,
    required this.isLoading,
    required this.isProcessingFile,
  });

  @override
  State<ConsolidatedFileAttachmentButton> createState() =>
      _ConsolidatedFileAttachmentButtonState();
}

class _ConsolidatedFileAttachmentButtonState
    extends State<ConsolidatedFileAttachmentButton> {
  final UnifiedImagePickerService _imagePickerService =
      UnifiedImagePickerService();
  int _buildCount = 0;

  @override
  void dispose() {
    _imagePickerService.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      setState(() {
        // Start processing
      });

      final imageData = await _imagePickerService.pickImageFromGallery(context);

      if (imageData != null) {
        widget.onClearSelectedImage(); // Clear previous image
        widget.onShowImageDialog(); // Show dialog to handle the new image
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      setState(() {
        // Start processing
      });

      final imageData = await _imagePickerService.pickImageFromCamera(context);

      if (imageData != null) {
        widget.onClearSelectedImage(); // Clear previous image
        widget.onShowImageDialog(); // Show dialog to handle the new image
      }
    } catch (e) {
      _showErrorSnackBar('Error capturing photo: $e');
    }
  }

  void _showImageDialog() {
    widget.onShowImageDialog();
  }

  void _clearSelectedImage() {
    print('=== _clearSelectedImage called ===');
    print('Before - hasImage: ${widget.selectedImageData != null}');
    print('Build count: $_buildCount');

    widget.onClearSelectedImage();

    print('After - hasImage: ${widget.selectedImageData != null}');
    print('=================================');

    // Force rebuild to ensure UI updates
    setState(() {
      _buildCount++;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    print('=== Build #$_buildCount ===');
    print('hasImage: ${widget.selectedImageData != null}');
    print(
        'showPreview: ${widget.selectedImageData != null && !widget.isLoading && !widget.isProcessingFile}');
    print('selectedImageData length: ${widget.selectedImageData?.length ?? 0}');
    print('================================');
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
          // Image preview when an image is selected
          if (widget.selectedImageData != null &&
              !widget.isLoading &&
              !widget.isProcessingFile)
            _buildImagePreview(),
          // Input row
          _buildInputRow(),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Image preview
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              base64Decode(widget.selectedImageData!),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[800],
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.white70),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Image info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Image Selected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Click send to attach with message',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Clear button
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: widget.isLoading || widget.isProcessingFile
                ? null
                : _clearSelectedImage,
            tooltip: 'Clear image',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow() {
    return Row(
      children: [
        // File attachment button on the left
        Container(
          decoration: BoxDecoration(
            color: widget.isLoading || widget.isProcessingFile
                ? Colors.grey[600]!
                : Colors.grey[700]!,
            borderRadius: BorderRadius.circular(25),
          ),
          child: IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.white),
            onPressed: widget.isLoading || widget.isProcessingFile
                ? null
                : _showImageDialog,
            tooltip: 'Attach image',
          ),
        ),
        const SizedBox(width: 12),
        // Expanded text input in the middle
        Expanded(
          child: TextField(
            controller: widget.textController,
            focusNode: widget.focusNode,
            enabled: !widget.isLoading && !widget.isProcessingFile,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: widget.isLoading || widget.isProcessingFile
                  ? 'Processing...'
                  : 'Type a message...',
              hintStyle: TextStyle(
                color: widget.isLoading || widget.isProcessingFile
                    ? Colors.grey[500]
                    : Colors.grey[400],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: widget.isLoading || widget.isProcessingFile
                  ? const Color(0xFF3A3A3A)
                  : const Color(0xFF2A2A2A),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            style: const TextStyle(color: Colors.white),
            maxLines: null,
            minLines: 1,
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        const SizedBox(width: 12),
        // Send button on the right
        Container(
          decoration: BoxDecoration(
            color: widget.isLoading || widget.isProcessingFile
                ? Colors.grey[600]!
                : (widget.textController.text.trim().isNotEmpty
                    ? Colors.blue[700]!
                    : Colors.grey[600]!),
            borderRadius: BorderRadius.circular(25),
          ),
          child: widget.isLoading || widget.isProcessingFile
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: widget.textController.text.trim().isEmpty ||
                          widget.isLoading ||
                          widget.isProcessingFile
                      ? null
                      : widget.onSendMessage,
                  tooltip: 'Send message',
                ),
        ),
      ],
    );
  }
}
