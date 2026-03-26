import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String _baseUrl = 'https://rickandmortyapi.com/api/';

  Future<Map<String, dynamic>> fetchCharacters({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}character?page=$page'),
      );

      if (response.statusCode == 200) {
        // http returns a string body, so you must decode it manually
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load characters: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching characters: $e');
    }
  }
}
