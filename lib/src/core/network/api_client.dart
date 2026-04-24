import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import 'dio_interceptors.dart';

class ApiClient {
  ApiClient({
    required this.baseUrl,
    Dio? dio,
  }) : _dio = dio ?? _createDio(baseUrl);

  final String baseUrl;
  final Dio _dio;

  String? _token;

  String? get token => _token;

  void setToken(String? value) {
    _token = value;
  }

  static Dio _createDio(String baseUrl) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: <String, dynamic>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    return dio;
  }

  void attachInterceptors(String? Function() tokenGetter) {
    _dio.interceptors.addAll([
      AuthInterceptor(tokenGetter),
      ErrorMappingInterceptor(),
    ]);
  }

  Future<bool> ping() async {
    try {
      final response = await _dio
          .get<dynamic>('/health')
          .timeout(const Duration(seconds: 2));
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
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
    final formData = FormData();
    if (fields != null) {
      formData.fields.addAll(
        fields.entries.map((e) => MapEntry(e.key, e.value)),
      );
    }
    formData.files.add(MapEntry(
      fieldName,
      await MultipartFile.fromFile(file.path),
    ));

    final response = await _dio.post<dynamic>(
      path,
      data: formData,
      options: Options(headers: <String, dynamic>{
        'Content-Type': 'multipart/form-data',
      }),
    );
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
    final options = Options(method: method);

    final response = await _dio.request<dynamic>(
      path,
      data: body,
      queryParameters: queryParameters,
      options: options,
    );
    return _decodeResponse(response);
  }

  Map<String, dynamic> _decodeResponse(Response<dynamic> response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return data;
      }
      throw ApiException(
        data['message'] as String? ??
            data['error'] as String? ??
            'Request failed with status ${response.statusCode}.',
        statusCode: response.statusCode,
        details: data,
      );
    }

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return data != null ? <String, dynamic>{'data': data} : const <String, dynamic>{};
    }

    throw ApiException(
      'Request failed with status ${response.statusCode}.',
      statusCode: response.statusCode,
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
