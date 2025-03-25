import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/student_provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/tab_provider.dart';
import '../enums/management_tab.dart';

class DeleteConfirmationDialog extends ConsumerWidget {
  final bool isStudent;
  final String id;
  final String name;

  const DeleteConfirmationDialog({
    super.key,
    required this.isStudent,
    required this.id,
    required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabProvider = isStudent ? studentsTabProvider : groupsTabProvider;

    return AlertDialog(
      title: Text('Delete ${isStudent ? 'Student' : 'Group'}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete ${isStudent ? 'student' : 'group'}:',
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (!isStudent) ...[
            const SizedBox(height: 16),
            const Text(
              'Warning: This will unassign all students from this group.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Reset tab to view
            ref.read(tabProvider.notifier).state = ManagementTab.view;
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            try {
              if (isStudent) {
                await ref
                    .read(studentNotifierProvider.notifier)
                    .deleteStudent(id);
              } else {
                await ref.read(groupNotifierProvider.notifier).deleteGroup(id);
              }

              if (context.mounted) {
                Navigator.of(context).pop();
                // Reset tab to view
                ref.read(tabProvider.notifier).state = ManagementTab.view;
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${isStudent ? 'Student' : 'Group'} deleted successfully',
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
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
