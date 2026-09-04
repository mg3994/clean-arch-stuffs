import 'package:flutter_test/flutter_test.dart';
import 'package:auth_data/auth_data.dart';

void main() {
  late InMemoryAuthLocalDataSourceImpl localDataSource;

  setUp(() {
    localDataSource = InMemoryAuthLocalDataSourceImpl();
  });

  test('saves and retrieves user dto locally', () async {
    final userDto = UserDto(
      id: 'u_10',
      email: 'cache@test.com',
      name: 'Cache User',
      token: 'jwt_cache_token',
    );

    await localDataSource.saveUser(userDto);
    final retrieved = await localDataSource.getUser();

    expect(retrieved, isNotNull);
    expect(retrieved?.id, 'u_10');
    expect(retrieved?.email, 'cache@test.com');
  });

  test('clears cached user dto', () async {
    final userDto = UserDto(
      id: 'u_10',
      email: 'cache@test.com',
      name: 'Cache User',
      token: 'jwt_cache_token',
    );

    await localDataSource.saveUser(userDto);
    await localDataSource.clearUser();
    final retrieved = await localDataSource.getUser();

    expect(retrieved, isNull);
  });
}
