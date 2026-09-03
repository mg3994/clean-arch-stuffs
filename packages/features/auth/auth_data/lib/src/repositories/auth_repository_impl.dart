import 'package:auth_domain/auth_domain.dart';
import 'package:core_domain/core_domain.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<User>> login({required String email, required String password}) async {
    try {
      final userDto = await remoteDataSource.login(email, password);
      return Result.success(userDto.toDomain());
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    return Result.success(null);
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    return Result.success(null);
  }
}
