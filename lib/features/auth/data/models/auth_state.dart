import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@immutable
class AppAuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AppAuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AppAuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AppAuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
