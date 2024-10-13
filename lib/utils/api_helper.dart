import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_exception.dart';

class ApiHelper {
  // LOCAL: 'http://localhost/api'
  // DEV: 'http://ec2-18-176-57-143.ap-northeast-1.compute.amazonaws.com/api'
  // PROD: 'http://ec2-54-95-23-200.ap-northeast-1.compute.amazonaws.com/api'
  String baseUrl = 'http://ec2-54-95-23-200.ap-northeast-1.compute.amazonaws.com/api';
  String? _token;

  // constructor
  ApiHelper() {
    _initToken();
  }

  Future<void> _initToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
    );

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

    request.headers.addAll(await _headers());

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    return _handleResponse(http.Response(responseBody, response.statusCode));
  }

  Future<dynamic> postNoConvert(String endpoint, Map<String, dynamic> body, {File? file}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }


  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  Future<Map<String, String>> _headers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
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
