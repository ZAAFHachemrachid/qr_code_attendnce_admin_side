import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/common/selectable_data_table.dart';
import '../../providers/student_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/tab_provider.dart';
import '../enums/management_tab.dart';
import '../widgets/student_form.dart';
import '../widgets/details_tab.dart';

class StudentsPage extends ConsumerWidget {
  const StudentsPage({super.key});

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
    final selectedStudentId = ref.watch(studentsTabNotifierProvider).selectedId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students Management'),
      ),
      body: Row(
        children: [
          // Left side - Table View
          Expanded(
            flex: 2,
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: studentsAsync.when(
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
                    onSelect: (item) {
                      // Set the selected student for the right panel
                      ref
                          .read(studentsTabNotifierProvider.notifier)
                          .selectItem(item['id']);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error: ${error.toString()}'),
                ),
              ),
            ),
          ),

          // Right side - Action Tabs
          Expanded(
            flex: 1,
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Create'),
                        Tab(text: 'Update'),
                        Tab(text: 'Delete'),
                        Tab(text: 'Details'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: StudentForm(
                              onSubmit: (firstName,
                                  lastName,
                                  phone,
                                  studentNumber,
                                  groupId,
                                  email,
                                  password) async {
                                try {
                                  await ref
                                      .read(studentNotifierProvider.notifier)
                                      .addStudent(
                                        email: email,
                                        password: password,
                                        firstName: firstName,
                                        lastName: lastName,
                                        phone: phone,
                                        studentNumber: studentNumber,
                                      );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Student added successfully'),
                                      ),
                                    );
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
                          ),
                          if (selectedStudentId != null) ...[
                            const Center(child: Text('Update')), // Placeholder
                            const Center(child: Text('Delete')), // Placeholder
                            const DetailsTab(isStudent: true),
                          ] else ...[
                            const Center(
                              child: Text('Select a student to update'),
                            ),
                            const Center(
                              child: Text('Select a student to delete'),
                            ),
                            const Center(
                              child: Text('Select a student to view details'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
