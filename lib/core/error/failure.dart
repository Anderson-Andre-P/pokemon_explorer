import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => const [];
}

final class NetworkFailure extends Failure {
  const NetworkFailure();
}

final class ServerFailure extends Failure {
  const ServerFailure({this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => [statusCode];
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure();
}

final class CacheFailure extends Failure {
  const CacheFailure();
}

final class OfflineDataUnavailableFailure extends Failure {
  const OfflineDataUnavailableFailure();
}

final class ValidationFailure extends Failure {
  const ValidationFailure();
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure();
}
