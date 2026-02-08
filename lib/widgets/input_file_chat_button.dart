import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import '../../widgets/loading/file_loading_indicator.dart';

class inputFileChatButton extends StatefulWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback onSendMessage;
  final VoidCallback onShowImageDialog;
  final String? selectedImageData;
  final VoidCallback onClearSelectedImage;
  final bool isLoading;

  const inputFileChatButton({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.onSendMessage,
    required this.onShowImageDialog,
    required this.selectedImageData,
    required this.onClearSelectedImage,
    required this.isLoading,
  });

  @override
  State<inputFileChatButton> createState() => _inputFileChatButtonState();
}

class _inputFileChatButtonState extends State<inputFileChatButton> {
  final ImagePicker _picker = ImagePicker();
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() {
      // We'll use a loading state to prevent interactions during processing
    });

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Simulate processing time for the image
        await Future.delayed(const Duration(milliseconds: 500));

        setState(() {
          widget.textController.text += ' [Image: ${image.name}] ';
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      setState(() {
        // We'll use a loading state to prevent interactions during processing
      });

      if (!_isCameraInitialized) {
        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          _cameraController =
              CameraController(cameras[0], ResolutionPreset.high);
          await _cameraController!.initialize();
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }

      if (_isCameraInitialized && _cameraController!.value.isInitialized) {
        final XFile? image = await _cameraController!.takePicture();
        if (image != null) {
          // Simulate processing time for the camera image
          await Future.delayed(const Duration(milliseconds: 500));

          setState(() {
            widget.textController.text += ' [Camera Image: ${image.name}] ';
          });
        }
      }
    } catch (e) {
      print('Error taking picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error taking picture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageDialog() {
    widget.onShowImageDialog();
  }

  void _clearSelectedImage() {
    print('_clearSelectedImage called');
    widget.onClearSelectedImage();
    // Force a rebuild to update the UI immediately
    setState(() {});
    // Also clear the text field if it contains image placeholder
    if (widget.textController.text.contains('[Image:')) {
      widget.textController.clear();
    }
    print('After clear - selectedImageData: ${widget.selectedImageData}');
  }

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
          // Temporarily disabled loading indicator to test layout issue
          // if (widget.isLoading)
          //   const FileLoadingIndicator(
          //     message: 'Processing image...',
          //     showProgress: true,
          //   ),
          // Image preview when an image is selected
          if (widget.selectedImageData != null && !widget.isLoading)
            Container(
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
                    onPressed: widget.isLoading ? null : _clearSelectedImage,
                    tooltip: 'Clear image',
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          // Input row
          Row(
            children: [
              // File attachment button on the left
              Container(
                decoration: BoxDecoration(
                  color:
                      widget.isLoading ? Colors.grey[600]! : Colors.grey[700]!,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.white),
                  onPressed: widget.isLoading ? null : _showImageDialog,
                  tooltip: 'Attach image',
                ),
              ),
              const SizedBox(width: 12),
              // Expanded text input in the middle
              Expanded(
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) {
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.enter) {
                      // Check if shift is pressed
                      final isShiftPressed =
                          event.logicalKey == LogicalKeyboardKey.shiftLeft ||
                              event.logicalKey == LogicalKeyboardKey.shiftRight;

                      if (isShiftPressed) {
                        // Shift+Enter: Insert newline manually
                        final currentText = widget.textController.text;
                        final selection = widget.textController.selection;

                        widget.textController.text =
                            currentText.substring(0, selection.start) +
                                '\n' +
                                currentText.substring(selection.end);

                        widget.textController.selection =
                            TextSelection.collapsed(
                                offset: selection.start + 1);
                      } else {
                        // Enter: Send message
                        if (!widget.isLoading) {
                          widget.onSendMessage();
                        }
                      }
                    }
                  },
                  child: TextField(
                    controller: widget.textController,
                    focusNode: widget.focusNode,
                    enabled: !widget.isLoading,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: widget.isLoading
                          ? 'Processing...'
                          : 'Type a message...',
                      hintStyle: TextStyle(
                        color: widget.isLoading
                            ? Colors.grey[500]
                            : Colors.grey[400],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: widget.isLoading
                          ? const Color(0xFF3A3A3A)
                          : const Color(0xFF2A2A2A),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    maxLines: null,
                    minLines: 1,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Send button on the right
              Container(
                decoration: BoxDecoration(
                  color: widget.isLoading
                      ? Colors.grey[600]!
                      : (widget.textController.text.trim().isNotEmpty
                          ? Colors.blue[700]!
                          : Colors.grey[600]!),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: widget.textController.text.trim().isEmpty
                            ? null
                            : widget.onSendMessage,
                        tooltip: 'Send message',
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
