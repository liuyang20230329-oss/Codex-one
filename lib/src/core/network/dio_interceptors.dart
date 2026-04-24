import 'package:dio/dio.dart';

import 'api_client.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenGetter);

  final String? Function() _tokenGetter;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenGetter();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class ErrorMappingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final decoded = _tryDecode(err.response);
    final message = decoded?['message'] as String? ??
        decoded?['error'] as String? ??
        err.message ??
        'Request failed with status ${err.response?.statusCode}.';

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: ApiException(
          message,
          statusCode: err.response?.statusCode,
          details: decoded,
        ),
      ),
    );
  }

  Map<String, dynamic>? _tryDecode(Response<dynamic>? response) {
    try {
      final body = response?.data;
      if (body is Map<String, dynamic>) return body;
      return null;
    } catch (_) {
      return null;
    }
  }
}
