import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../data/models/auth_state.dart';
import '../data/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AppAuthState build() {
    return AppAuthState(
      user: ref.watch(authRepositoryProvider).currentUser,
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await ref.read(authRepositoryProvider).signIn(
            email: email,
            password: password,
          );

      state = state.copyWith(
        user: ref.read(authRepositoryProvider).currentUser,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await ref.read(authRepositoryProvider).signUp(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
          );

      state = state.copyWith(
        user: ref.read(authRepositoryProvider).currentUser,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await ref.read(authRepositoryProvider).signOut();
      state = state.copyWith(
        user: null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await ref.read(authRepositoryProvider).resetPassword(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await ref.read(authRepositoryProvider).updatePassword(newPassword);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}
