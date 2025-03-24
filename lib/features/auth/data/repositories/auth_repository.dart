import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Verify that the user is an admin
      if (response.user != null) {
        final userProfile = await _client
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .eq('role', 'admin')
            .single();

        if (userProfile == null) {
          await _client.auth.signOut();
          throw Exception('Access denied: Not an admin user');
        }
      }

      return response;
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    try {
      // 1. Create auth user
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Failed to create user');
      }

      // 2. Create profile as admin
      await _client.from('profiles').insert({
        'id': response.user!.id,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'role': 'admin', // Set role as admin
      });

      // 3. Create admin profile
      await _client.from('admin_profiles').insert({
        'id': response.user!.id,
        'access_level': 'limited', // Default to limited access
      });

      return response;
    } catch (e) {
      // If any step fails, attempt to clean up
      if (currentUser != null) {
        try {
          await _client.auth.admin.deleteUser(currentUser!.id);
        } catch (_) {
          // Ignore cleanup errors
        }
      }
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Failed to send reset password email: ${e.toString()}');
    }
  }

  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to update password: ${e.toString()}');
    }
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(Supabase.instance.client);
}

@Riverpod(keepAlive: true)
Stream<AuthState> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}
