import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/admin_model.dart';
import '../../providers/admin_provider.dart';
import '../../../../shared/widgets/common/data_table_widget.dart';
import '../widgets/admin_form_dialog.dart';

class AdminPage extends ConsumerWidget {
  const AdminPage({super.key});

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AdminFormDialog(),
    );
  }

  void _showEditDialog(BuildContext context, AdminModel admin) {
    showDialog(
      context: context,
      builder: (context) => AdminFormDialog(admin: admin),
    );
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, AdminModel admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Admin'),
        content: Text(
          'Are you sure you want to delete ${admin.firstName} ${admin.lastName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(adminNotifierProvider.notifier)
                  .deleteAdmin(admin.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminsAsync = ref.watch(adminNotifierProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Management',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: adminsAsync.when(
              data: (admins) => DataTableWidget(
                columns: const [
                  CustomDataColumn(
                    label: 'Name',
                    field: 'name',
                  ),
                  CustomDataColumn(
                    label: 'Email',
                    field: 'email',
                  ),
                  CustomDataColumn(
                    label: 'Access Level',
                    field: 'accessLevel',
                  ),
                  CustomDataColumn(
                    label: 'Phone',
                    field: 'phone',
                  ),
                  CustomDataColumn(
                    label: 'Created At',
                    field: 'createdAt',
                  ),
                ],
                data: admins
                    .map((admin) => {
                          'id': admin.id,
                          'name': '${admin.firstName} ${admin.lastName}',
                          'accessLevel': admin.accessLevel == 'super'
                              ? 'Super Admin'
                              : 'Limited Admin',
                          'phone': admin.phone ?? '-',
                          'createdAt':
                              DateFormat('MMM d, yyyy').format(admin.createdAt),
                          '_original': admin,
                        })
                    .toList(),
                onAdd: () => _showCreateDialog(context),
                onEdit: (item) => _showEditDialog(
                  context,
                  item['_original'] as AdminModel,
                ),
                onDelete: (item) => _showDeleteDialog(
                  context,
                  ref,
                  item['_original'] as AdminModel,
                ),
                noDataMessage: 'No admins found',
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${error.toString()}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => ref.invalidate(adminNotifierProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
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
