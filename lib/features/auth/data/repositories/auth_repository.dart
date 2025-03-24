import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/constants/supabase_constants.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final SupabaseClient _client;
  late final SupabaseClient _adminClient;

  AuthRepository(this._client) {
    _adminClient = SupabaseClient(
      SupabaseConstants.url,
      SupabaseConstants.serviceKey,
    );
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> createFirstSuperAdmin() async {
    try {
      // Check if any admin exists
      final adminsCount =
          await _adminClient.from('profiles').count().eq('role', 'admin');

      if (adminsCount == 0) {
        // Create first super admin with default credentials
        final response = await _adminClient.auth.admin.createUser(
          AdminUserAttributes(
            email: 'admin@system.com',
            password: 'admin123',
            emailConfirm: true,
          ),
        );

        if (response.user == null) {
          throw Exception('Failed to create super admin');
        }

        // Create profile
        await _adminClient.from('profiles').insert({
          'id': response.user!.id,
          'first_name': 'System',
          'last_name': 'Admin',
          'role': 'admin',
        });

        // Create admin profile with super access
        await _adminClient.from('admin_profiles').insert({
          'id': response.user!.id,
          'access_level': 'super',
        });

        print('First super admin created successfully');
      }
    } catch (e) {
      print('Error creating first super admin: ${e.toString()}');
    }
  }

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
            .maybeSingle();

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

  Future<UserResponse> createAdmin({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    required String accessLevel,
  }) async {
    UserResponse? authResponse;
    try {
      // 1. Create auth user with service role
      authResponse = await _adminClient.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true,
        ),
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user');
      }

      // 2. Create profile
      await _adminClient.from('profiles').insert({
        'id': authResponse.user!.id,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'role': 'admin',
      });

      // 3. Create admin profile
      await _adminClient.from('admin_profiles').insert({
        'id': authResponse.user!.id,
        'access_level': accessLevel,
      });

      return authResponse;
    } catch (e) {
      // If any step fails, attempt to clean up
      try {
        if (authResponse?.user != null) {
          await _adminClient.auth.admin.deleteUser(authResponse!.user!.id);
        }
      } catch (_) {
        // Ignore cleanup errors
      }
      throw Exception('Failed to create admin: ${e.toString()}');
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
  final repo = AuthRepository(Supabase.instance.client);
  // Initialize first super admin if needed
  repo.createFirstSuperAdmin();
  return repo;
}

@Riverpod(keepAlive: true)
Stream<AuthState> authStateChanges(AuthStateChangesRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}
