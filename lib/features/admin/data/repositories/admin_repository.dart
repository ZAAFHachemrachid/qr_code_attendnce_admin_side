import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/admin_model.dart';

part 'admin_repository.g.dart';

class AdminRepository {
  final SupabaseClient _client;

  AdminRepository(this._client);

  Future<List<AdminModel>> getAllAdmins() async {
    final response = await _client
        .from('profiles')
        .select('*, admin_profiles(*)')
        .eq('role', 'admin')
        .order('created_at', ascending: false);

    return (response as List).map((admin) {
      final adminProfile = admin['admin_profiles'][0] as Map<String, dynamic>;
      return AdminModel(
        id: admin['id'] as String,
        firstName: admin['first_name'] as String,
        lastName: admin['last_name'] as String,
        phone: admin['phone'] as String?,
        accessLevel: adminProfile['access_level'] as String,
        createdAt: DateTime.parse(admin['created_at'] as String),
        updatedAt: DateTime.parse(admin['updated_at'] as String),
      );
    }).toList();
  }

  Future<AdminModel> createAdmin({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    required String accessLevel,
  }) async {
    String? createdUserId;
    try {
      // 1. Create auth user
      final authResponse = await _client.auth.admin.createUser(
        AdminUserAttributes(
          email: email,
          password: password,
          emailConfirm: true,
        ),
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user');
      }

      createdUserId = authResponse.user!.id;

      // 2. Create profile
      await _client.from('profiles').insert({
        'id': createdUserId,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'role': 'admin',
      });

      // 3. Create admin profile
      await _client.from('admin_profiles').insert({
        'id': createdUserId,
        'access_level': accessLevel,
      });

      // 4. Fetch and return the created admin
      final response = await _client
          .from('profiles')
          .select('*, admin_profiles(*)')
          .eq('id', createdUserId)
          .single();

      final adminProfile =
          response['admin_profiles'][0] as Map<String, dynamic>;
      return AdminModel(
        id: response['id'] as String,
        firstName: response['first_name'] as String,
        lastName: response['last_name'] as String,
        phone: response['phone'] as String?,
        accessLevel: adminProfile['access_level'] as String,
        createdAt: DateTime.parse(response['created_at'] as String),
        updatedAt: DateTime.parse(response['updated_at'] as String),
      );
    } catch (e) {
      // If any step fails, attempt to clean up
      if (createdUserId != null) {
        try {
          await _client.auth.admin.deleteUser(createdUserId);
        } catch (_) {
          // Ignore cleanup errors
        }
      }
      rethrow;
    }
  }

  Future<AdminModel> updateAdmin({
    required String id,
    required String firstName,
    required String lastName,
    String? phone,
    required String accessLevel,
  }) async {
    try {
      // 1. Update profile
      await _client.from('profiles').update({
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);

      // 2. Update admin profile
      await _client.from('admin_profiles').update({
        'access_level': accessLevel,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);

      // 3. Fetch and return the updated admin
      final response = await _client
          .from('profiles')
          .select('*, admin_profiles(*)')
          .eq('id', id)
          .single();

      final adminProfile =
          response['admin_profiles'][0] as Map<String, dynamic>;
      return AdminModel(
        id: response['id'] as String,
        firstName: response['first_name'] as String,
        lastName: response['last_name'] as String,
        phone: response['phone'] as String?,
        accessLevel: adminProfile['access_level'] as String,
        createdAt: DateTime.parse(response['created_at'] as String),
        updatedAt: DateTime.parse(response['updated_at'] as String),
      );
    } catch (e) {
      throw Exception('Failed to update admin: ${e.toString()}');
    }
  }

  Future<void> deleteAdmin(String id) async {
    try {
      // Since we have RLS policies and cascading deletes set up,
      // deleting the auth user will trigger deletion of related records
      await _client.auth.admin.deleteUser(id);
    } catch (e) {
      throw Exception('Failed to delete admin: ${e.toString()}');
    }
  }
}

@Riverpod(keepAlive: true)
AdminRepository adminRepository(AdminRepositoryRef ref) {
  return AdminRepository(Supabase.instance.client);
}
