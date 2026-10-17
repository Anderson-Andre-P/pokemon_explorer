import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_explorer/core/network/interceptors/retry_interceptor.dart';

import '../../../helpers/fake_http_client_adapter.dart';

void main() {
  late List<Duration> delays;

  ({Dio dio, FakeHttpClientAdapter adapter}) dioWith(
    ResponseBody Function(RequestOptions options, int call) answer,
  ) {
    var calls = 0;
    final adapter = FakeHttpClientAdapter(
      (options) => answer(options, ++calls),
    );

    final dio = Dio(BaseOptions(baseUrl: 'https://pokeapi.co/api/v2/'))
      ..httpClientAdapter = adapter;

    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        delay: (duration) async => delays.add(duration),
      ),
    );

    return (dio: dio, adapter: adapter);
  }

  Never throwDio(RequestOptions options, DioExceptionType type) =>
      throw DioException(requestOptions: options, type: type);

  setUp(() => delays = []);

  test(
    'retries a timed-out GET and returns the response once it succeeds',
    () async {
      final (:dio, :adapter) = dioWith(
        ((options, call) => call < 3
            ? throwDio(options, DioExceptionType.receiveTimeout)
            : jsonBody('{}', 200)),
      );

      final response = await dio.get<dynamic>('pokemon/25');

      expect(response.statusCode, 200);
      expect(adapter.request, hasLength(3));
      expect(delays, [
        const Duration(milliseconds: 500),
        const Duration(seconds: 1),
      ]);
    },
  );

  test('gives up after two retries and surfaces the timeout', () async {
    final (:dio, :adapter) = dioWith(
      (options, _) => throwDio(options, DioExceptionType.connectionTimeout),
    );

    await expectLater(
      dio.get<dynamic>('pokemon/25'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.connectionTimeout,
        ),
      ),
    );
    expect(adapter.request, hasLength(3));
  });

  test('does not retry a timed-out POST', () async {
    final (:dio, :adapter) = dioWith(
      (options, _) => throwDio(options, DioExceptionType.receiveTimeout),
    );

    await expectLater(
      dio.post<dynamic>('pokemon'),
      throwsA(isA<DioException>()),
    );

    expect(adapter.request, hasLength(1));
  });

  test('does not retry a 404', () async {
    final (:dio, :adapter) = dioWith((_, _) => jsonBody('{}', 404));

    await expectLater(
      dio.get<dynamic>('pokemon/0'),
      throwsA(isA<DioException>()),
    );

    expect(adapter.request, hasLength(1));
  });

  test('does not retry a connection error', () async {
    final (:dio, :adapter) = dioWith(
      (options, _) => throwDio(options, DioExceptionType.connectionError),
    );

    await expectLater(
      dio.get<dynamic>('pokemon/25'),
      throwsA(isA<DioException>()),
    );

    expect(adapter.request, hasLength(1));
  });

  test('does not retry a cancelled request', () async {
    final (:dio, :adapter) = dioWith(
      (options, _) => throwDio(options, DioExceptionType.cancel),
    );

    await expectLater(
      dio.get<dynamic>('pokemon/25'),
      throwsA(isA<DioException>()),
    );

    expect(adapter.request, hasLength(1));

    expect(delays, isEmpty);
  });
}
