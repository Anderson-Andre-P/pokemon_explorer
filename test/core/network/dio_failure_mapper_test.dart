import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_explorer/core/error/failure.dart';

import 'package:pokemon_explorer/core/network/dio_failure_mapper.dart';

void main() {
  final options = RequestOptions(path: 'pokemon/25');

  DioException exceptionOf(DioExceptionType type, {Object? error}) =>
      DioException(requestOptions: options, type: type, error: error);

  DioException badResponse(int status) => DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<void>(requestOptions: options, statusCode: status),
  );

  group('mapDioException', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
      DioExceptionType.badCertificate,
    ]) {
      test('maps ${type.name} to NetworkFailure', () {
        expect(mapDioException(exceptionOf(type)), const NetworkFailure());
      });
    }

    test('maps a 404 response to NotFoundFailure', () {
      expect(mapDioException(badResponse(404)), const NotFoundFailure());
    });

    test('maps any other bad response to ServerFailure with its status', () {
      expect(
        mapDioException(badResponse(503)),
        const ServerFailure(statusCode: 503),
      );
    });

    test(
      'maps an unknown error caused by a SocketException to NetworkFailure',
      () {
        expect(
          mapDioException(
            exceptionOf(
              DioExceptionType.unknown,
              error: const SocketException('Failed host lookup'),
            ),
          ),
          const NetworkFailure(),
        );
      },
    );

    test('maps any other unknown error to UnexpectedFailure', () {
      expect(
        mapDioException(
          exceptionOf(DioExceptionType.unknown, error: StateError('Boom!')),
        ),
        const UnexpectedFailure(),
      );
    });

    test('maps a response transform timeout to UnexpectedFailure', () {
      expect(
        mapDioException(exceptionOf(DioExceptionType.transformTimeout)),
        const UnexpectedFailure(),
      );
    });

    test('maps a cancelled request to UnexpectedFailure', () {
      expect(
        mapDioException(exceptionOf(DioExceptionType.cancel)),
        const UnexpectedFailure(),
      );
    });
  });
}
