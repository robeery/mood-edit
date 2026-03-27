import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../model/ai_exception.dart';
import '../model/chat_message.dart';

class GeminiService {
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  static const _systemPrompt = '''
You are a photo editing assistant. The user describes how they want their photo to look.
You must respond with ONLY a valid JSON object matching the schema below. No explanation, no markdown, no extra text.

The image provided shows the CURRENT EDITED STATE of the photo.
Each user message includes a CURRENT STATE section with the exact parameters currently applied.
Build on existing edits — only include operations you want to change or add.
Operations not in your response remain unchanged.
To reset an operation to 0, include it explicitly with value: 0.

SCHEMA:
{
  "message": "<short friendly description of what you changed and why>",
  "edits": [
    { "type": "<OperationType>", "value": <number> }
  ],
  "colorEdits": [
    { "range": "<ColorRange>", "hue": <number>, "saturation": <number>, "luminance": <number> }
  ],
  "colorGradingEdits": [
    { "zone": "<ColorGradingZone>", "hue": <number>, "strength": <number>, "luminance": <number> }
  ]
}

OPERATION TYPES AND VALUE RANGES:
Basic edits (range -100 to +100): exposure, brightness, highlights, shadows, contrast, warmth, tint, saturation, vibrance, vignette
Basic edits (range 0 to +100): sharpness, definition, blackpoint, noiseReduction, grain, fade

Selective color ranges: red, orange, yellow, green, cyan, blue, purple, magenta
  - hue: -100 to +100
  - saturation: -100 to +100
  - luminance: -100 to +100

Color grading zones: shadows, midtones, highlights, global
  - hue: 0 to 360 (degrees)
  - strength: 0 to 100
  - luminance: -100 to +100

RULES:
- The "message" field is REQUIRED. Keep it short (1-2 sentences) explaining what you did.
- Only include operations with non-zero values.
- All three edit arrays are optional — include only the ones needed.
- Values must be within the specified ranges.
- Return ONLY the JSON object, nothing else.
- Use CURRENT STATE to understand what is already applied before deciding what to change.
''';

  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<String> sendPrompt(
    String userMessage, {
    Uint8List? imageBytes,
    String model = 'gemini-2.5-flash-lite',
    List<ChatMessage> history = const [],
    String? currentStateJson,
  }) async {
    if (_apiKey.isEmpty || _apiKey == 'your_key_here') {
      throw Exception('GEMINI_API_KEY not configured in .env');
    }

    final url = Uri.parse('$_baseUrl/$model:generateContent?key=$_apiKey');

    // Build conversation history (text only - no images in past turns)
    final contents = <Map<String, dynamic>>[];
    for (final msg in history) {
      if (msg.isError) continue;
      contents.add({
        'role': msg.isUser ? 'user' : 'model',
        'parts': [{'text': msg.text}],
      });
    }

    // Build current message: image + current state + user text
    final currentParts = <Map<String, dynamic>>[];
    if (imageBytes != null) {
      currentParts.add({
        'inline_data': {
          'mime_type': 'image/jpeg',
          'data': base64Encode(imageBytes),
        },
      });
    }
    final messageText = currentStateJson != null
        ? 'CURRENT STATE:\n$currentStateJson\n\nUSER: $userMessage'
        : userMessage;
    currentParts.add({'text': messageText});
    contents.add({'role': 'user', 'parts': currentParts});

    final body = jsonEncode({
      'contents': contents,
      'systemInstruction': {
        'parts': [
          {'text': _systemPrompt},
        ],
      },
      'generationConfig': {
        'responseMimeType': 'application/json',
      },
    });

    final http.Response response;
    try {
      response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
    } on SocketException {
      throw const AiException(
        type: AiErrorType.unknown,
        message: 'Connection failed. Check your internet.',
      );
    }

    if (response.statusCode != 200) {
      throw AiException.fromStatusCode(response.statusCode, response.body);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final text = json['candidates'][0]['content']['parts'][0]['text'] as String;
    return text;
  }
}
