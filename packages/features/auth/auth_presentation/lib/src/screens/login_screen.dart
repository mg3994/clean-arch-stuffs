import 'package:flutter/material.dart';
import 'package:core_ui/core_ui.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  final AuthController controller;
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.controller,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onAuthStateChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (widget.controller.value.status == AuthStateStatus.authenticated) {
      widget.onLoginSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthState>(
      valueListenable: widget.controller,
      builder: (context, state, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Login')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    state.errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ],
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Sign In',
                  isLoading: state.status == AuthStateStatus.loading,
                  onPressed: () {
                    widget.controller.login(
                      _emailController.text,
                      _passwordController.text,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
