import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/common/selectable_data_table.dart';
import '../../providers/student_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/tab_provider.dart';
import '../enums/management_tab.dart';
import '../widgets/group_form.dart';
import '../widgets/details_tab.dart';

class GroupsPage extends ConsumerStatefulWidget {
  const GroupsPage({super.key});

  @override
  ConsumerState<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends ConsumerState<GroupsPage>
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
      ref.read(groupsTabProvider.notifier).state =
          ManagementTab.values[_tabController.index];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(groupNotifierProvider);
    final studentsAsync = ref.watch(studentNotifierProvider);
    final selectedGroupId = ref.watch(groupsTabNotifierProvider).selectedId;
    final currentTab = ref.watch(groupsTabProvider);

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
                          ref
                              .read(groupsTabNotifierProvider.notifier)
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
                        selectedGroupId,
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
      ManagementTab currentTab, String? selectedGroupId) {
    switch (currentTab) {
      case ManagementTab.create:
        return GroupForm(
          onSubmit:
              (departmentId, academicYear, currentYear, section, name) async {
            try {
              await ref.read(groupNotifierProvider.notifier).addGroup(
                    departmentId: departmentId,
                    academicYear: academicYear,
                    currentYear: currentYear,
                    section: section,
                    name: name,
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Group added successfully')),
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
        return selectedGroupId != null
            ? const Center(child: Text('Update')) // TODO: Implement update form
            : const Center(child: Text('Select a group to update'));
      case ManagementTab.delete:
        return selectedGroupId != null
            ? const Center(
                child: Text('Delete')) // TODO: Implement delete confirmation
            : const Center(child: Text('Select a group to delete'));
      case ManagementTab.details:
        return selectedGroupId != null
            ? const DetailsTab(isStudent: false)
            : const Center(child: Text('Select a group to view details'));
      default:
        return const SizedBox.shrink();
    }
  }
}
