import '../error/failures.dart';

sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(Failure failure) = FailureResult<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  T get data => (this as Success<T>).data;
  Failure get failure => (this as FailureResult<T>).failure;

  R fold<R>(R Function(Failure failure) onFailure, R Function(T data) onSuccess) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).data);
    } else {
      return onFailure((this as FailureResult<T>).failure);
    }
  }
}

class Success<T> extends Result<T> {
  @override
  final T data;
  const Success(this.data);
}

class FailureResult<T> extends Result<T> {
  @override
  final Failure failure;
  const FailureResult(this.failure);
}
