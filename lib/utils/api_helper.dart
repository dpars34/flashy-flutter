import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import 'api_exception.dart';

class ApiHelper {
  String baseUrl = 'http://localhost/api';

  // constructor
  ApiHelper();

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));

    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body, {File? file}) async {
    var uri = Uri.parse('$baseUrl$endpoint');
    var request = http.MultipartRequest('POST', uri);

    // Add fields
    body.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add file if provided
    if (file != null) {
      var fileStream = http.ByteStream(file.openRead());
      var length = await file.length();
      var multipartFile = http.MultipartFile(
        'profile_image',
        fileStream,
        length,
        filename: basename(file.path),
      );
      request.files.add(multipartFile);
    }

    request.headers.addAll(_headers());

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    return _handleResponse(http.Response(responseBody, response.statusCode));
  }


  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers(),
    );

    return _handleResponse(response);
  }

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  dynamic _handleResponse(http.Response response) {
    final int statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw ApiException(statusCode, 'Error occurred with status code: $statusCode');
    }
  }
}
