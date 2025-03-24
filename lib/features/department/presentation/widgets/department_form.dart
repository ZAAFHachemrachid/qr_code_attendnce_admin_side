import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/department_list_provider.dart';

class DepartmentForm extends ConsumerStatefulWidget {
  final String? id;
  final String? name;
  final String? code;

  const DepartmentForm({
    super.key,
    this.id,
    this.name,
    this.code,
  });

  @override
  ConsumerState<DepartmentForm> createState() => _DepartmentFormState();
}

class _DepartmentFormState extends ConsumerState<DepartmentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _codeController = TextEditingController(text: widget.code);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (widget.id == null) {
        // Create new department
        await ref.read(departmentListProvider.notifier).addDepartment(
              name: _nameController.text.trim(),
              code: _codeController.text.trim(),
            );
      } else {
        // Update existing department
        await ref.read(departmentListProvider.notifier).updateDepartment(
              id: widget.id!,
              name: _nameController.text.trim(),
              code: _codeController.text.trim(),
            );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter department name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Code
          TextFormField(
            controller: _codeController,
            decoration: const InputDecoration(labelText: 'Code'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter department code';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Submit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.id == null ? 'Create' : 'Update'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
