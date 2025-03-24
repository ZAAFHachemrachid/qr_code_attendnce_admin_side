import 'package:flutter/material.dart';
import 'department_form.dart';

class DepartmentFormDialog extends StatelessWidget {
  final String? id;
  final String? name;
  final String? code;

  const DepartmentFormDialog({
    super.key,
    this.id,
    this.name,
    this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                id == null ? 'Add Department' : 'Edit Department',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              DepartmentForm(
                id: id,
                name: name,
                code: code,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
