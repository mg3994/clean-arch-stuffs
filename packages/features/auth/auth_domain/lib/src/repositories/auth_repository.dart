import 'package:core_domain/core_domain.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Result<User>> login({required String email, required String password});
  Future<Result<void>> logout();
  Future<Result<User?>> getCurrentUser();
}
