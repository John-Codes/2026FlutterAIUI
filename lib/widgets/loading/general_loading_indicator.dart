import 'dart:math';
import 'package:flutter/material.dart';

/// General loading indicator that shows appropriate messages based on context
/// Follows SRP by only handling loading display logic
class GeneralLoadingIndicator extends StatefulWidget {
  final bool isLoading;
  final bool isProcessingFile;
  final String? customMessage;

  const GeneralLoadingIndicator({
    super.key,
    required this.isLoading,
    required this.isProcessingFile,
    this.customMessage,
  });

  @override
  State<GeneralLoadingIndicator> createState() =>
      _GeneralLoadingIndicatorState();
}

class _GeneralLoadingIndicatorState extends State<GeneralLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only show if either loading state is true
    if (!widget.isLoading && !widget.isProcessingFile) {
      return const SizedBox.shrink();
    }

    // Determine the appropriate message
    String message;
    if (widget.customMessage != null) {
      message = widget.customMessage!;
    } else if (widget.isProcessingFile) {
      message = 'Processing image...';
    } else if (widget.isLoading) {
      message = 'Sending message...';
    } else {
      message = 'Loading...';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF404040)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Modern animated dots
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  final delay = index * 0.2;
                  final scale = 1.0 +
                      0.3 * sin((_animation.value * 2 * pi) + (delay * 2 * pi));
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.blue[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(width: 16),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
