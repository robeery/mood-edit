import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  // static const _model = 'gemini-2.5-flash';
  // static const _model = 'gemini-2.5-pro';
  static const _model = 'gemini-2.5-flash-lite';
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  static const _systemPrompt = '''
You are a photo editing assistant. The user describes how they want their photo to look.
You must respond with ONLY a valid JSON object matching the schema below. No explanation, no markdown, no extra text.

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
    { "zone": "<ColorGradingZone>", "hue": <number>, "strength": <number> }
  ]
}

OPERATION TYPES AND VALUE RANGES:
Basic edits (range -100 to +100): exposure, brightness, highlights, shadows, contrast, warmth, tint, saturation, vibrance
Basic edits (range 0 to +100): sharpness, definition, blackpoint, vignette, noiseReduction, grain, fade

Selective color ranges: red, orange, yellow, green, cyan, blue, purple, magenta
  - hue: -100 to +100
  - saturation: -100 to +100
  - luminance: -100 to +100

Color grading zones: shadows, midtones, highlights, global
  - hue: 0 to 360 (degrees)
  - strength: 0 to 100

RULES:
- The "message" field is REQUIRED. Keep it short (1-2 sentences) explaining what you did.
- Only include operations with non-zero values.
- All three edit arrays are optional — include only the ones needed.
- Values must be within the specified ranges.
- Return ONLY the JSON object, nothing else.
''';

  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<String> sendPrompt(String userMessage, {Uint8List? imageBytes}) async {
    if (_apiKey.isEmpty || _apiKey == 'your_key_here') {
      throw Exception('GEMINI_API_KEY not configured in .env');
    }

    final url = Uri.parse('$_baseUrl/$_model:generateContent?key=$_apiKey');

    final parts = <Map<String, dynamic>>[
      {'text': userMessage},
    ];

    if (imageBytes != null) {
      parts.insert(0, {
        'inline_data': {
          'mime_type': 'image/jpeg',
          'data': base64Encode(imageBytes),
        },
      });
    }

    final body = jsonEncode({
      'contents': [
        {'parts': parts},
      ],
      'systemInstruction': {
        'parts': [
          {'text': _systemPrompt},
        ],
      },
      'generationConfig': {
        'responseMimeType': 'application/json',
      },
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final text = json['candidates'][0]['content']['parts'][0]['text'] as String;
    return text;
  }
}
