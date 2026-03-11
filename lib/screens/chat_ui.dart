import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../widgets/message_widget.dart';
import '../widgets/input/chat_input_row.dart';
import '../widgets/input/chat_input_state_provider.dart';
import 'settings_screen.dart';
import 'chat_drawer_menu.dart';
import '../services/auth_state_service.dart';

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
  final _authService = AuthStateService();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    // Show authentication overlay if not authenticated
    if (!_authService.isAuthenticated) {
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
        drawer: ChatDrawerMenu(
          onNavigateToSettings: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
          onSignOut: () {
            // No-op since user is not authenticated
          },
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to AI Chat',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please sign in to start chatting',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/sign_in');
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/sign_up');
                  },
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
      drawer: ChatDrawerMenu(
        onNavigateToSettings: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SettingsScreen(),
            ),
          );
        },
        onSignOut: () {
          Navigator.pushReplacementNamed(context, '/');
        },
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
              itemCount: widget.messages.length,
              itemBuilder: (context, index) {
                final message = widget.messages[index];
                return MessageWidget(
                  message: message,
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
                return ChatInputRow(
                  textController: stateProvider.textController,
                  focusNode: stateProvider.focusNode,
                  onSendMessage: stateProvider.onSendMessage,
                  onShowImageDialog: stateProvider.onShowImageDialog,
                  onClearSelectedImage: stateProvider.onClearSelectedImage,
                  selectedImageData: stateProvider.selectedImageData,
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
