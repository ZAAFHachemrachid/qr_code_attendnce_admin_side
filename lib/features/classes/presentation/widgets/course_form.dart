import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/course_provider.dart';
import '../../../department/providers/department_provider.dart';

class CourseForm extends ConsumerStatefulWidget {
  final String? id;
  final String? code;
  final String? title;
  final String? description;
  final int? creditHours;
  final String? departmentId;
  final int? yearOfStudy;
  final String? semester;

  const CourseForm({
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
  ConsumerState<CourseForm> createState() => _CourseFormState();
}

class _CourseFormState extends ConsumerState<CourseForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _creditHoursController;
  late final TextEditingController _yearOfStudyController;
  String? _selectedDepartmentId;
  String? _selectedSemester;

  final List<String> _semesters = [
    'semester1',
    'semester2',
    'semester3',
    'semester4',
    'semester5',
  ];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.code);
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);
    _creditHoursController =
        TextEditingController(text: widget.creditHours?.toString());
    _yearOfStudyController =
        TextEditingController(text: widget.yearOfStudy?.toString());
    _selectedDepartmentId = widget.departmentId;
    _selectedSemester = widget.semester;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _creditHoursController.dispose();
    _yearOfStudyController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (widget.id == null) {
        // Create new course
        await ref.read(asyncCourseListProvider.notifier).addCourse(
              code: _codeController.text.trim(),
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              creditHours: int.parse(_creditHoursController.text.trim()),
              departmentId: _selectedDepartmentId ?? '',
              yearOfStudy: int.parse(_yearOfStudyController.text.trim()),
              semester: _selectedSemester!,
            );
      } else {
        // Update existing course
        await ref.read(asyncCourseListProvider.notifier).updateCourse(
              id: widget.id!,
              code: _codeController.text.trim(),
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              creditHours: int.parse(_creditHoursController.text.trim()),
              departmentId: _selectedDepartmentId ?? '',
              yearOfStudy: int.parse(_yearOfStudyController.text.trim()),
              semester: _selectedSemester!,
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
    final departmentsAsync = ref.watch(departmentsProvider);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Course Code
          TextFormField(
            controller: _codeController,
            decoration: const InputDecoration(labelText: 'Course Code'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter course code';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Title
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              helperText: 'Optional',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Credit Hours
          TextFormField(
            controller: _creditHoursController,
            decoration: const InputDecoration(labelText: 'Credit Hours'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter credit hours';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Year of Study
          TextFormField(
            controller: _yearOfStudyController,
            decoration: const InputDecoration(labelText: 'Year of Study'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter year of study';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              final year = int.parse(value);
              if (year < 1 || year > 5) {
                return 'Year must be between 1 and 5';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Semester
          DropdownButtonFormField<String>(
            value: _selectedSemester,
            decoration: const InputDecoration(labelText: 'Semester'),
            items: _semesters.map((semester) {
              return DropdownMenuItem<String>(
                value: semester,
                child: Text(semester),
              );
            }).toList(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a semester';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _selectedSemester = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Department Dropdown
          departmentsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (error, stackTrace) => Text('Error: ${error.toString()}'),
            data: (departments) {
              return DropdownButtonFormField<String?>(
                value: _selectedDepartmentId,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  helperText: 'Required',
                ),
                items: departments.map((department) {
                  return DropdownMenuItem<String?>(
                    value: department['id'] as String,
                    child: Text(department['name'] as String),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a department';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _selectedDepartmentId = value;
                  });
                },
              );
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
