import 'package:logger/logger.dart';

class AppLogger {
  AppLogger(this._logger);

  factory AppLogger.create({required bool isRelease, LogOutput? output}) =>
      AppLogger(
        Logger(
          filter: ProductionFilter(),
          level: isRelease ? Level.warning : Level.debug,
          printer: PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 8,
            colors: false,
            printEmojis: false,
            noBoxingByDefault: true,
          ),
          output: output,
        ),
      );

  final Logger _logger;

  void debug(String message) => _logger.d(message);
  void info(String message) => _logger.i(message);
  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
