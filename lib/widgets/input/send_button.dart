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
  final ValueNotifier<String> _textNotifier = ValueNotifier('');

  @override
  void initState() {
    super.initState();

    // Listen to text changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTextNotifier();
    });
  }

  void _updateTextNotifier() {
    final stateProvider = ChatInputStateProvider.of(context);
    if (stateProvider != null) {
      _textNotifier.value = stateProvider.textController.text;
      // Add listener to text controller
      stateProvider.textController.removeListener(_updateTextNotifier);
      stateProvider.textController.addListener(_updateTextNotifier);
    }
  }

  @override
  void dispose() {
    _textNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateProvider = ChatInputStateProvider.of(context);
    if (stateProvider == null) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<String>(
      valueListenable: _textNotifier,
      builder: (context, text, child) {
        final hasText = text.trim().isNotEmpty;
        final hasImage = stateProvider.selectedImageData != null;
        final canSend = hasText || hasImage;
        final isLoading =
            stateProvider.isLoading || stateProvider.isProcessingFile;

        return AnimatedBuilder(
          animation: const AlwaysStoppedAnimation<double>(1.0),
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: isLoading
                    ? Colors.grey[700]!
                    : (canSend ? Colors.blue[600]! : Colors.grey[600]!),
                borderRadius: BorderRadius.circular(30),
                boxShadow: isLoading
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : (canSend
                        ? [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: isLoading
                    ? Matrix4.diagonal3Values(0.95, 0.95, 1.0)
                    : Matrix4.identity(),
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        ),
                        child: child,
                      );
                    },
                    child: isLoading
                        ? const Icon(
                            Icons.square,
                            color: Colors.white,
                            key: ValueKey('stop'),
                            size: 22,
                          )
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                            key: ValueKey('send'),
                            size: 22,
                          ),
                  ),
                  onPressed: (canSend && !isLoading)
                      ? stateProvider.onSendMessage
                      : null,
                  tooltip: isLoading ? 'Sending...' : 'Send message',
                  style: IconButton.styleFrom(
                    disabledForegroundColor:
                        Colors.white.withValues(alpha: 0.4),
                    hoverColor: Colors.blue[500],
                    focusColor: Colors.blue[500],
                    highlightColor: Colors.blue[400],
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Enhanced keyboard listener widget for send functionality
/// Uses FocusNode.onKeyEvent for better cross-platform support
class SendKeyboardListener extends StatefulWidget {
  final Widget child;
  final FocusNode? focusNode;

  const SendKeyboardListener({
    super.key,
    required this.child,
    this.focusNode,
  });

  @override
  State<SendKeyboardListener> createState() => _SendKeyboardListenerState();
}

class _SendKeyboardListenerState extends State<SendKeyboardListener> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateProvider = ChatInputStateProvider.of(context);
    if (stateProvider == null) {
      return widget.child;
    }

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        // We only care about key down and repeat events
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            // Use the more reliable isShiftPressed method
            final bool isShiftPressed =
                HardwareKeyboard.instance.isShiftPressed;

            if (!isShiftPressed) {
              // Plain Enter: Send message - check if text or image is present
              final hasText =
                  stateProvider.textController.text.trim().isNotEmpty;
              final hasImage = stateProvider.selectedImageData != null;
              final canSend = hasText || hasImage;

              if (!(stateProvider.isLoading ||
                      stateProvider.isProcessingFile) &&
                  canSend) {
                stateProvider.onSendMessage();
                return KeyEventResult
                    .handled; // Prevent newline + prevent default submit
              }
              return KeyEventResult.ignored;
            } else {
              // Shift+Enter: Do nothing here → Flutter will insert \n automatically
              return KeyEventResult
                  .ignored; // Let the default behavior happen (newline)
            }
          }
        }
        return KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }
}
