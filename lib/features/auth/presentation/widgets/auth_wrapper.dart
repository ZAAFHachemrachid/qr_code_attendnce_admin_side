import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../pages/login_page.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AuthWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    print('AuthWrapper - initState called');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    print('AuthWrapper build');
    print('- User: ${authState.user?.email}');
    print('- IsLoading: ${authState.isLoading}');
    print('- Error: ${authState.error}');

    if (authState.isLoading) {
      print('AuthWrapper - Showing loading state');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authState.user == null) {
      print('AuthWrapper - No user, showing login page');
      return const LoginPage();
    }

    print('AuthWrapper - User authenticated, showing main content');
    return widget.child;
  }
}

class AuthGuard extends ConsumerWidget {
  final Widget child;

  const AuthGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    if (authState.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      });
    }

    return child;
  }
}
