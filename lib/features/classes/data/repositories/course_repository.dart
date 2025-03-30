import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_model.dart';

part 'course_repository.g.dart';

class CourseRepository {
  final SupabaseClient _client;

  CourseRepository(this._client);

  Future<List<CourseModel>> getAllCourses() async {
    try {
      final response = await _client
          .from('courses')
          .select()
          .order('created_at', ascending: false);

      debugPrint('getAllCourses response: $response');

      return (response as List).map((course) {
        try {
          return CourseModel.fromJson(course);
        } catch (e, stackTrace) {
          debugPrint('Error parsing course data: $course');
          debugPrint('Error: $e');
          debugPrint('Stack trace: $stackTrace');
          rethrow;
        }
      }).toList();
    } catch (e, stackTrace) {
      debugPrint('Error in getAllCourses: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<CourseModel> createCourse({
    required String code,
    required String title,
    String? description,
    required int creditHours,
    required String departmentId,
    required int yearOfStudy,
    required String semester,
  }) async {
    try {
      final response = await _client
          .from('courses')
          .insert({
            'code': code,
            'title': title,
            'description': description,
            'credit_hours': creditHours,
            'department_id': departmentId,
            'year_of_study': yearOfStudy,
            'semester': semester,
          })
          .select()
          .single();

      debugPrint('createCourse response: $response');
      return CourseModel.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint('Error in createCourse: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to create course: ${e.toString()}');
    }
  }

  Future<CourseModel> updateCourse({
    required String id,
    required String code,
    required String title,
    String? description,
    required int creditHours,
    required String departmentId,
    required int yearOfStudy,
    required String semester,
  }) async {
    try {
      final response = await _client
          .from('courses')
          .update({
            'code': code,
            'title': title,
            'description': description,
            'credit_hours': creditHours,
            'department_id': departmentId,
            'year_of_study': yearOfStudy,
            'semester': semester,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      debugPrint('updateCourse response: $response');
      return CourseModel.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint('Error in updateCourse: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to update course: ${e.toString()}');
    }
  }

  Future<void> deleteCourse(String id) async {
    try {
      await _client.from('courses').delete().eq('id', id);
      debugPrint('Course deleted successfully');
    } catch (e, stackTrace) {
      debugPrint('Error in deleteCourse: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to delete course: ${e.toString()}');
    }
  }
}

@Riverpod(keepAlive: true)
CourseRepository courseRepository(CourseRepositoryRef ref) {
  return CourseRepository(Supabase.instance.client);
}
