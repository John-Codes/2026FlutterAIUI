import 'package:flutter/material.dart';
import '../widgets/input/text_input.dart' as CustomTextInput;

class ChatTextInput extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback onSendMessage;

  const ChatTextInput({
    super.key,
    required this.textController,
    required this.focusNode,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextInput.TextInput(
      textController: textController,
      focusNode: focusNode,
      onSendMessage: onSendMessage,
    );
  }
}
