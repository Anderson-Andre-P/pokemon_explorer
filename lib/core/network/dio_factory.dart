import 'package:dio/dio.dart';
import 'package:pokemon_explorer/core/logging/app_logger.dart';
import 'package:pokemon_explorer/core/network/api_endpoints.dart';
import 'package:pokemon_explorer/core/network/interceptors/logging_interceptor.dart';
import 'package:pokemon_explorer/core/network/interceptors/retry_interceptor.dart';

const _connectTimeout = Duration(seconds: 10);
const _receiveTimeout = Duration(seconds: 15);

Dio createDio(AppLogger logger) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      headers: {Headers.acceptHeader: Headers.jsonContentType},
    ),
  );

  dio.interceptors.addAll([
    LoggingInterceptor(logger),
    RetryInterceptor(dio: dio),
  ]);

  return dio;
}
