import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService{
  static const String _apiKey = 'AIzaSyCq11cnjedwH9SZvUNoa3pwvJu1C6T6gIg';

  static Future<String> getGimniResponse(String prompt) async{
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent');

    final response = await http.post(
        url,
      headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
      },
      body: jsonEncode(
          {
            "contents": [
              {
                "parts": [
                  {
                    "text": prompt
                  }
                ]
              }
            ]
          }
      ),
    );

    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    }else {
      print('Gemini error: ${response.statusCode} ${response.body}');
      return "I'm having trouble answering that.";
    }
  }
}