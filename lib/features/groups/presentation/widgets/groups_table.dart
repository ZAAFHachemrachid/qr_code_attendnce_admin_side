import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/common/data_table_widget.dart';
import '../../../groups/providers/group_provider.dart';
import 'group_form_dialog.dart';

class GroupsTable extends ConsumerWidget {
  const GroupsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Student Groups',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const GroupFormDialog(),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Group'),
              ),
            ],
          ),
        ),
        Expanded(
          child: groupsAsync.when(
            data: (groups) {
              final data = groups.map((group) {
                return {
                  'id': group.id,
                  'academic_year': group.academicYear.toString(),
                  'current_year': group.currentYear.toString(),
                  'section': group.section,
                  'name': group.name ?? '-',
                  'department_id': group.departmentId,
                };
              }).toList();

              return DataTableWidget(
                columns: const [
                  CustomDataColumn(
                    label: 'Academic Year',
                    field: 'academic_year',
                  ),
                  CustomDataColumn(
                    label: 'Current Year',
                    field: 'current_year',
                  ),
                  CustomDataColumn(
                    label: 'Section',
                    field: 'section',
                  ),
                  CustomDataColumn(
                    label: 'Name',
                    field: 'name',
                  ),
                ],
                data: data,
                onAdd: () {
                  showDialog(
                    context: context,
                    builder: (context) => const GroupFormDialog(),
                  );
                },
                onEdit: (group) {
                  final groupModel = groups.firstWhere(
                    (g) => g.id == group['id'],
                  );
                  showDialog(
                    context: context,
                    builder: (context) => GroupFormDialog(
                      groupId: groupModel.id,
                      initialDepartmentId: groupModel.departmentId,
                      initialAcademicYear: groupModel.academicYear,
                      initialCurrentYear: groupModel.currentYear,
                      initialSection: groupModel.section,
                      initialName: groupModel.name,
                    ),
                  );
                },
                onDelete: (group) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Group'),
                      content: const Text(
                        'Are you sure you want to delete this group? All students will be unassigned from this group.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              await ref
                                  .read(groupNotifierProvider.notifier)
                                  .deleteGroup(group['id']);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Group deleted successfully',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                noDataMessage: 'No groups found',
                isLoading: groupsAsync is AsyncLoading,
                errorMessage: groupsAsync is AsyncError
                    ? groupsAsync.error.toString()
                    : null,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error: ${error.toString()}'),
            ),
          ),
        ),
      ],
    );
  }
}
