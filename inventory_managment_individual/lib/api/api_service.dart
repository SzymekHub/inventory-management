import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android emulator and not localhost.
  // When physical Android device connected to my development machine, 10.0.2.2 might not work.
  // In that case, I need to use my development machine's actual IP address on my local network.
  final String baseUrl = 'http://10.0.2.2:8080';

  // New method to fetch enums
  Future<Map<String, List<String>>> getVinylEnums() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/vinyls/enums'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        // Convert each list of enums to a List<String>
        final Map<String, List<String>> enums = decodedData
            .map((key, value) => MapEntry(key, List<String>.from(value)));
        return enums;
      } else {
        throw Exception('Failed to load enums: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Could not connect to the server. Please try again.');
    }
  }

  Future<List<Map<String, dynamic>>> getVinyls(int page, int size) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/vinyls?page=$page&size=$size'))
          .timeout(const Duration(seconds: 5)); // Timeout after 10 seconds

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        if (decodedData.containsKey('vinyls')) {
          return List<Map<String, dynamic>>.from(decodedData['vinyls']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load vinyls: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Could not connect to the server. Please try again.');
    }
  }

  Future<Map<String, dynamic>> getVinyl(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/vinyls/$id'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load vinyl: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Could not connect to the server. Please try again.');
    }
  }

  Future<http.Response> addVinyl(Map<String, dynamic> vinylData) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/vinyls'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(vinylData),
          )
          .timeout(const Duration(seconds: 5));
      return response;
    } catch (e) {
      throw Exception('Could not connect to the server. Please try again.');
    }
  }

  Future<http.Response> updateVinyl(
      int id, Map<String, dynamic> vinylData) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/vinyls/$id'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(vinylData),
          )
          .timeout(const Duration(seconds: 5));
      return response;
    } catch (e) {
      throw Exception('Could not connect to the server. Please try again.');
    }
  }

  Future<http.Response> deleteVinyl(int id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/vinyls/$id'))
          .timeout(const Duration(seconds: 5));
      return response;
    } catch (e) {
      throw Exception('Could not connect to the server. Please try again.');
    }
  }

  // will add methods for image uploads here
}
