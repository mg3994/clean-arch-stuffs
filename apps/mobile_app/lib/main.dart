import 'package:flutter/material.dart';
import 'package:auth_presentation/auth_presentation.dart';
import 'package:blog_presentation/blog_presentation.dart';
import 'package:core_ui/core_ui.dart';
import 'di/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ServiceLocator().setup();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modular Monorepo Shell App',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) => LoginScreen(
          controller: ServiceLocator().authController,
          onLoginSuccess: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BlogFeedScreen(
                  controller: ServiceLocator().blogController,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
