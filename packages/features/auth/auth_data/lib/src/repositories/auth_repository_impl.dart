import 'package:auth_domain/auth_domain.dart';
import 'package:core_domain/core_domain.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<User>> login({required String email, required String password}) async {
    try {
      final userDto = await remoteDataSource.login(email, password);
      await localDataSource.saveUser(userDto);
      return Result.success(userDto.toDomain());
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await localDataSource.clearUser();
      return Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final cachedUser = await localDataSource.getUser();
      return Result.success(cachedUser?.toDomain());
    } catch (e) {
      return Result.failure(CacheFailure(e.toString()));
    }
  }
}
