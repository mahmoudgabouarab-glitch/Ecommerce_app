import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'cache_helper.dart';
import 'cache_keys.dart';

class ApiServise {
  /// API base URL. Defaults to the hosted Railway API, and can be overridden
  /// at build/run time (e.g. to point at a local server) via:
  ///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/
  ///
  /// Local addresses for development:
  /// - iOS simulator / desktop / web:  http://127.0.0.1:8000/api/
  /// - Android emulator:               http://10.0.2.2:8000/api/
  /// - Real device on the same Wi-Fi:  http://YOUR_COMPUTER_LAN_IP:8000/api/
  static const String _defaultBaseUrl =
      "https://ecommerceapp-production-620e.up.railway.app/api/";
  final String _baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );
  final Dio _dio;

  ApiServise(this._dio) {
    _dio.options.headers = {"Accept": "application/json"};
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = CacheHelper.getDataString(key: CacheKeys.token);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
    _dio.interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );
  }

  Future<Map<String, dynamic>> get({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await _dio.get(
      "$_baseUrl$endpoint",
      queryParameters: queryParameters,
      options: options,
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> post({
    required String endpoint,
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    dynamic body = data;
    if (data is Map<String, dynamic> &&
        data.values.any((v) => v is MultipartFile)) {
      body = FormData.fromMap(data);
    }
    final response = await _dio.post(
      "$_baseUrl$endpoint",
      data: body,
      queryParameters: queryParameters,
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> put({
    required String endpoint,
    Object? data,
  }) async {
    final response = await _dio.put("$_baseUrl$endpoint", data: data);
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> patch({
    required String endpoint,
    Object? data,
  }) async {
    final response = await _dio.patch("$_baseUrl$endpoint", data: data);
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> delete({
    required String endpoint,
    Object? data,
  }) async {
    final response = await _dio.delete("$_baseUrl$endpoint", data: data);
    return _asMap(response.data);
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    return {'data': data};
  }
}
