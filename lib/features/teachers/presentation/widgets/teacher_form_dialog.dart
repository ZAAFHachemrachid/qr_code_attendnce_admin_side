import 'package:flutter/material.dart';
import 'teacher_form.dart';

class TeacherFormDialog extends StatelessWidget {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? employeeId;
  final String? departmentId;

  const TeacherFormDialog({
    super.key,
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.employeeId,
    this.departmentId,
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
                id == null ? 'Add Teacher' : 'Edit Teacher',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TeacherForm(
                id: id,
                firstName: firstName,
                lastName: lastName,
                email: email,
                phone: phone,
                employeeId: employeeId,
                departmentId: departmentId,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
