import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/group_provider.dart';
import 'group_form.dart';

class GroupFormDialog extends ConsumerWidget {
  final String? groupId;
  final String? initialDepartmentId;
  final int? initialAcademicYear;
  final int? initialCurrentYear;
  final String? initialSection;
  final String? initialName;

  const GroupFormDialog({
    super.key,
    this.groupId,
    this.initialDepartmentId,
    this.initialAcademicYear,
    this.initialCurrentYear,
    this.initialSection,
    this.initialName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    groupId == null ? 'Add Group' : 'Update Group',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GroupForm(
                groupId: groupId,
                initialDepartmentId: initialDepartmentId,
                initialAcademicYear: initialAcademicYear,
                initialCurrentYear: initialCurrentYear,
                initialSection: initialSection,
                initialName: initialName,
                onSubmit: (departmentId, academicYear, currentYear, section,
                    name) async {
                  try {
                    if (groupId == null) {
                      // Create new group
                      await ref.read(groupNotifierProvider.notifier).addGroup(
                            departmentId: departmentId,
                            academicYear: academicYear,
                            currentYear: currentYear,
                            section: section,
                            name: name,
                          );
                    } else {
                      // Update existing group
                      await ref
                          .read(groupNotifierProvider.notifier)
                          .updateGroup(
                            id: groupId!,
                            departmentId: departmentId,
                            academicYear: academicYear,
                            currentYear: currentYear,
                            section: section,
                            name: name,
                          );
                    }
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            groupId == null
                                ? 'Group added successfully'
                                : 'Group updated successfully',
                          ),
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
            ],
          ),
        ),
      ),
    );
  }
}
