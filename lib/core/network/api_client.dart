import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String _baseUrl = 'https://rickandmortyapi.com/api/';

  Future<Map<String, dynamic>> fetchCharacters({
    int page = 1, 
    String? name,
    String? status,
    String? species,
  }) async {
    try {
      final queryParameters = {
        'page': page.toString(),
        if (name != null && name.isNotEmpty) 'name': name,
        if (status != null && status.isNotEmpty) 'status': status,
        if (species != null && species.isNotEmpty) 'species': species,
      };
      
      final uri = Uri.parse('${_baseUrl}character').replace(queryParameters: queryParameters);
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return {
          'info': {'count': 0, 'pages': 0, 'next': null, 'prev': null},
          'results': []
        };
      } else {
        throw Exception('Failed to load characters: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching characters: $e');
    }
  }
}
