import 'dart:convert';

import 'package:easycook/env/constants/open_ai.dart';
import 'package:easycook/models/open_ai.dart';
import 'package:easycook/models/usage.dart';
import 'package:http/http.dart' as http;

class RecommendationService {
  static Future<GptData> getLunchRecommendation(String input) async {
    late GptData gptData = GptData(
      id: "",
      object: "",
      created: 0,
      model: "",
      choices: [],
      usage: Usage(completionTokens: 0, promptTokens: 0, totalTokens: 0),
    );

    try {
      var url = Uri.parse('https://api.openai.com/v1/chat/completions');

      Map<String, String> headers = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Charset': 'utf-8',
        'Authorization': 'Bearer $apiKey',
      };

      final data = jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "You are a cooking expert."},
          {"role": "system", "content": input},
        ],
        "max_tokens": 200,
      });

      var response = await http.post(url, headers: headers, body: data);
      if (response.statusCode == 200) {
        gptData = gptDataFromJson(response.body);
      }
    } catch (e) {
      throw Exception('Error occurred when sending request.');
    }

    return gptData;
  }
}
