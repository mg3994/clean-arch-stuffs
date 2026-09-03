import 'package:flutter_test/flutter_test.dart';
import 'package:auth_domain/auth_domain.dart';
import 'package:core_domain/core_domain.dart';

class FakeAuthRepository implements AuthRepository {
  User? userToReturn;
  Failure? failureToReturn;

  @override
  Future<Result<User>> login({required String email, required String password}) async {
    if (failureToReturn != null) {
      return Result.failure(failureToReturn!);
    }
    return Result.success(userToReturn!);
  }

  @override
  Future<Result<User?>> getCurrentUser() async => Result.success(null);

  @override
  Future<Result<void>> logout() async => Result.success(null);
}

void main() {
  late LoginUser useCase;
  late FakeAuthRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeAuthRepository();
    useCase = LoginUser(fakeRepository);
  });

  test('should return failure if email is invalid format', () async {
    final result = await useCase(const LoginParams(email: 'invalid_email', password: 'password123'));

    expect(result.isFailure, true);
    expect(result.failure, isA<ServerFailure>());
    expect(result.failure.message, contains('Invalid email address format'));
  });

  test('should return failure if password length is less than 6', () async {
    final result = await useCase(const LoginParams(email: 'user@test.com', password: '123'));

    expect(result.isFailure, true);
    expect(result.failure.message, contains('Password must be at least 6 characters'));
  });

  test('should return User on successful repository login', () async {
    const expectedUser = User(
      id: '1',
      email: 'user@test.com',
      name: 'Test User',
      token: 'jwt_token',
    );
    fakeRepository.userToReturn = expectedUser;

    final result = await useCase(const LoginParams(email: 'user@test.com', password: 'password123'));

    expect(result.isSuccess, true);
    expect(result.data, equals(expectedUser));
  });
}
