import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class ProfileView extends StatelessWidget {
  final UserModel user;

  const ProfileView({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user.name}'),
            Text('Email: ${user.email}'),
            Text('Role: ${user.role}'),
            Text('Age: ${user.age}'),
            const SizedBox(height: 20),
            if (user.role == 'student')
              const Text('Welcome Student! View your courses here.')
            else if (user.role == 'teacher')
              const Text('Welcome Teacher! Manage your classes here.'),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
