import '../models/user_dto.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserDto user);
  Future<UserDto?> getUser();
  Future<void> clearUser();
}

class InMemoryAuthLocalDataSourceImpl implements AuthLocalDataSource {
  UserDto? _cachedUser;

  @override
  Future<void> saveUser(UserDto user) async {
    _cachedUser = user;
  }

  @override
  Future<UserDto?> getUser() async {
    return _cachedUser;
  }

  @override
  Future<void> clearUser() async {
    _cachedUser = null;
  }
}
