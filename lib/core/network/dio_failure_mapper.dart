import 'dart:io';

import 'package:dio/dio.dart';

import '../error/failure.dart';

Failure mapDioException(DioException exception) => switch (exception.type) {
  DioExceptionType.connectionTimeout ||
  DioExceptionType.sendTimeout ||
  DioExceptionType.receiveTimeout ||
  DioExceptionType.connectionError ||
  DioExceptionType.badCertificate => const NetworkFailure(),

  DioExceptionType.badResponse => switch (exception.response?.statusCode) {
    404 => const NotFoundFailure(),
    final status => ServerFailure(statusCode: status),
  },

  DioExceptionType.unknown when exception.error is SocketException =>
    const NetworkFailure(),

  DioExceptionType.unknown ||
  DioExceptionType.cancel ||
  DioExceptionType.transformTimeout => const UnexpectedFailure(),
};
