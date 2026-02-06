You are an expert Flutter developer specializing in clean, minimalist, maintainable code for solo bootstrapped founders with limited time and budget.

Write a complete, production-ready Flutter app (single main.dart file if possible) for a simple AI chat interface that strictly follows the Single Responsibility Principle (SRP). Keep code extremely clean, simple, readable, no over-abstraction, no unnecessary layers, no complex state management beyond setState + SharedPreferences for persistence. Avoid third-party packages except:

- flutter/material.dart
- http
- shared_preferences
- dart:convert
- dart:io (only if needed)

No riverpod, no provider, no bloc, no getx, no excessive comments, no boilerplate.

App requirements:

1. Single-screen mobile-first chat UI, dark theme, sleek & modern look
   - Background: Color(0xFF121212)
   - Surface/AppBar: Color(0xFF1E1E1E)
   - Text: white/white tones
   - Accents: subtle blue (e.g. Colors.blue[700]) or cyan for user messages/send button

2. Chat layout:
   - ListView.builder for messages (efficient)
   - User messages: right-aligned, blue-ish bubble (rounded corners ~20px)
   - AI messages: left-aligned, white bubble (rounded corners ~20px)
   - Show loading indicator (e.g. three bouncing dots or CircularProgressIndicator) while waiting for AI response

3. Bottom input area:
   - Expandable TextField (minLines: 1, maxLines: null)
   - Starts slim/single-line, grows vertically as user types
   - Leading icon button: Icons.attach_file or Icons.image (placeholder for image — for now just opens a dialog to paste image URL)
   - Trailing send button: Icons.send, rounded, modern look (subtle elevation or border)
   - Enter key: sends message
   - Shift + Enter: new line (do NOT send)
   - Clear input after sending

4. API integration:
   - Use this FastAPI endpoint: POST /generate
   - Base URL stored as a constant at the top of the file (so easy to change):
     const String apiBaseUrl = 'http://localhost:8000'; // change here
   - Request body (JSON):
     {
       "text": "user message",
       "image_url": "optional url string",
       "api_key": "...",
       "model_name": "..."
     }
   - Response: { "response": "AI text" }
   - Handle errors gracefully (show error message in chat)

5. Persistent settings:
   - Use SharedPreferences to store apiKey and modelName
   - Hamburger menu (Drawer) contains:
     - Chat (current screen)
     - Settings (new screen/page)
   - Settings screen:
     - TextField for OpenRouter API Key
     - TextField for Model Name (e.g. anthropic/claude-3.5-sonnet, openai/gpt-4o, etc.)
     - Save button → saves to SharedPreferences and pops back
     - Simple, clean form layout

6. Image support (minimal):
   - When user taps attach icon → show simple AlertDialog with TextField to paste image URL
   - If URL provided, include "image_url" in API request
   - For now, just send the URL string (backend handles multimodal)

7. Other details:
   - Responsive: use MediaQuery for padding/margins when needed, but keep simple
   - AppBar: title "AI Chat", leading hamburger icon for Drawer
   - Initial message from AI: "Hello! How can I help you today?"
   - When sending: show user message immediately, then loading indicator, then AI response
   - Keyboard: requestFocus after sending to keep typing smooth

Deliver:
- Full code in one file (main.dart)
- Runnable with flutter run
- Use dummy initial messages
- Clean, flat structure: separate small widget methods or private classes only when it truly improves readability (SRP)

Do NOT add authentication, animations beyond basic, themes beyond dark, or any feature not explicitly requested. Keep it dead simple, fast to iterate on for a solo dev. Add a proper git ignore.
Target initial development and testing on:
- Linux desktop: Pop!_OS 24.04 LTS with COSMIC desktop environment (Wayland)
- Web: running in Google Chrome (flutter run -d chrome)
- Android mobile (emulator or device)

Make the UI responsive and comfortable on both larger desktop screens (e.g. 1920x1080+) and smaller mobile screens. Use MediaQuery, LayoutBuilder, or simple breakpoints (e.g. if width > 800 use wider layouts) where it improves usability without adding complexity. Prefer mouse + keyboard friendly interactions on desktop/web (e.g. larger tap targets, hover effects if natural, Enter key works well). Keep mobile as the primary design foundation.