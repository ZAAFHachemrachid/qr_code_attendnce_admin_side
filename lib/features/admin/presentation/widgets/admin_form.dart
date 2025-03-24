import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/admin_model.dart';
import '../../providers/admin_provider.dart';

class AdminForm extends ConsumerStatefulWidget {
  final AdminModel? admin;

  const AdminForm({super.key, this.admin});

  @override
  ConsumerState<AdminForm> createState() => _AdminFormState();
}

class _AdminFormState extends ConsumerState<AdminForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  String _accessLevel = 'limited';

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.admin?.firstName);
    _lastNameController = TextEditingController(text: widget.admin?.lastName);
    _phoneController = TextEditingController(text: widget.admin?.phone);
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    if (widget.admin != null) {
      _accessLevel = widget.admin!.accessLevel;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final formNotifier = ref.read(adminFormNotifierProvider.notifier);
      await formNotifier.submitForm(
        id: widget.admin?.id,
        email: _emailController.text,
        password: _passwordController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        accessLevel: _accessLevel,
      );

      if (mounted && context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(adminFormNotifierProvider, (previous, next) {
      if (next is AsyncError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final formState = ref.watch(adminFormNotifierProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.admin == null ? 'Create Admin' : 'Edit Admin',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (widget.admin == null) ...[
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
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
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a first name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a last name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _accessLevel,
              decoration: const InputDecoration(
                labelText: 'Access Level',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'limited',
                  child: Text('Limited'),
                ),
                DropdownMenuItem(
                  value: 'super',
                  child: Text('Super Admin'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _accessLevel = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: formState.isLoading ? null : _submitForm,
                  child: formState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
