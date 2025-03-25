import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/student_model.dart';
import '../../data/models/group_model.dart';
import '../../providers/student_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/tab_provider.dart';

class DetailsTab extends ConsumerWidget {
  final bool isStudent;

  const DetailsTab({
    super.key,
    required this.isStudent,
  });

  Widget _buildStudentDetails(
    StudentModel student,
    AsyncValue<List<GroupModel>> groupsAsync,
  ) {
    String groupName = '-';

    switch (groupsAsync) {
      case AsyncData(:final value) when student.groupId != null:
        final group = value.where((g) => g.id == student.groupId).firstOrNull;
        if (group != null) {
          groupName = group.name ?? '${group.academicYear}-${group.section}';
        }
      default:
        groupName = '-';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text('Student Information'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Student Number: ${student.studentNumber}'),
              Text('Name: ${student.firstName} ${student.lastName}'),
              Text('Phone: ${student.phone ?? '-'}'),
              Text('Group: $groupName'),
            ],
          ),
        ),
        ListTile(
          title: const Text('Timestamps'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Created: ${student.createdAt.toLocal()}'),
              Text('Updated: ${student.updatedAt.toLocal()}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupDetails(
    GroupModel group,
    AsyncValue<List<StudentModel>> studentsAsync,
  ) {
    int studentCount = 0;

    switch (studentsAsync) {
      case AsyncData(:final value):
        studentCount = value.where((s) => s.groupId == group.id).length;
      default:
        studentCount = 0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text('Group Information'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${group.name ?? '-'}'),
              Text('Academic Year: ${group.academicYear}'),
              Text('Current Year: ${group.currentYear}'),
              Text('Section: ${group.section}'),
              Text('Number of Students: $studentCount'),
            ],
          ),
        ),
        ListTile(
          title: const Text('Timestamps'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Created: ${group.createdAt.toLocal()}'),
              Text('Updated: ${group.updatedAt.toLocal()}'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(
      isStudent ? studentsTabNotifierProvider : groupsTabNotifierProvider,
    );

    if (tabState.selectedId == null) {
      return const Center(
        child: Text('Select an item to view details'),
      );
    }

    if (isStudent) {
      final studentsAsync = ref.watch(studentNotifierProvider);
      final groupsAsync = ref.watch(groupNotifierProvider);

      return studentsAsync.when(
        data: (students) {
          final student =
              students.where((s) => s.id == tabState.selectedId).firstOrNull;

          if (student == null) {
            return const Center(child: Text('Student not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildStudentDetails(student, groupsAsync),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      );
    } else {
      final groupsAsync = ref.watch(groupNotifierProvider);
      final studentsAsync = ref.watch(studentNotifierProvider);

      return groupsAsync.when(
        data: (groups) {
          final group =
              groups.where((g) => g.id == tabState.selectedId).firstOrNull;

          if (group == null) {
            return const Center(child: Text('Group not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildGroupDetails(group, studentsAsync),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      );
    }
  }
}
