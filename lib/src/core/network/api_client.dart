import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  String? _token;

  String? get token => _token;

  void setToken(String? value) {
    _token = value;
  }

  Future<bool> ping() async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 2));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    return _request(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
  }) {
    return _request(
      method: 'POST',
      path: path,
      body: body,
    );
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Object? body,
  }) {
    return _request(
      method: 'PUT',
      path: path,
      body: body,
    );
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Object? body,
  }) {
    return _request(
      method: 'PATCH',
      path: path,
      body: body,
    );
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Object? body,
  }) {
    return _request(
      method: 'DELETE',
      path: path,
      body: body,
    );
  }

  Future<Map<String, dynamic>> uploadFile(
    String path, {
    required String fieldName,
    required File file,
    Map<String, String>? fields,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
    request.headers.addAll(_headers(includeJson: false));
    if (fields != null) {
      request.fields.addAll(fields);
    }
    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _decodeResponse(response);
  }

  Uri websocketUri(String path) {
    final uri = Uri.parse('$baseUrl$path');
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    return uri.replace(
      scheme: scheme,
      queryParameters: <String, String>{
        if (uri.queryParameters.isNotEmpty) ...uri.queryParameters,
        if (_token != null && _token!.isNotEmpty) 'token': _token!,
      },
    );
  }

  Future<Map<String, dynamic>> _request({
    required String method,
    required String path,
    Object? body,
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: queryParameters?.isEmpty == true ? null : queryParameters,
    );

    late final http.Response response;
    switch (method) {
      case 'GET':
        response = await _httpClient.get(uri, headers: _headers());
      case 'POST':
        response = await _httpClient.post(
          uri,
          headers: _headers(),
          body: body == null ? null : jsonEncode(body),
        );
      case 'PUT':
        response = await _httpClient.put(
          uri,
          headers: _headers(),
          body: body == null ? null : jsonEncode(body),
        );
      case 'PATCH':
        response = await _httpClient.patch(
          uri,
          headers: _headers(),
          body: body == null ? null : jsonEncode(body),
        );
      case 'DELETE':
        response = await _httpClient.delete(
          uri,
          headers: _headers(),
          body: body == null ? null : jsonEncode(body),
        );
      default:
        throw ApiException('Unsupported method: $method');
    }

    return _decodeResponse(response);
  }

  Map<String, String> _headers({
    bool includeJson = true,
  }) {
    return <String, String>{
      if (includeJson) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_token != null && _token!.isNotEmpty) 'Authorization': 'Bearer $_token',
    };
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final decoded = response.body.isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    throw ApiException(
      decoded['message'] as String? ??
          decoded['error'] as String? ??
          'Request failed with status ${response.statusCode}.',
      statusCode: response.statusCode,
      details: decoded,
    );
  }
}

class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.details,
  });

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
