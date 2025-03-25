import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/common/selectable_data_table.dart';
import '../../providers/student_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/tab_provider.dart';
import '../enums/management_tab.dart';
import '../widgets/group_form.dart';
import '../widgets/details_tab.dart';

class GroupsPage extends ConsumerWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupNotifierProvider);
    final studentsAsync = ref.watch(studentNotifierProvider);
    final selectedGroupId = ref.watch(groupsTabNotifierProvider).selectedId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups Management'),
      ),
      body: Row(
        children: [
          // Left side - Table View
          Expanded(
            flex: 2,
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: groupsAsync.when(
                data: (groups) {
                  final data = groups.map((group) {
                    int studentCount = 0;
                    if (studentsAsync case AsyncData(:final value)) {
                      studentCount =
                          value.where((s) => s.groupId == group.id).length;
                    }

                    return {
                      'id': group.id,
                      'name': group.name ?? '-',
                      'academic_year': group.academicYear.toString(),
                      'current_year': group.currentYear.toString(),
                      'section': group.section,
                      'students': studentCount.toString(),
                    };
                  }).toList();

                  return SelectableDataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Academic Year')),
                      DataColumn(label: Text('Current Year')),
                      DataColumn(label: Text('Section')),
                      DataColumn(label: Text('Students')),
                    ],
                    data: data,
                    noDataMessage: 'No groups found',
                    isLoading: groupsAsync is AsyncLoading,
                    errorMessage: groupsAsync is AsyncError
                        ? groupsAsync.error.toString()
                        : null,
                    onSelect: (item) {
                      // Set the selected group for the right panel
                      ref
                          .read(groupsTabNotifierProvider.notifier)
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
                            child: GroupForm(
                              onSubmit: (departmentId, academicYear,
                                  currentYear, section, name) async {
                                try {
                                  await ref
                                      .read(groupNotifierProvider.notifier)
                                      .addGroup(
                                        departmentId: departmentId,
                                        academicYear: academicYear,
                                        currentYear: currentYear,
                                        section: section,
                                        name: name,
                                      );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Group added successfully'),
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
                          if (selectedGroupId != null) ...[
                            const Center(child: Text('Update')), // Placeholder
                            const Center(child: Text('Delete')), // Placeholder
                            const DetailsTab(isStudent: false),
                          ] else ...[
                            const Center(
                              child: Text('Select a group to update'),
                            ),
                            const Center(
                              child: Text('Select a group to delete'),
                            ),
                            const Center(
                              child: Text('Select a group to view details'),
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
