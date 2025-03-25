import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/common/selectable_data_table.dart';
import '../../providers/student_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/tab_provider.dart';
import '../enums/management_tab.dart';
import 'student_form.dart';
import 'management_tab_view.dart';
import 'details_tab.dart';
import 'delete_confirmation_dialog.dart';

class StudentsManagementView extends ConsumerWidget {
  const StudentsManagementView({super.key});

  String _getGroupName(
      String? studentGroupId, AsyncValue<List<dynamic>> groupsAsync) {
    if (studentGroupId == null) return '-';

    switch (groupsAsync) {
      case AsyncData(:final value):
        final group = value.where((g) => g.id == studentGroupId).firstOrNull;
        if (group != null) {
          return group.name ?? '${group.academicYear}-${group.section}';
        }
      default:
        return '-';
    }
    return '-';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentNotifierProvider);
    final groupsAsync = ref.watch(groupNotifierProvider);
    final tabState = ref.watch(studentsTabNotifierProvider);

    Widget buildViewTab() {
      return studentsAsync.when(
        data: (students) {
          final data = students.map((student) {
            return {
              'id': student.id,
              'student_number': student.studentNumber,
              'first_name': student.firstName,
              'last_name': student.lastName,
              'phone': student.phone ?? '-',
              'group': _getGroupName(student.groupId, groupsAsync),
            };
          }).toList();

          return SelectableDataTable(
            columns: const [
              DataColumn(label: Text('Student Number')),
              DataColumn(label: Text('First Name')),
              DataColumn(label: Text('Last Name')),
              DataColumn(label: Text('Phone')),
              DataColumn(label: Text('Group')),
            ],
            data: data,
            noDataMessage: 'No students found',
            isLoading: studentsAsync is AsyncLoading,
            errorMessage: studentsAsync is AsyncError
                ? studentsAsync.error.toString()
                : null,
            onAdd: (_) {
              ref.read(studentsTabProvider.notifier).state =
                  ManagementTab.create;
            },
            onEdit: (item) {
              ref.read(studentsTabNotifierProvider.notifier)
                ..setTab(ManagementTab.update)
                ..selectItem(item['id']);
            },
            onDelete: (item) {
              showDialog(
                context: context,
                builder: (context) => DeleteConfirmationDialog(
                  isStudent: true,
                  id: item['id'],
                  name:
                      '${item['first_name']} ${item['last_name']} (${item['student_number']})',
                ),
              );
            },
            onSelect: (item) {
              ref.read(studentsTabNotifierProvider.notifier)
                ..setTab(ManagementTab.details)
                ..selectItem(item['id']);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      );
    }

    Widget buildCreateTab() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: StudentForm(
          onSubmit: (firstName, lastName, phone, studentNumber, groupId, email,
              password) async {
            try {
              await ref.read(studentNotifierProvider.notifier).addStudent(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName,
                    phone: phone,
                    studentNumber: studentNumber,
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Student added successfully')),
                );
                ref.read(studentsTabProvider.notifier).state =
                    ManagementTab.view;
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      );
    }

    Widget buildDeleteTab() {
      if (tabState.selectedId == null) {
        return const Center(
          child: Text('Select a student to delete'),
        );
      }

      final student = studentsAsync.maybeWhen(
        data: (students) =>
            students.where((s) => s.id == tabState.selectedId).firstOrNull,
        orElse: () => null,
      );

      if (student == null) {
        return const Center(
          child: Text('Student not found'),
        );
      }

      return Center(
        child: DeleteConfirmationDialog(
          isStudent: true,
          id: student.id,
          name:
              '${student.firstName} ${student.lastName} (${student.studentNumber})',
        ),
      );
    }

    return ManagementTabView(
      title: 'Students Management',
      tabProvider: studentsTabProvider,
      hideUpdateDelete: false,
      views: [
        buildViewTab(),
        buildCreateTab(),
        const Center(child: Text('Update')), // Update tab placeholder
        buildDeleteTab(),
        const DetailsTab(isStudent: true),
      ],
    );
  }
}
