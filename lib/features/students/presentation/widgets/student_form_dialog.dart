import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/student_provider.dart';
import 'student_form.dart';

class StudentFormDialog extends ConsumerWidget {
  final String? studentId;
  final String? initialFirstName;
  final String? initialLastName;
  final String? initialPhone;
  final String? initialStudentNumber;
  final String? initialGroupId;

  const StudentFormDialog({
    super.key,
    this.studentId,
    this.initialFirstName,
    this.initialLastName,
    this.initialPhone,
    this.initialStudentNumber,
    this.initialGroupId,
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
                    studentId == null ? 'Add Student' : 'Update Student',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StudentForm(
                studentId: studentId,
                initialFirstName: initialFirstName,
                initialLastName: initialLastName,
                initialPhone: initialPhone,
                initialStudentNumber: initialStudentNumber,
                initialGroupId: initialGroupId,
                onSubmit: (firstName, lastName, phone, studentNumber, groupId,
                    email, password) async {
                  try {
                    if (studentId == null) {
                      // Create new student
                      await ref
                          .read(studentNotifierProvider.notifier)
                          .addStudent(
                            email: email,
                            password: password,
                            firstName: firstName,
                            lastName: lastName,
                            phone: phone.isNotEmpty ? phone : null,
                            studentNumber: studentNumber,
                            groupId: groupId.isNotEmpty ? groupId : null,
                          );
                    } else {
                      // Update existing student
                      await ref
                          .read(studentNotifierProvider.notifier)
                          .updateStudent(
                            id: studentId!,
                            firstName: firstName,
                            lastName: lastName,
                            phone: phone.isNotEmpty ? phone : null,
                            studentNumber: studentNumber,
                            groupId: groupId.isNotEmpty ? groupId : null,
                          );
                    }
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            studentId == null
                                ? 'Student added successfully'
                                : 'Student updated successfully',
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
