import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../tutor/tutor_list_view.dart';
import '../tutor/tutor_availability_view.dart';

class ProfileView extends StatefulWidget {
  final UserModel user;

  const ProfileView({required this.user, super.key});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late UserModel _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  Future<void> _updateUserProfile({
    required String name,
    required String email,
    required int age,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .update({'name': name, 'email': email, 'age': age});

      setState(() {
        _currentUser = UserModel(
          uid: _currentUser.uid,
          name: name,
          email: email,
          role: _currentUser.role,
          age: age,
          password: _currentUser.password,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8fd3fe), Color(0xFF4facfe)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _currentUser.role == 'student'
                            ? 'Student Dashboard'
                            : 'Tutor Dashboard',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4facfe),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _currentUser.role == 'student'
                            ? '🎓  View your courses or browse tutors.'
                            : '🧑‍🏫 Manage your classes here.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_currentUser.role == 'student')
                        const SizedBox(height: 20),
                      if (_currentUser.role == 'student')
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4facfe),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TutorListView(),
                              ),
                            );
                          },
                          child: const Text('Browse Tutors'),
                        ),
                      if (_currentUser.role == 'teacher')
                        const SizedBox(height: 20),
                      if (_currentUser.role == 'teacher')
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4facfe),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => TutorAvailabilityView(
                                      userId: _currentUser.uid,
                                    ),
                              ),
                            );
                          },
                          child: const Text('Manage Availability'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4facfe),
        elevation: 0,
        title: const Text('Profile'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white,
              size: 30,
            ),
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pop(context);
              } else if (value == 'profile') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Profile Information'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDialogProfileItem('Name', _currentUser.name),
                          _buildDialogProfileItem('Email', _currentUser.email),
                          _buildDialogProfileItem('Role', _currentUser.role),
                          _buildDialogProfileItem(
                            'Age',
                            _currentUser.age.toString(),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                final nameController = TextEditingController(
                                  text: _currentUser.name,
                                );
                                final emailController = TextEditingController(
                                  text: _currentUser.email,
                                );
                                final ageController = TextEditingController(
                                  text: _currentUser.age.toString(),
                                );

                                return AlertDialog(
                                  title: const Text('Edit Profile'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: nameController,
                                          decoration: const InputDecoration(
                                            labelText: 'Name',
                                          ),
                                        ),
                                        TextField(
                                          controller: emailController,
                                          decoration: const InputDecoration(
                                            labelText: 'Email',
                                          ),
                                          keyboardType:
                                              TextInputType.emailAddress,
                                        ),
                                        TextField(
                                          controller: ageController,
                                          decoration: const InputDecoration(
                                            labelText: 'Age',
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        final newName =
                                            nameController.text.trim();
                                        final newEmail =
                                            emailController.text.trim();
                                        final newAge =
                                            int.tryParse(
                                              ageController.text.trim(),
                                            ) ??
                                            _currentUser.age;

                                        if (newName.isNotEmpty &&
                                            newEmail.isNotEmpty) {
                                          _updateUserProfile(
                                            name: newName,
                                            email: newEmail,
                                            age: newAge,
                                          );
                                          Navigator.pop(
                                            context,
                                          ); // Close edit dialog
                                          Navigator.pop(
                                            context,
                                          ); // Close profile info dialog
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Name and Email cannot be empty',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Save'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text('Edit Profile'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile Info'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }

  Widget _buildDialogProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
