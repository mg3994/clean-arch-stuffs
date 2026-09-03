import 'package:flutter/foundation.dart';
import 'package:auth_domain/auth_domain.dart';

enum AuthStateStatus { initial, loading, authenticated, error }

class AuthState {
  final AuthStateStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStateStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStateStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthController extends ValueNotifier<AuthState> {
  final LoginUser _loginUser;

  AuthController(this._loginUser) : super(const AuthState());

  Future<void> login(String email, String password) async {
    value = value.copyWith(status: AuthStateStatus.loading, errorMessage: null);

    final result = await _loginUser(LoginParams(email: email, password: password));

    result.fold(
      (failure) {
        value = value.copyWith(
          status: AuthStateStatus.error,
          errorMessage: failure.message,
        );
      },
      (user) {
        value = value.copyWith(
          status: AuthStateStatus.authenticated,
          user: user,
        );
      },
    );
  }
}
