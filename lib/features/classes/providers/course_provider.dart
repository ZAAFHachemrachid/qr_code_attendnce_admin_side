import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/course_model.dart';
import '../data/repositories/course_repository.dart';

part 'course_provider.g.dart';

@riverpod
class AsyncCourseList extends _$AsyncCourseList {
  @override
  FutureOr<List<CourseModel>> build() async {
    return _fetchCourses();
  }

  Future<List<CourseModel>> _fetchCourses() async {
    try {
      final courses = await ref.read(courseRepositoryProvider).getAllCourses();
      return courses;
    } catch (e, stackTrace) {
      debugPrint('Error fetching courses: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> addCourse({
    required String code,
    required String title,
    String? description,
    required int creditHours,
    required String departmentId,
    required int yearOfStudy,
    required String semester,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(courseRepositoryProvider).createCourse(
            code: code,
            title: title,
            description: description,
            creditHours: creditHours,
            departmentId: departmentId,
            yearOfStudy: yearOfStudy,
            semester: semester,
          );
      return _fetchCourses();
    });
  }

  Future<void> updateCourse({
    required String id,
    required String code,
    required String title,
    String? description,
    required int creditHours,
    required String departmentId,
    required int yearOfStudy,
    required String semester,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(courseRepositoryProvider).updateCourse(
            id: id,
            code: code,
            title: title,
            description: description,
            creditHours: creditHours,
            departmentId: departmentId,
            yearOfStudy: yearOfStudy,
            semester: semester,
          );
      return _fetchCourses();
    });
  }

  Future<void> deleteCourse(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(courseRepositoryProvider).deleteCourse(id);
      return _fetchCourses();
    });
  }
}
