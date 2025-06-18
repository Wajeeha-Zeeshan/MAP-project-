import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class PasswordRecoveryView extends StatefulWidget {
  const PasswordRecoveryView({super.key});

  @override
  State<PasswordRecoveryView> createState() => _PasswordRecoveryViewState();
}

class _PasswordRecoveryViewState extends State<PasswordRecoveryView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Recover Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Enter your email to receive a password reset link.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator:
                    (v) =>
                        v == null || !v.contains('@')
                            ? 'Enter a valid email'
                            : null,
              ),
              const SizedBox(height: 24),

              // ─── Error Message ───
              if (auth.error != null)
                Text(auth.error!, style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 16),

              // ─── Send Link Button ───
              auth.loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    child: const Text('Send Reset Link'),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      await auth.sendResetEmail(_emailController.text.trim());

                      if (auth.error == null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reset link sent to your email.'),
                          ),
                        );
                        Navigator.pop(context);
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
