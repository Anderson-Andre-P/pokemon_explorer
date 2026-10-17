import 'package:bloc/bloc.dart';

import '../core/logging/app_logger.dart';

class AppBlocObserver extends BlocObserver {
  AppBlocObserver(this._logger, {required this.logChanges});

  final AppLogger _logger;
  final bool logChanges;

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (!logChanges) return;
    _logger.debug(
      '${bloc.runtimeType}: ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _logger.error(
      'Unhandled error in ${bloc.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
