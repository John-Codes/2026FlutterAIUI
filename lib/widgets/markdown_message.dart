import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../models/chat_message.dart';

class MarkdownMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const MarkdownMessageWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: message.text,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.5,
        ),
        strong: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        em: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontStyle: FontStyle.italic,
        ),
        code: TextStyle(
          color: Colors.green[300],
          fontSize: 14,
          fontFamily: 'monospace',
          backgroundColor: Colors.grey[800],
        ),
        codeblockDecoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        h1: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        h2: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        h3: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        blockquote: TextStyle(
          color: Colors.grey[300],
          fontSize: 16,
          fontStyle: FontStyle.italic,
        ),
        a: TextStyle(
          color: Colors.blue[300],
          fontSize: 16,
          decoration: TextDecoration.underline,
        ),
      ),
      selectable: true,
    );
  }
}
