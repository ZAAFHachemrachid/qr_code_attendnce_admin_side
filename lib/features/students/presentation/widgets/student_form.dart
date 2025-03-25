import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudentForm extends ConsumerStatefulWidget {
  final String? studentId;
  final String? initialFirstName;
  final String? initialLastName;
  final String? initialPhone;
  final String? initialStudentNumber;
  final String? initialGroupId;
  final void Function(
    String firstName,
    String lastName,
    String phone,
    String studentNumber,
    String groupId,
    String email,
    String password,
  ) onSubmit;

  const StudentForm({
    super.key,
    this.studentId,
    this.initialFirstName,
    this.initialLastName,
    this.initialPhone,
    this.initialStudentNumber,
    this.initialGroupId,
    required this.onSubmit,
  });

  @override
  ConsumerState<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends ConsumerState<StudentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _studentNumberController;
  late final TextEditingController _groupIdController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.initialFirstName);
    _lastNameController = TextEditingController(text: widget.initialLastName);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _studentNumberController =
        TextEditingController(text: widget.initialStudentNumber);
    _groupIdController = TextEditingController(text: widget.initialGroupId);
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _studentNumberController.dispose();
    _groupIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'First Name',
              hintText: 'Enter first name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter first name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last Name',
              hintText: 'Enter last name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter last name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone',
              hintText: 'Enter phone number',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _studentNumberController,
            decoration: const InputDecoration(
              labelText: 'Student Number',
              hintText: 'Enter student number',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter student number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _groupIdController,
            decoration: const InputDecoration(
              labelText: 'Group ID',
              hintText: 'Enter group ID',
            ),
          ),
          if (widget.studentId == null) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter email',
              ),
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
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter password',
              ),
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
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSubmit(
                  _firstNameController.text,
                  _lastNameController.text,
                  _phoneController.text,
                  _studentNumberController.text,
                  _groupIdController.text,
                  _emailController.text,
                  _passwordController.text,
                );
              }
            },
            child: Text(
                widget.studentId == null ? 'Add Student' : 'Update Student'),
          ),
        ],
      ),
    );
  }
}
