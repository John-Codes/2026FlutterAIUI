import 'package:flutter/material.dart';
import '../input/chat_input_state_provider.dart';
import 'send_button.dart';
import 'file_attachment_section.dart';
import 'text_input.dart' as CustomTextInput;

/// Chat input row component that coordinates layout for input components
/// Arranges file attachment, text input, and send button horizontally
class ChatInputRow extends StatelessWidget {
  const ChatInputRow({super.key});

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
      child: Row(
        children: [
          // File attachment button on the left
          const SizedBox(
            width: 48,
            child: FileAttachmentSection(),
          ),
          const SizedBox(width: 12),
          // Expanded text input in the middle
          Expanded(
            child: SendKeyboardListener(
              child: CustomTextInput.TextInput(
                textController: stateProvider.textController,
                focusNode: stateProvider.focusNode,
                onSendMessage: stateProvider.onSendMessage,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Send button on the right
          const SendButton(),
        ],
      ),
    );
  }
}
