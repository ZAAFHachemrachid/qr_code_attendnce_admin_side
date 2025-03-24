import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/department_model.dart';
import '../data/repositories/department_repository.dart';

part 'department_list_provider.g.dart';

@riverpod
class DepartmentList extends _$DepartmentList {
  @override
  Future<List<DepartmentModel>> build() {
    return ref.read(departmentRepositoryProvider).getAllDepartments();
  }

  Future<void> addDepartment({
    required String name,
    required String code,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final department =
          await ref.read(departmentRepositoryProvider).createDepartment(
                name: name,
                code: code,
              );

      final currentDepartments = [...?state.value];
      return [department, ...currentDepartments];
    });
  }

  Future<void> updateDepartment({
    required String id,
    required String name,
    required String code,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updatedDepartment =
          await ref.read(departmentRepositoryProvider).updateDepartment(
                id: id,
                name: name,
                code: code,
              );

      final currentDepartments = [...?state.value];
      final index = currentDepartments.indexWhere((d) => d.id == id);
      if (index != -1) {
        currentDepartments[index] = updatedDepartment;
      }
      return currentDepartments;
    });
  }

  Future<void> deleteDepartment(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(departmentRepositoryProvider).deleteDepartment(id);
      final currentDepartments = [...?state.value];
      return currentDepartments.where((d) => d.id != id).toList();
    });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(departmentRepositoryProvider).getAllDepartments(),
    );
  }
}
