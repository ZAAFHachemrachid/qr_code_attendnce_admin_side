import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/department_list_provider.dart';
import '../../../../shared/widgets/common/data_table_widget.dart';
import '../widgets/department_form_dialog.dart';

class DepartmentPage extends ConsumerWidget {
  const DepartmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departmentsAsync = ref.watch(departmentListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Departments'),
        centerTitle: true,
      ),
      body: departmentsAsync.when(
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
                  ref.read(departmentListProvider.notifier).refresh();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (departments) {
          final columns = [
            const CustomDataColumn(
              label: 'Code',
              field: 'code',
            ),
            const CustomDataColumn(
              label: 'Name',
              field: 'name',
            ),
            CustomDataColumn(
              label: 'Created At',
              field: 'createdAt',
              customBuilder: (value) => Text(
                value != null
                    ? (value as DateTime).toLocal().toString().split(' ')[0]
                    : '',
              ),
            ),
          ];

          final data = departments
              .map((dept) => {
                    'id': dept.id,
                    'code': dept.code,
                    'name': dept.name,
                    'createdAt': dept.createdAt,
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
                  builder: (context) => const DepartmentFormDialog(),
                );

                if (result == true) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Department added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  ref.read(departmentListProvider.notifier).refresh();
                }
              },
              onEdit: (department) async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => DepartmentFormDialog(
                    id: department['id'] as String,
                    code: department['code'] as String,
                    name: department['name'] as String,
                  ),
                );

                if (result == true) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Department updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  ref.read(departmentListProvider.notifier).refresh();
                }
              },
              onDelete: (department) async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: Text(
                      'Are you sure you want to delete ${department['name']}? This action cannot be undone.',
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
                        .read(departmentListProvider.notifier)
                        .deleteDepartment(department['id'] as String);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Department deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Error deleting department: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              noDataMessage: 'No departments found',
            ),
          );
        },
      ),
    );
  }
}
