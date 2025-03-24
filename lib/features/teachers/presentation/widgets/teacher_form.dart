import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/teacher_provider.dart';
import '../../../department/providers/department_provider.dart';

class TeacherForm extends ConsumerStatefulWidget {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? employeeId;
  final String? departmentId;

  const TeacherForm({
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
  ConsumerState<TeacherForm> createState() => _TeacherFormState();
}

class _TeacherFormState extends ConsumerState<TeacherForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _employeeIdController;
  late final TextEditingController _passwordController;
  String? _selectedDepartmentId;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
    _employeeIdController = TextEditingController(text: widget.employeeId);
    _passwordController = TextEditingController();
    _selectedDepartmentId = widget.departmentId;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (widget.id == null) {
        // Create new teacher
        await ref.read(teacherListProvider.notifier).addTeacher(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              phone: _phoneController.text.trim(),
              employeeId: _employeeIdController.text.trim(),
              departmentId: _selectedDepartmentId ?? '',
            );
      } else {
        // Update existing teacher
        await ref.read(teacherListProvider.notifier).updateTeacher(
              id: widget.id!,
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              phone: _phoneController.text.trim(),
              employeeId: _employeeIdController.text.trim(),
              departmentId: _selectedDepartmentId ?? '',
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
          // First Name
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(labelText: 'First Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter first name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Last Name
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(labelText: 'Last Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter last name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email (only for new teachers)
          if (widget.id == null) ...[
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password (only for new teachers)
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],

          // Phone
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone'),
          ),
          const SizedBox(height: 16),

          // Employee ID
          TextFormField(
            controller: _employeeIdController,
            decoration: const InputDecoration(labelText: 'Employee ID'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter employee ID';
              }
              return null;
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
                  helperText: 'Optional - Can be assigned later',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      'Not Assigned',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  ...departments.map((department) {
                    return DropdownMenuItem<String?>(
                      value: department['id'] as String,
                      child: Text(department['name'] as String),
                    );
                  }).toList(),
                ],
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
