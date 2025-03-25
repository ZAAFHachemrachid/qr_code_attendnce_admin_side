import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_model.dart';

part 'student_repository.g.dart';

class StudentRepository {
  final SupabaseClient _client;

  StudentRepository(this._client);

  Future<List<StudentModel>> getAllStudents() async {
    try {
      final response = await _client.from('profiles').select('''
            id,
            first_name,
            last_name,
            phone,
            created_at,
            updated_at,
            student_profiles!inner (
              student_number,
              group_id
            )
          ''').eq('role', 'student').order('created_at', ascending: false);

      debugPrint('getAllStudents response: $response');

      return (response as List).map((student) {
        try {
          return StudentModel.fromJson(student);
        } catch (e, stackTrace) {
          debugPrint('Error parsing student data: $student');
          debugPrint('Error: $e');
          debugPrint('Stack trace: $stackTrace');
          rethrow;
        }
      }).toList();
    } catch (e, stackTrace) {
      debugPrint('Error in getAllStudents: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<StudentModel> createStudent({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    required String studentNumber,
    String? groupId,
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
        'role': 'student',
      });

      // 3. Create student profile
      await _client.from('student_profiles').insert({
        'id': createdUserId,
        'student_number': studentNumber,
        'group_id': groupId,
      });

      // 4. Fetch and return the created student
      final response = await _client.from('profiles').select('''
            id,
            first_name,
            last_name,
            phone,
            created_at,
            updated_at,
            student_profiles!inner (
              student_number,
              group_id
            )
          ''').eq('id', createdUserId).single();

      debugPrint('createStudent response: $response');
      return StudentModel.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint('Error in createStudent: $e');
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

  Future<StudentModel> updateStudent({
    required String id,
    required String firstName,
    required String lastName,
    String? phone,
    required String studentNumber,
    String? groupId,
  }) async {
    try {
      // 1. Update profile
      await _client.from('profiles').update({
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);

      // 2. Update student profile
      await _client.from('student_profiles').update({
        'student_number': studentNumber,
        'group_id': groupId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);

      // 3. Fetch and return the updated student
      final response = await _client.from('profiles').select('''
            id,
            first_name,
            last_name,
            phone,
            created_at,
            updated_at,
            student_profiles!inner (
              student_number,
              group_id
            )
          ''').eq('id', id).single();

      debugPrint('updateStudent response: $response');
      return StudentModel.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint('Error in updateStudent: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to update student: ${e.toString()}');
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      debugPrint('Deleting student with ID: $id');

      // 1. Delete student_profiles record first
      await _client.from('student_profiles').delete().eq('id', id);
      debugPrint('Deleted student_profiles record');

      // 2. Delete profiles record
      await _client.from('profiles').delete().eq('id', id);
      debugPrint('Deleted profiles record');

      // 3. Finally delete the auth user
      await _client.auth.admin.deleteUser(id);
      debugPrint('Deleted auth user');
    } catch (e, stackTrace) {
      debugPrint('Error in deleteStudent: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to delete student: ${e.toString()}');
    }
  }
}

@Riverpod(keepAlive: true)
StudentRepository studentRepository(StudentRepositoryRef ref) {
  return StudentRepository(Supabase.instance.client);
}
