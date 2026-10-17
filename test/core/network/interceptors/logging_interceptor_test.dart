import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokemon_explorer/core/network/interceptors/logging_interceptor.dart';

import '../../../helpers/fake_http_client_adapter.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockAppLogger logger;

  Dio dioAnswering(ResponseBody Function() answer) {
    final dio = Dio(BaseOptions(baseUrl: 'https://pokeapi.com/api/v2/'))
      ..httpClientAdapter = FakeHttpClientAdapter((_) => answer())
      ..interceptors.add(LoggingInterceptor(logger));

    return dio;
  }

  setUp(() => logger = MockAppLogger());

  test(
    'logs method, path, status and duration without the response body',
    () async {
      final dio = dioAnswering(() => jsonBody('{"secret":"payload"}', 200));
      await dio.get<dynamic>('pokemon/25');
      final message =
          verify(() => logger.debug(captureAny())).captured.single as String;

      expect(message, contains('GET pokemon/25'));
      expect(message, contains('200'));
      expect(message, matches(RegExp(r'\(\d+ ms\)')));
      expect(message, isNot(contains('payload')));
    },
  );

  test(
    'logs a failed request as a warning with its error type and status',
    () async {
      final dio = dioAnswering(() => jsonBody('{"detail":"Not found."}', 404));
      await expectLater(
        dio.get<dynamic>('pokemon/0'),
        throwsA(isA<DioException>()),
      );
      final message =
          verify(() => logger.warning(captureAny())).captured.single as String;

      expect(message, contains('GET pokemon/0'));
      expect(message, contains('badResponse'));
      expect(message, contains('404'));
      expect(message, isNot(contains('Not found.')));
    },
  );
}
