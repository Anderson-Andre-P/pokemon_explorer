import 'package:bloc/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokemon_explorer/app/app_bloc_observer.dart';

import '../helpers/mocks.dart';

sealed class _State {
  const _State();

  @override
  String toString() => 'SECRET PAYLOAD';
}

final class _Idle extends _State {
  const _Idle();
}

final class _Busy extends _State {
  const _Busy();
}

class _TestCubit extends Cubit<_State> {
  _TestCubit() : super(const _Idle());
}

void main() {
  late MockAppLogger logger;
  late _TestCubit cubit;

  setUp(() {
    logger = MockAppLogger();
    cubit = _TestCubit();
  });

  tearDown(() => cubit.close());

  const change = Change<_State>(currentState: _Idle(), nextState: _Busy());

  test('Logs state changes as runtime types only', () {
    AppBlocObserver(logger, logChanges: true).onChange(cubit, change);
    verify(() => logger.debug('_TestCubit: _Idle -> _Busy')).called(1);
  });

  test('Does not log state changes when disabled', () {
    AppBlocObserver(logger, logChanges: false).onChange(cubit, change);

    verifyNever(() => logger.debug(any()));
  });

  test('always logs errors with their stack trace', () {
    final error = StateError('boom');
    final stackTrace = StackTrace.current;

    AppBlocObserver(
      logger,
      logChanges: false,
    ).onError(cubit, error, stackTrace);

    verify(
      () => logger.error(
        'Unhandled error in _TestCubit',
        error: error,
        stackTrace: stackTrace,
      ),
    ).called(1);
  });
}
