import 'package:equatable/equatable.dart';

import '../error/failure.dart';

sealed class Result<T> extends Equatable {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}

final class Failed<T> extends Result<T> {
  const Failed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
