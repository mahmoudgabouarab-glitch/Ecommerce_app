import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'cache_helper.dart';
import 'cache_keys.dart';

class ApiServise {
  /// API base URL. Configured at build/run time via:
  ///   flutter run --dart-define=API_BASE_URL=https://your-host/api/
  ///
  /// Falls back to a local address for development when no value is passed:
  /// - iOS simulator / desktop / web:  http://127.0.0.1:8000/api/
  /// - Android emulator:               http://10.0.2.2:8000/api/
  /// - Real device on the same Wi-Fi:  http://YOUR_COMPUTER_LAN_IP:8000/api/
  static const String _defaultBaseUrl = "http://192.168.1.3:8000/api/";
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
