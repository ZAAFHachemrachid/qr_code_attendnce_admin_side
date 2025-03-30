import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group_model.dart';
import '../models/student_model.dart';

part 'group_repository.g.dart';

class GroupRepository {
  final SupabaseClient _client;

  GroupRepository(this._client);

  Future<List<GroupModel>> getAllGroups() async {
    try {
      final response = await _client
          .from('student_groups')
          .select()
          .order('created_at', ascending: false);

      debugPrint('getAllGroups response: $response');

      return (response as List).map((group) {
        try {
          return GroupModel.fromJson(group);
        } catch (e, stackTrace) {
          debugPrint('Error parsing group data: $group');
          debugPrint('Error: $e');
          debugPrint('Stack trace: $stackTrace');
          rethrow;
        }
      }).toList();
    } catch (e, stackTrace) {
      debugPrint('Error in getAllGroups: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<StudentModel>> getGroupStudents(String groupId) async {
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
          ''').eq('role', 'student').eq('student_profiles.group_id', groupId);

      debugPrint('getGroupStudents response: $response');

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
      debugPrint('Error in getGroupStudents: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<GroupModel> createGroup({
    required String departmentId,
    required int academicYear,
    required int currentYear,
    required String section,
    String? name,
  }) async {
    try {
      final response = await _client
          .from('student_groups')
          .insert({
            'department_id': departmentId,
            'academic_year': academicYear,
            'current_year': currentYear,
            'section': section,
            'name': name,
          })
          .select()
          .single();

      debugPrint('createGroup response: $response');
      return GroupModel.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint('Error in createGroup: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<GroupModel> updateGroup({
    required String id,
    required String departmentId,
    required int academicYear,
    required int currentYear,
    required String section,
    String? name,
  }) async {
    try {
      final response = await _client
          .from('student_groups')
          .update({
            'department_id': departmentId,
            'academic_year': academicYear,
            'current_year': currentYear,
            'section': section,
            'name': name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      debugPrint('updateGroup response: $response');
      return GroupModel.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint('Error in updateGroup: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to update group: ${e.toString()}');
    }
  }

  Future<void> deleteGroup(String id) async {
    try {
      debugPrint('Deleting group with ID: $id');

      // First update all students in this group to have no group
      await _client
          .from('student_profiles')
          .update({'group_id': null}).eq('group_id', id);
      debugPrint('Removed group reference from students');

      // Then delete the group
      await _client.from('student_groups').delete().eq('id', id);
      debugPrint('Deleted group');
    } catch (e, stackTrace) {
      debugPrint('Error in deleteGroup: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to delete group: ${e.toString()}');
    }
  }

  Future<void> assignStudentsToGroup({
    required String groupId,
    required List<String> studentIds,
  }) async {
    try {
      for (final id in studentIds) {
        await _client.from('student_profiles').update({
          'group_id': groupId,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', id);
      }

      debugPrint('Assigned students to group: $studentIds');
    } catch (e, stackTrace) {
      debugPrint('Error in assignStudentsToGroup: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to assign students to group: ${e.toString()}');
    }
  }

  Future<void> removeStudentsFromGroup(List<String> studentIds) async {
    try {
      for (final id in studentIds) {
        await _client.from('student_profiles').update({
          'group_id': null,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', id);
      }

      debugPrint('Removed students from group: $studentIds');
    } catch (e, stackTrace) {
      debugPrint('Error in removeStudentsFromGroup: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to remove students from group: ${e.toString()}');
    }
  }
}

@Riverpod(keepAlive: true)
GroupRepository groupRepository(GroupRepositoryRef ref) {
  return GroupRepository(Supabase.instance.client);
}
