import 'package:core_data/core_data.dart';
import '../models/user_dto.dart';

abstract class AuthRemoteDataSource {
  Future<UserDto> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final NetworkClient networkClient;

  AuthRemoteDataSourceImpl(this.networkClient);

  @override
  Future<UserDto> login(String email, String password) async {
    final response = await networkClient.post('/api/v1/auth/login', body: {
      'email': email,
      'password': password,
    });
    return UserDto.fromJson(response);
  }
}
