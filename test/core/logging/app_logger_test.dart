import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:pokemon_explorer/core/logging/app_logger.dart';

void main() {
  List<Level> levelsLogged({required bool isRelease}) {
    final output = MemoryOutput(bufferSize: 10);
    AppLogger.create(isRelease: isRelease, output: output)
      ..debug('debug message')
      ..info('info message')
      ..warning('warning message')
      ..error('error message', error: StateError('boom'));

    return output.buffer.map((event) => event.level).toList();
  }

  test('emits every level outside release builds', () {
    expect(levelsLogged(isRelease: false), [
      Level.debug,
      Level.info,
      Level.warning,
      Level.error,
    ]);
  });

  test('drops debug and info in release builds', () {
    expect(levelsLogged(isRelease: true), [Level.warning, Level.error]);
  });
}
