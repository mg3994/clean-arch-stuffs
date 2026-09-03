import 'package:core_domain/core_domain.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}

class LoginUser implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  LoginUser(this.repository);

  @override
  Future<Result<User>> call(LoginParams params) async {
    if (params.email.isEmpty || !params.email.contains('@')) {
      return Result.failure(const ServerFailure('Invalid email address format'));
    }
    if (params.password.length < 6) {
      return Result.failure(const ServerFailure('Password must be at least 6 characters'));
    }
    return repository.login(email: params.email, password: params.password);
  }
}
