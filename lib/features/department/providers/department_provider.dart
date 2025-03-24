import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'department_provider.g.dart';

@riverpod
Future<List<Map<String, dynamic>>> departments(DepartmentsRef ref) async {
  final response = await Supabase.instance.client
      .from('departments')
      .select('id, name')
      .order('name', ascending: true);

  return List<Map<String, dynamic>>.from(response);
}
