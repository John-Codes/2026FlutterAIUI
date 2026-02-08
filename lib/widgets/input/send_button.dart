import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../input/chat_input_state_provider.dart';

/// Send button component with send logic only
/// Handles keyboard events, button state, and send callback
class SendButton extends StatefulWidget {
  const SendButton({super.key});

  @override
  State<SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<SendButton> {
  @override
  Widget build(BuildContext context) {
    final stateProvider = ChatInputStateProvider.of(context);
    if (stateProvider == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: stateProvider.isLoading || stateProvider.isProcessingFile
            ? Colors.grey[600]!
            : (stateProvider.textController.text.trim().isNotEmpty
                ? Colors.blue[700]!
                : Colors.grey[600]!),
        borderRadius: BorderRadius.circular(25),
      ),
      child: stateProvider.isLoading || stateProvider.isProcessingFile
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
              onPressed: stateProvider.textController.text.trim().isEmpty
                  ? null
                  : stateProvider.onSendMessage,
              tooltip: 'Send message',
            ),
    );
  }
}

/// Keyboard listener widget for send functionality
class SendKeyboardListener extends StatefulWidget {
  final Widget child;

  const SendKeyboardListener({
    super.key,
    required this.child,
  });

  @override
  State<SendKeyboardListener> createState() => _SendKeyboardListenerState();
}

class _SendKeyboardListenerState extends State<SendKeyboardListener> {
  @override
  Widget build(BuildContext context) {
    final stateProvider = ChatInputStateProvider.of(context);
    if (stateProvider == null) {
      return widget.child;
    }

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.enter) {
          // Check if shift is pressed - if shift is pressed, allow new line
          final isShiftPressed = HardwareKeyboard.instance.physicalKeysPressed
                  .contains(LogicalKeyboardKey.shiftLeft) ||
              HardwareKeyboard.instance.physicalKeysPressed
                  .contains(LogicalKeyboardKey.shiftRight);

          if (!isShiftPressed) {
            // Enter: Send message
            if (!(stateProvider.isLoading || stateProvider.isProcessingFile)) {
              stateProvider.onSendMessage();
            }
          }
        }
      },
      child: widget.child,
    );
  }
}
