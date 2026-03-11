import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'chat_state.dart';
import 'chat_ui.dart';
import 'chat_image_handler.dart';
import 'settings_screen.dart';
import '../widgets/input/consolidated_file_attachment_button.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatState _chatState;
  late final ChatImageHandler _imageHandler;

  @override
  void initState() {
    super.initState();
    _chatState = ChatState();
    _chatState.initialize();
    _imageHandler = ChatImageHandler(
      onImageSelected: _handleImageSelected,
      onShowImageDialog: _showImageDialog,
      onClearSelectedImage: _chatState.clearSelectedImage,
      onProcessingStateChanged: _setProcessingFileState,
      context: context,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to chat state changes
    _chatState.addListener(() {
      setState(() {});
    });
  }

  void _handleImageSelected(String? imageData) {
    _chatState.selectedImageData = imageData;
    _chatState.imageUrl = null;
    setState(() {});
  }

  void _setProcessingFileState(bool isProcessing) {
    _chatState.isProcessingFile = isProcessing;
    setState(() {});
  }

  void _showImageDialog() {
    _imageHandler.showImageDialog();
  }

  @override
  Widget build(BuildContext context) {
    return ChatUI(
      messages: _chatState.messages,
      isLoading: _chatState.isLoading,
      textController: _chatState.textController,
      focusNode: _chatState.focusNode,
      onSendMessage: () => _handleSendMessage(),
      onShowImageDialog: _showImageDialog,
      selectedImageData: _chatState.selectedImageData,
      onClearSelectedImage: _chatState.clearSelectedImage,
      isProcessingFile: _chatState.isProcessingFile,
      scaffoldKey: _chatState.scaffoldKey,
    );
  }

  Future<void> _handleSendMessage() async {
    await _chatState.sendMessage();
    setState(() {}); // Trigger UI update after message is sent
  }

  @override
  void dispose() {
    _chatState.dispose();
    super.dispose();
  }
}
