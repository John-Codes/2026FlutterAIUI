import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chat_input_state_provider.dart';
import 'file_attachment_section.dart';
import 'text_input.dart' as input;
import 'send_button.dart';

/// Main chat input container that orchestrates all input components
/// Follows SRP by only handling container logic and coordination
class ChatInputContainer extends StatelessWidget {
  const ChatInputContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final stateProvider = ChatInputStateProvider.of(context);
    if (stateProvider == null) {
      return const SizedBox.shrink();
    }

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
          // File attachment section (handles image preview and attachment button)
          const FileAttachmentSection(),

          // Input row (text input and send button)
          Row(
            children: [
              // Text input component wrapped in keyboard listener
              Expanded(
                child: SendKeyboardListener(
                  child: input.TextInput(
                    textController: stateProvider.textController,
                    focusNode: stateProvider.focusNode,
                    onSendMessage: stateProvider.onSendMessage,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Send button component
              const SendButton(),
            ],
          ),
        ],
      ),
    );
  }
}
