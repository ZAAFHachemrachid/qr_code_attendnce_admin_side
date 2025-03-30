import 'package:flutter/material.dart';
import 'course_form.dart';

class CourseFormDialog extends StatelessWidget {
  final String? id;
  final String? code;
  final String? title;
  final String? description;
  final int? creditHours;
  final String? departmentId;
  final int? yearOfStudy;
  final String? semester;

  const CourseFormDialog({
    super.key,
    this.id,
    this.code,
    this.title,
    this.description,
    this.creditHours,
    this.departmentId,
    this.yearOfStudy,
    this.semester,
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
                id == null ? 'Add Course' : 'Edit Course',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              CourseForm(
                id: id,
                code: code,
                title: title,
                description: description,
                creditHours: creditHours,
                departmentId: departmentId,
                yearOfStudy: yearOfStudy,
                semester: semester,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
