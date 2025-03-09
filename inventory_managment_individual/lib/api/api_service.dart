import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator and not localhost.
  // When physical Android device connected to my development machine, 10.0.2.2 might not work.
  // In that case, I need to use my development machine's actual IP address on my local network.
  // android emulator:
  //final String baseUrl = 'http://10.0.2.2:8080';

  // machine IP address:
  // cmd -> ipconfig -> Wireless LAN adapter WiFi ->  IPv4 Address
  final String baseUrl = 'http://192.168.178.36:8080';

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

  //vinyls
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

  // Get vinyl by tag ID
  Future<Map<String, dynamic>?> getVinylByTagId(String tagId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/vinyls/tag/$tagId'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        // Tag not found in database
        return null;
      } else {
        throw Exception('Failed to load vinyl by tag: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Could not connect to the server. Please try again.');
    }
  }

  Future<http.Response> addVinyl(
      Map<String, dynamic> vinylData, File? imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/vinyls'));

      // Create a MultipartFile for the vinylData with the correct Content-Type
      request.files.add(
        http.MultipartFile.fromString(
          'vinylData',
          jsonEncode(vinylData),
          contentType: MediaType('application', 'json'),
        ),
      );

      if (imageFile != null) {
        // Determine the Content-Type of the image file
        final mimeTypeData =
            lookupMimeType(imageFile.path, headerBytes: [0xFF, 0xD8])!
                .split('/'); // Add this import 'package:mime/mime.dart';
        // Add the image file as a part
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        ));
      }

      // Send the request
      var response = await request.send().timeout(const Duration(seconds: 5));

      return http.Response.fromStream(response);
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

  //artists
  Future<List<Map<String, dynamic>>> getArtists(int page, int size) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/artist?page=$page&size=$size'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        if (decodedData.containsKey('artists')) {
          return List<Map<String, dynamic>>.from(decodedData['artists']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load artists: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Could not connect to the server. Please try again.');
    }
  }

  Future<Map<String, dynamic>> getArtist(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/artist/$id'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load artist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Could not connect to the server. Please try again.');
    }
  }

  Future<http.Response> createArtist(Map<String, dynamic> artistData) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/artist'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(artistData),
          )
          .timeout(const Duration(seconds: 5));
      return response;
    } catch (e) {
      throw Exception('Could not connect to the server. Please try again.');
    }
  }
}
