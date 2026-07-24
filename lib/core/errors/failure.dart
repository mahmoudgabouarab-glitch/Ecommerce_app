import 'package:dio/dio.dart';

abstract class Failure {
  final String errorMessage;
  final int? statusCode;

  Failure(this.errorMessage, {this.statusCode});
}

class ServiseFailure extends Failure {
  ServiseFailure(super.errorMessage, {super.statusCode});

  factory ServiseFailure.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ServiseFailure("Connection timeout. Please try again.");
      case DioExceptionType.sendTimeout:
        return ServiseFailure("Send timeout. Please try again.");
      case DioExceptionType.receiveTimeout:
        return ServiseFailure("Receive timeout. Please try again.");
      case DioExceptionType.badCertificate:
        return ServiseFailure("Bad certificate.");
      case DioExceptionType.cancel:
        return ServiseFailure("Request cancelled.");
      case DioExceptionType.connectionError:
        return ServiseFailure(
          "Cannot reach the server. Check your connection.",
        );
      case DioExceptionType.unknown:
        return ServiseFailure("Unexpected error. Please try again.");
      case DioExceptionType.badResponse:
        return ServiseFailure.fromResponse(
          e.response?.statusCode,
          e.response?.data,
        );
      default:
        return ServiseFailure("Unexpected error. Please try again.");
    }
  }

  factory ServiseFailure.fromResponse(int? statusCode, dynamic response) {
    final map = response is Map<String, dynamic> ? response : const {};

    switch (statusCode) {
      case 400:
      case 403:
      case 404:
      case 409:
      case 429:
      case 500:
        return ServiseFailure(
          (map['message'] as String?) ?? 'Something went wrong',
          statusCode: statusCode,
        );
      case 401:
        return ServiseFailure(
          (map['message'] as String?) ??
              'Session expired. Please log in again.',
          statusCode: statusCode,
        );

      case 422:
        final errors = map['errors'];
        if (errors is Map<String, dynamic>) {
          for (final entry in errors.entries) {
            final val = entry.value;
            if (val is List && val.isNotEmpty) {
              return ServiseFailure(val.first.toString(), statusCode: 422);
            }
          }
        }
        return ServiseFailure(
          (map['message'] as String?) ?? 'Validation error',
          statusCode: 422,
        );

      default:
        return ServiseFailure(
          (map['message'] as String?) ?? 'Something went wrong',
          statusCode: statusCode,
        );
    }
  }
}
