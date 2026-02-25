import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static const _model = 'gemini-2.5-flash';
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  static const _systemPrompt = '''
You are a photo editing assistant. The user describes how they want their photo to look.
You must respond with ONLY a valid JSON object matching the schema below. No explanation, no markdown, no extra text.

SCHEMA:
{
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
- Only include operations with non-zero values.
- All three top-level arrays are optional — include only the ones needed.
- Values must be within the specified ranges.
- Return ONLY the JSON object, nothing else.
''';

  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<String> sendPrompt(String userMessage) async {
    if (_apiKey.isEmpty || _apiKey == 'your_key_here') {
      throw Exception('GEMINI_API_KEY not configured in .env');
    }

    final url = Uri.parse('$_baseUrl/$_model:generateContent?key=$_apiKey');

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': userMessage},
          ],
        },
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
