import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this._dio,
    this.maxRetries = 2,
    this._delay = Future<void>.delayed,
  });

  static const _attemptKey = 'retry attempt';
  static const _initialBackoff = Duration(milliseconds: 500);

  final Dio _dio;
  final Future<void> Function(Duration) _delay;
  final int maxRetries;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = options.extra[_attemptKey] as int? ?? 0;

    if (!_isRetryable(err) || attempt >= maxRetries) {
      handler.next(err);
      return;
    }

    await _delay(_initialBackoff * (1 << attempt));

    options.extra[_attemptKey] = attempt + 1;

    try {
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _isRetryable(DioException err) =>
      err.requestOptions.method.toUpperCase() == 'GET' &&
      (err.type == DioExceptionType.connectionTimeout ||
          err.type == DioExceptionType.receiveTimeout);
}
