import 'package:flutter/material.dart';
import '../pages/admin_signup_page.dart';
import '../pages/login_page.dart';

class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Theme.of(context),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => const LoginPage(),
            );
          case '/signup':
            return MaterialPageRoute(
              builder: (_) => const AdminSignUpPage(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const LoginPage(),
            );
        }
      },
    );
  }
}
