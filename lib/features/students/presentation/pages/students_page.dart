import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/common/selectable_data_table.dart';
import '../../../../features/groups/providers/group_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/tab_provider.dart';
import '../enums/management_tab.dart';
import '../widgets/student_form.dart';
import '../widgets/details_tab.dart';

class StudentsPage extends ConsumerStatefulWidget {
  const StudentsPage({super.key});

  @override
  ConsumerState<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends ConsumerState<StudentsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: ManagementTab.values.length,
      vsync: this,
      initialIndex: ManagementTab.view.index,
    );
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      ref.read(studentsTabProvider.notifier).state =
          ManagementTab.values[_tabController.index];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentNotifierProvider);
    final groupsAsync = ref.watch(groupNotifierProvider);
    final selectedStudentId = ref.watch(studentsTabNotifierProvider).selectedId;
    final currentTab = ref.watch(studentsTabProvider);

    // Keep tab controller in sync with provider state
    if (_tabController.index != currentTab.index) {
      _tabController.animateTo(currentTab.index);
    }

    return Column(
      children: [
        // Management Tabs
        Material(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: TabBar(
            controller: _tabController,
            tabs: ManagementTab.values
                .map((tab) => Tab(text: tab.label))
                .toList(),
          ),
        ),
        // Content Area
        Expanded(
          child: Row(
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
                          ref
                              .read(studentsTabNotifierProvider.notifier)
                              .selectItem(item['id']);
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text('Error: ${error.toString()}'),
                    ),
                  ),
                ),
              ),
              // Right side - Action Panel
              if (currentTab != ManagementTab.view) ...[
                Expanded(
                  flex: 1,
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildActionPanel(
                        context,
                        ref,
                        currentTab,
                        selectedStudentId,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionPanel(BuildContext context, WidgetRef ref,
      ManagementTab currentTab, String? selectedStudentId) {
    switch (currentTab) {
      case ManagementTab.create:
        return StudentForm(
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
        );
      case ManagementTab.update:
        return selectedStudentId != null
            ? const Center(child: Text('Update')) // TODO: Implement update form
            : const Center(child: Text('Select a student to update'));
      case ManagementTab.delete:
        return selectedStudentId != null
            ? const Center(
                child: Text('Delete')) // TODO: Implement delete confirmation
            : const Center(child: Text('Select a student to delete'));
      case ManagementTab.details:
        return selectedStudentId != null
            ? const DetailsTab(isStudent: true)
            : const Center(child: Text('Select a student to view details'));
      default:
        return const SizedBox.shrink();
    }
  }
}
