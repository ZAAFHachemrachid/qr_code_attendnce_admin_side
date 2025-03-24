import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/department_model.dart';

part 'department_repository.g.dart';

class DepartmentRepository {
  final SupabaseClient _client;

  DepartmentRepository(this._client);

  Future<List<DepartmentModel>> getAllDepartments() async {
    final response = await _client
        .from('departments')
        .select()
        .order('name', ascending: true);

    return (response as List)
        .map((dept) => DepartmentModel.fromJson(dept))
        .toList();
  }

  Future<DepartmentModel> createDepartment({
    required String name,
    required String code,
  }) async {
    try {
      final response = await _client
          .from('departments')
          .insert({
            'name': name,
            'code': code,
          })
          .select()
          .single();

      return DepartmentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create department: ${e.toString()}');
    }
  }

  Future<DepartmentModel> updateDepartment({
    required String id,
    required String name,
    required String code,
  }) async {
    try {
      final response = await _client
          .from('departments')
          .update({
            'name': name,
            'code': code,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      return DepartmentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update department: ${e.toString()}');
    }
  }

  Future<void> deleteDepartment(String id) async {
    try {
      await _client.from('departments').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete department: ${e.toString()}');
    }
  }
}

@riverpod
DepartmentRepository departmentRepository(DepartmentRepositoryRef ref) {
  return DepartmentRepository(Supabase.instance.client);
}
