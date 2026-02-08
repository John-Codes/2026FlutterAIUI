import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../widgets/message_widget.dart' as message_widgets;
import '../widgets/message/loading_indicator.dart';
import '../widgets/input/chat_input_row.dart';
import '../widgets/input/chat_input_state_provider.dart';
import '../widgets/input/consolidated_file_attachment_button.dart';

class ChatUI extends StatefulWidget {
  final List<ChatMessage> messages;
  final bool isLoading;
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback onSendMessage;
  final VoidCallback onShowImageDialog;
  final String? selectedImageData;
  final VoidCallback onClearSelectedImage;
  final bool isProcessingFile;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ChatUI({
    super.key,
    required this.messages,
    required this.isLoading,
    required this.textController,
    required this.focusNode,
    required this.onSendMessage,
    required this.onShowImageDialog,
    required this.selectedImageData,
    required this.onClearSelectedImage,
    required this.isProcessingFile,
    required this.scaffoldKey,
  });

  @override
  State<ChatUI> createState() => _ChatUIState();
}

class _ChatUIState extends State<ChatUI> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      key: widget.scaffoldKey,
      appBar: AppBar(
        title: const Text('AI Chat'),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF121212),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
              ),
              child: Text(
                'AI Chat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.white),
              title: const Text('Chat', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title:
                  const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings screen
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(
                bottom: isDesktop ? 100 : 80,
                left: isDesktop ? 24 : 16,
                right: isDesktop ? 24 : 16,
                top: 16,
              ),
              itemCount: widget.messages.length + (widget.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == widget.messages.length && widget.isLoading) {
                  return const LoadingIndicator();
                }
                final message = widget.messages[index];
                return message_widgets.MessageWidget(
                  message: {
                    'content': message.text,
                    'image_data': message.imageData,
                    'timestamp': message.timestamp,
                  },
                  isUser: message.isUser,
                );
              },
            ),
          ),
          ChatInputStateProvider(
            textController: widget.textController,
            focusNode: widget.focusNode,
            isLoading: widget.isLoading,
            isProcessingFile: widget.isProcessingFile,
            selectedImageData: widget.selectedImageData,
            onSendMessage: widget.onSendMessage,
            onShowImageDialog: widget.onShowImageDialog,
            onClearSelectedImage: widget.onClearSelectedImage,
            child: Builder(
              builder: (context) {
                final stateProvider = ChatInputStateProvider.of(context);
                if (stateProvider == null) {
                  return const SizedBox.shrink();
                }
                return ConsolidatedFileAttachmentButton(
                  textController: stateProvider.textController,
                  focusNode: stateProvider.focusNode,
                  onSendMessage: stateProvider.onSendMessage,
                  onShowImageDialog: stateProvider.onShowImageDialog,
                  selectedImageData: stateProvider.selectedImageData,
                  onClearSelectedImage: stateProvider.onClearSelectedImage,
                  isLoading: stateProvider.isLoading,
                  isProcessingFile: stateProvider.isProcessingFile,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
