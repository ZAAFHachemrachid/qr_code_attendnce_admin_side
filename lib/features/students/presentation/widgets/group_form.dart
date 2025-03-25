import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupForm extends ConsumerStatefulWidget {
  final String? groupId;
  final String? initialDepartmentId;
  final int? initialAcademicYear;
  final int? initialCurrentYear;
  final String? initialSection;
  final String? initialName;
  final void Function(
    String departmentId,
    int academicYear,
    int currentYear,
    String section,
    String? name,
  ) onSubmit;

  const GroupForm({
    super.key,
    this.groupId,
    this.initialDepartmentId,
    this.initialAcademicYear,
    this.initialCurrentYear,
    this.initialSection,
    this.initialName,
    required this.onSubmit,
  });

  @override
  ConsumerState<GroupForm> createState() => _GroupFormState();
}

class _GroupFormState extends ConsumerState<GroupForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _departmentIdController;
  late final TextEditingController _academicYearController;
  late final TextEditingController _currentYearController;
  late final TextEditingController _sectionController;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _departmentIdController =
        TextEditingController(text: widget.initialDepartmentId);
    _academicYearController = TextEditingController(
      text: widget.initialAcademicYear?.toString(),
    );
    _currentYearController = TextEditingController(
      text: widget.initialCurrentYear?.toString(),
    );
    _sectionController = TextEditingController(text: widget.initialSection);
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _departmentIdController.dispose();
    _academicYearController.dispose();
    _currentYearController.dispose();
    _sectionController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TODO: Replace with department dropdown
          TextFormField(
            controller: _departmentIdController,
            decoration: const InputDecoration(
              labelText: 'Department',
              hintText: 'Select department',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a department';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _academicYearController,
            decoration: const InputDecoration(
              labelText: 'Academic Year',
              hintText: 'Enter academic year (e.g., 2025)',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter academic year';
              }
              final year = int.tryParse(value);
              if (year == null || year < 2000) {
                return 'Please enter a valid year';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _currentYearController,
            decoration: const InputDecoration(
              labelText: 'Current Year',
              hintText: 'Enter current year (1-5)',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter current year';
              }
              final year = int.tryParse(value);
              if (year == null || year < 1 || year > 5) {
                return 'Please enter a year between 1 and 5';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _sectionController,
            decoration: const InputDecoration(
              labelText: 'Section',
              hintText: 'Enter section (e.g., A, B)',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter section';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name (Optional)',
              hintText: 'Enter group name',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSubmit(
                  _departmentIdController.text,
                  int.parse(_academicYearController.text),
                  int.parse(_currentYearController.text),
                  _sectionController.text,
                  _nameController.text.isNotEmpty ? _nameController.text : null,
                );
              }
            },
            child: Text(widget.groupId == null ? 'Add Group' : 'Update Group'),
          ),
        ],
      ),
    );
  }
}
