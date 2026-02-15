import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../models/chat_message.dart';
import '../../utils/formatters.dart';
import 'markdown_message.dart';

class MessageWidget extends StatelessWidget {
  final ChatMessage message;

  const MessageWidget({
    super.key,
    required this.message,
  });

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          if (!message.isUser)
            const CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 16,
              child: Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
            )
          else
            const CircleAvatar(
              backgroundColor: Colors.green,
              radius: 16,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? const Color(0xFF2A5CAA)
                        : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.imageData != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              message.imageData is String
                                  ? base64Decode(message.imageData!)
                                  : message.imageData as Uint8List,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: 200,
                                  color: Colors.grey[800],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white70,
                                        size: 40,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Image could not be loaded',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      // Stack to position copy button and text properly
                      Stack(
                        children: [
                          // Container for text with proper padding to avoid button overlap
                          Container(
                            padding: const EdgeInsets.only(
                                bottom: 32, left: 32, right: 8),
                            child: message.isUser
                                ? Text(
                                    message.text,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  )
                                : MarkdownMessageWidget(message: message),
                          ),
                          // Copy button positioned on the left lower end inside the message
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              child: IconButton(
                                icon: const Icon(Icons.copy,
                                    color: Colors.white70, size: 16),
                                onPressed: () =>
                                    _copyToClipboard(context, message.text),
                                tooltip: 'Copy message',
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatTimestamp(message.timestamp),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
