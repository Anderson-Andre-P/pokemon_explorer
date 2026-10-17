import 'package:dio/dio.dart';
import 'package:pokemon_explorer/core/logging/app_logger.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this._logger);

  static const _stopwatchKey = 'logging_stopwatch';

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_stopwatchKey] = Stopwatch()..start();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final options = response.requestOptions;
    _logger.debug(
      '${options.method} ${options.path} -> ${response.statusCode} (${_elapsedMs(options)} ms)',
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final status = err.response?.statusCode;

    _logger.warning(
      '${options.method} ${options.path} failed: ${err.type.name} ${status == null ? '' : '$status'} (${_elapsedMs(options)} ms)',
    );

    handler.next(err);
  }

  int _elapsedMs(RequestOptions options) {
    final stopWatch = options.extra[_stopwatchKey];
    return stopWatch is Stopwatch ? stopWatch.elapsedMilliseconds : 0;
  }
}
