import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/group_model.dart';
import '../data/models/student_model.dart';
import '../data/repositories/group_repository.dart';

part 'group_provider.g.dart';

@riverpod
class GroupNotifier extends _$GroupNotifier {
  @override
  Future<List<GroupModel>> build() async {
    return _fetchGroups();
  }

  Future<List<GroupModel>> _fetchGroups() async {
    try {
      final groups = await ref.read(groupRepositoryProvider).getAllGroups();
      return groups;
    } catch (e, stackTrace) {
      debugPrint('Error fetching groups: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> addGroup({
    required String departmentId,
    required int academicYear,
    required int currentYear,
    required String section,
    String? name,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(groupRepositoryProvider).createGroup(
            departmentId: departmentId,
            academicYear: academicYear,
            currentYear: currentYear,
            section: section,
            name: name,
          );
      state = AsyncValue.data(await _fetchGroups());
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      debugPrint('Error adding group: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateGroup({
    required String id,
    required String departmentId,
    required int academicYear,
    required int currentYear,
    required String section,
    String? name,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(groupRepositoryProvider).updateGroup(
            id: id,
            departmentId: departmentId,
            academicYear: academicYear,
            currentYear: currentYear,
            section: section,
            name: name,
          );
      state = AsyncValue.data(await _fetchGroups());
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      debugPrint('Error updating group: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> deleteGroup(String id) async {
    state = const AsyncLoading();
    try {
      await ref.read(groupRepositoryProvider).deleteGroup(id);
      state = AsyncValue.data(await _fetchGroups());
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      debugPrint('Error deleting group: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> assignStudentsToGroup({
    required String groupId,
    required List<String> studentIds,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(groupRepositoryProvider).assignStudentsToGroup(
            groupId: groupId,
            studentIds: studentIds,
          );
      state = AsyncValue.data(await _fetchGroups());
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      debugPrint('Error assigning students to group: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> removeStudentsFromGroup(List<String> studentIds) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(groupRepositoryProvider)
          .removeStudentsFromGroup(studentIds);
      state = AsyncValue.data(await _fetchGroups());
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      debugPrint('Error removing students from group: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}

@riverpod
Future<List<StudentModel>> groupStudents(
  GroupStudentsRef ref,
  String groupId,
) async {
  final repository = ref.read(groupRepositoryProvider);
  return repository.getGroupStudents(groupId);
}
