import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/common/selectable_data_table.dart';
import '../../providers/student_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/tab_provider.dart';
import '../enums/management_tab.dart';
import 'group_form.dart';
import 'management_tab_view.dart';
import 'details_tab.dart';
import 'delete_confirmation_dialog.dart';

class GroupsManagementView extends ConsumerWidget {
  const GroupsManagementView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupNotifierProvider);
    final studentsAsync = ref.watch(studentNotifierProvider);
    final tabState = ref.watch(groupsTabNotifierProvider);

    Widget buildViewTab() {
      return groupsAsync.when(
        data: (groups) {
          final data = groups.map((group) {
            int studentCount = 0;
            if (studentsAsync case AsyncData(:final value)) {
              studentCount = value.where((s) => s.groupId == group.id).length;
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
            errorMessage:
                groupsAsync is AsyncError ? groupsAsync.error.toString() : null,
            onAdd: (_) {
              ref.read(groupsTabProvider.notifier).state = ManagementTab.create;
            },
            onEdit: (item) {
              ref.read(groupsTabNotifierProvider.notifier)
                ..setTab(ManagementTab.update)
                ..selectItem(item['id']);
            },
            onDelete: (item) {
              showDialog(
                context: context,
                builder: (context) => DeleteConfirmationDialog(
                  isStudent: false,
                  id: item['id'],
                  name:
                      '${item['name']} (${item['academic_year']}-${item['section']})',
                ),
              );
            },
            onSelect: (item) {
              ref.read(groupsTabNotifierProvider.notifier)
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
        child: GroupForm(
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
                ref.read(groupsTabProvider.notifier).state = ManagementTab.view;
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
          child: Text('Select a group to delete'),
        );
      }

      final group = groupsAsync.maybeWhen(
        data: (groups) =>
            groups.where((g) => g.id == tabState.selectedId).firstOrNull,
        orElse: () => null,
      );

      if (group == null) {
        return const Center(
          child: Text('Group not found'),
        );
      }

      return Center(
        child: DeleteConfirmationDialog(
          isStudent: false,
          id: group.id,
          name:
              '${group.name ?? 'Unnamed Group'} (${group.academicYear}-${group.section})',
        ),
      );
    }

    return ManagementTabView(
      title: 'Groups Management',
      tabProvider: groupsTabProvider,
      hideUpdateDelete: false,
      views: [
        buildViewTab(),
        buildCreateTab(),
        const Center(child: Text('Update')), // Update tab placeholder
        buildDeleteTab(),
        const DetailsTab(isStudent: false),
      ],
    );
  }
}
