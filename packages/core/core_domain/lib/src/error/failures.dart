abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => '$runtimeType: $message (code: $statusCode)';
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server Error', int? statusCode])
      : super(message, statusCode: statusCode);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache Error', int? statusCode])
      : super(message, statusCode: statusCode);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network Connection Error', int? statusCode])
      : super(message, statusCode: statusCode);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String message = 'Unauthorized Action', int? statusCode])
      : super(message, statusCode: statusCode);
}
