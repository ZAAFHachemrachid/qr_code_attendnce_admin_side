import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/teacher_model.dart';
import '../data/repositories/teacher_repository.dart';

part 'teacher_provider.g.dart';

@riverpod
class TeacherList extends _$TeacherList {
  @override
  Future<List<TeacherModel>> build() {
    return ref.read(teacherRepositoryProvider).getAllTeachers();
  }

  Future<void> addTeacher({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    required String employeeId,
    required String departmentId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final teacher = await ref.read(teacherRepositoryProvider).createTeacher(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            employeeId: employeeId,
            departmentId: departmentId,
          );

      final currentTeachers = [...?state.value];
      return [teacher, ...currentTeachers];
    });
  }

  Future<void> updateTeacher({
    required String id,
    required String firstName,
    required String lastName,
    String? phone,
    required String employeeId,
    required String departmentId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updatedTeacher =
          await ref.read(teacherRepositoryProvider).updateTeacher(
                id: id,
                firstName: firstName,
                lastName: lastName,
                phone: phone,
                employeeId: employeeId,
                departmentId: departmentId,
              );

      final currentTeachers = [...?state.value];
      final index = currentTeachers.indexWhere((t) => t.id == id);
      if (index != -1) {
        currentTeachers[index] = updatedTeacher;
      }
      return currentTeachers;
    });
  }

  Future<void> deleteTeacher(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(teacherRepositoryProvider).deleteTeacher(id);
      final currentTeachers = [...?state.value];
      return currentTeachers.where((t) => t.id != id).toList();
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(teacherRepositoryProvider).getAllTeachers(),
    );
  }
}
