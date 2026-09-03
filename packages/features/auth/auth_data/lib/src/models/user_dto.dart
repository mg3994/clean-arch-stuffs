import 'package:auth_domain/auth_domain.dart';

class UserDto {
  final String id;
  final String email;
  final String name;
  final String token;

  UserDto({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'token': token,
    };
  }

  User toDomain() {
    return User(
      id: id,
      email: email,
      name: name,
      token: token,
    );
  }

  factory UserDto.fromDomain(User user) {
    return UserDto(
      id: user.id,
      email: user.email,
      name: user.name,
      token: user.token,
    );
  }
}
