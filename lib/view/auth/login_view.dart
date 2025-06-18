import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ─── Email ───
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

              // ─── Password ───
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator:
                    (v) =>
                        v == null || v.length < 6 ? 'Min 6 characters' : null,
              ),
              const SizedBox(height: 24),

              // ─── Error message ───
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    auth.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // ─── Login button or loader ───
              auth.loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    child: const Text('Login'),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      await auth.login(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      );

                      // On success: clear stack & go to home (‘/’ → HomeScreen)
                      if (auth.error == null && context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (_) => false,
                        );
                      }
                    },
                  ),

              const SizedBox(height: 16),

              // ─── Forgot password ───
              TextButton(
                onPressed: () async {
                  final email = _emailController.text.trim();
                  if (email.isEmpty || !email.contains('@')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter your email first.')),
                    );
                    return;
                  }
                  await auth.sendResetEmail(email);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reset link sent!')),
                    );
                  }
                },
                child: const Text('Forgot password?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
