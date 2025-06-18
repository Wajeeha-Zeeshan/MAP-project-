import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  String? _role; // “Student” or “Tutor”

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ───── Name ─────
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // ───── Email ─────
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (v) =>
                        v == null || !v.contains('@')
                            ? 'Enter a valid email'
                            : null,
              ),
              const SizedBox(height: 16),

              // ───── Password ─────
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator:
                    (v) =>
                        (v == null || v.length < 6) ? 'Min 6 characters' : null,
              ),
              const SizedBox(height: 16),

              // ───── Age ─────
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator:
                    (v) =>
                        (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter age' : null,
              ),
              const SizedBox(height: 16),

              // ───── Role dropdown ─────
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'Student', child: Text('Student')),
                  DropdownMenuItem(value: 'Tutor', child: Text('Tutor')),
                ],
                onChanged: (val) => setState(() => _role = val),
                validator: (v) => v == null ? 'Please choose role' : null,
              ),
              const SizedBox(height: 24),

              // ───── Error message ─────
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    auth.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // ───── Register button / progress ─────
              auth.loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      await auth.signUp(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                        name: _nameController.text.trim(),
                        role: _role!,
                        age: int.parse(_ageController.text.trim()),
                      );

                      if (auth.error == null && context.mounted) {
                        Navigator.pop(context); // back to login / home
                      }
                    },
                    child: const Text('Register'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
