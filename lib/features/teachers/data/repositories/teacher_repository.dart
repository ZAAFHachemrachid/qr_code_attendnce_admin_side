import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/teacher_model.dart';

part 'teacher_repository.g.dart';

class TeacherRepository {
  final SupabaseClient _client;

  TeacherRepository(this._client);

  Future<List<TeacherModel>> getAllTeachers() async {
    try {
      final response = await _client.from('profiles').select('''
            id,
            first_name,
            last_name,
            phone,
            created_at,
            updated_at,
            teacher_profiles!inner (
              employee_id,
              department_id
            )
          ''').eq('role', 'teacher').order('created_at', ascending: false);

      debugPrint('getAllTeachers response: $response');

      return (response as List).map((teacher) {
        try {
          return TeacherModel.fromJson(teacher);
        } catch (e, stackTrace) {
          debugPrint('Error parsing teacher data: $teacher');
          debugPrint('Error: $e');
          debugPrint('Stack trace: $stackTrace');
          rethrow;
        }
      }).toList();
    } catch (e, stackTrace) {
      debugPrint('Error in getAllTeachers: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<TeacherModel> createTeacher({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    required String employeeId,
    required String departmentId,
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
        'role': 'teacher',
      });

      // 3. Create teacher profile
      await _client.from('teacher_profiles').insert({
        'id': createdUserId,
        'employee_id': employeeId,
        'department_id': departmentId.isEmpty ? null : departmentId,
      });

      // 4. Fetch and return the created teacher
      final response = await _client.from('profiles').select('''
            id,
            first_name,
            last_name,
            phone,
            created_at,
            updated_at,
            teacher_profiles!inner (
              employee_id,
              department_id
            )
          ''').eq('id', createdUserId).single();

      debugPrint('createTeacher response: $response');
      return TeacherModel.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint('Error in createTeacher: $e');
      debugPrint('Stack trace: $stackTrace');

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

  Future<TeacherModel> updateTeacher({
    required String id,
    required String firstName,
    required String lastName,
    String? phone,
    required String employeeId,
    required String departmentId,
  }) async {
    try {
      // 1. Update profile
      await _client.from('profiles').update({
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);

      // 2. Update teacher profile
      await _client.from('teacher_profiles').update({
        'employee_id': employeeId,
        'department_id': departmentId.isEmpty ? null : departmentId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);

      // 3. Fetch and return the updated teacher
      final response = await _client.from('profiles').select('''
            id,
            first_name,
            last_name,
            phone,
            created_at,
            updated_at,
            teacher_profiles!inner (
              employee_id,
              department_id
            )
          ''').eq('id', id).single();

      debugPrint('updateTeacher response: $response');
      return TeacherModel.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint('Error in updateTeacher: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to update teacher: ${e.toString()}');
    }
  }

  Future<void> deleteTeacher(String id) async {
    try {
      debugPrint('Deleting teacher with ID: $id');

      // 1. Delete teacher_profiles record first
      await _client.from('teacher_profiles').delete().eq('id', id);
      debugPrint('Deleted teacher_profiles record');

      // 2. Delete profiles record
      await _client.from('profiles').delete().eq('id', id);
      debugPrint('Deleted profiles record');

      // 3. Finally delete the auth user
      await _client.auth.admin.deleteUser(id);
      debugPrint('Deleted auth user');
    } catch (e, stackTrace) {
      debugPrint('Error in deleteTeacher: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to delete teacher: ${e.toString()}');
    }
  }
}

@Riverpod(keepAlive: true)
TeacherRepository teacherRepository(TeacherRepositoryRef ref) {
  return TeacherRepository(Supabase.instance.client);
}
