import 'package:flutter_test/flutter_test.dart';
import 'package:auth_data/auth_data.dart';
import 'package:auth_domain/auth_domain.dart';

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  UserDto? dtoToReturn;
  bool shouldThrow = false;

  @override
  Future<UserDto> login(String email, String password) async {
    if (shouldThrow) {
      throw Exception('Server unreachable');
    }
    return dtoToReturn!;
  }
}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late InMemoryAuthLocalDataSourceImpl localDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    localDataSource = InMemoryAuthLocalDataSourceImpl();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: localDataSource,
    );
  });

  test('login returns User entity when remote data source returns UserDto and caches it', () async {
    mockRemoteDataSource.dtoToReturn = UserDto(
      id: 'usr_1',
      email: 'alex@example.com',
      name: 'Alex',
      token: 'token_xyz',
    );

    final result = await repository.login(email: 'alex@example.com', password: 'password123');

    expect(result.isSuccess, true);
    expect(result.data, isA<User>());
    expect(result.data.email, 'alex@example.com');

    final cachedUserResult = await repository.getCurrentUser();
    expect(cachedUserResult.isSuccess, true);
    expect(cachedUserResult.data?.email, 'alex@example.com');
  });

  test('login returns ServerFailure on exception', () async {
    mockRemoteDataSource.shouldThrow = true;

    final result = await repository.login(email: 'alex@example.com', password: 'password123');

    expect(result.isFailure, true);
    expect(result.failure.message, contains('Server unreachable'));
  });
}
