import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/teacher_provider.dart';
import '../../../../shared/widgets/common/data_table_widget.dart';
import '../widgets/teacher_form_dialog.dart';

class TeachersPage extends ConsumerWidget {
  const TeachersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersAsync = ref.watch(teacherListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachers'),
        centerTitle: true,
      ),
      body: teachersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error: ${error.toString()}',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(teacherListProvider.notifier).refresh();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (teachers) {
          final columns = [
            const CustomDataColumn(
              label: 'Name',
              field: 'name',
            ),
            const CustomDataColumn(
              label: 'Employee ID',
              field: 'employeeId',
            ),
            const CustomDataColumn(
              label: 'Phone',
              field: 'phone',
            ),
            CustomDataColumn(
              label: 'Department',
              field: 'department',
              customBuilder: (value) => Text(
                value as String? ?? 'Not Assigned',
                style: TextStyle(
                  color: value == null ? Colors.orange : null,
                  fontStyle: value == null ? FontStyle.italic : null,
                ),
              ),
            ),
          ];

          final data = teachers
              .map((teacher) => {
                    'id': teacher.id,
                    'name': '${teacher.firstName} ${teacher.lastName}',
                    'employeeId': teacher.employeeId,
                    'phone': teacher.phone ?? 'N/A',
                    'department': teacher.departmentId,
                    'firstName': teacher.firstName,
                    'lastName': teacher.lastName,
                  })
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: DataTableWidget(
              columns: columns,
              data: data,
              isLoading: false,
              onAdd: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => const TeacherFormDialog(),
                );

                if (result == true) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Teacher added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  ref.read(teacherListProvider.notifier).refresh();
                }
              },
              onEdit: (teacher) async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => TeacherFormDialog(
                    id: teacher['id'] as String,
                    firstName: teacher['firstName'] as String,
                    lastName: teacher['lastName'] as String,
                    phone: teacher['phone'] as String?,
                    employeeId: teacher['employeeId'] as String,
                    departmentId: teacher['department'] as String?,
                  ),
                );

                if (result == true) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Teacher updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  ref.read(teacherListProvider.notifier).refresh();
                }
              },
              onDelete: (teacher) async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: Text(
                      'Are you sure you want to delete ${teacher['name']}? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  try {
                    await ref
                        .read(teacherListProvider.notifier)
                        .deleteTeacher(teacher['id'] as String);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Teacher deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Error deleting teacher: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              noDataMessage: 'No teachers found',
            ),
          );
        },
      ),
    );
  }
}
