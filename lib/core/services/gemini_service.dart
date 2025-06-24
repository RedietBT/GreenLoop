import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GeminiService {
  final String apiKey;

  GeminiService(this.apiKey);

  Future<Map<String, dynamic>> classifyWasteWithGemini(File imageFile) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent?key=$apiKey');
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final prompt = '''
You are a recycling assistant. Given an image, classify the main waste item into one of these classes: battrey, cardboard, clothes, metal, paper, plastic. 
Return a JSON with these fields:
- class: the waste type
- recyclable: true/false
- sorting_steps: a numbered list of clear, step-by-step instructions for sorting this waste
- points: a fun number of points for recycling this item
- encouragement: a short, fun message for the user
''';

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text": prompt
            },
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Image
              }
            }
          ]
        }
      ]
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
      // Try to extract JSON from the text
      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd != -1) {
        final jsonString = text.substring(jsonStart, jsonEnd + 1);
        return jsonDecode(jsonString);
      }
      return {"error": "No JSON found in Gemini response", "raw": text};
    } else {
      throw Exception('Failed to get response from Gemini: ${response.body}');
    }
  }
} 