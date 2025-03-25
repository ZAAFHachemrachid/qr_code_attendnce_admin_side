import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/student_model.dart';
import '../data/repositories/student_repository.dart';

part 'student_provider.g.dart';

@riverpod
class StudentNotifier extends _$StudentNotifier {
  @override
  Future<List<StudentModel>> build() async {
    return _fetchStudents();
  }

  Future<List<StudentModel>> _fetchStudents() async {
    try {
      final students =
          await ref.read(studentRepositoryProvider).getAllStudents();
      return students;
    } catch (e, stackTrace) {
      debugPrint('Error fetching students: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> addStudent({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    required String studentNumber,
    String? groupId,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(studentRepositoryProvider).createStudent(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            studentNumber: studentNumber,
            groupId: groupId,
          );
      state = AsyncValue.data(await _fetchStudents());
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      debugPrint('Error adding student: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateStudent({
    required String id,
    required String firstName,
    required String lastName,
    String? phone,
    required String studentNumber,
    String? groupId,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(studentRepositoryProvider).updateStudent(
            id: id,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            studentNumber: studentNumber,
            groupId: groupId,
          );
      state = AsyncValue.data(await _fetchStudents());
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      debugPrint('Error updating student: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> deleteStudent(String id) async {
    state = const AsyncLoading();
    try {
      await ref.read(studentRepositoryProvider).deleteStudent(id);
      state = AsyncValue.data(await _fetchStudents());
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      debugPrint('Error deleting student: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
