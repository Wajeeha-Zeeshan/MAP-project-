import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_model.dart';
import '../tutor/tutor_list_view.dart';
import '../tutor/tutor_availability_view.dart';
import '../booking/students_booking_view.dart';
import '../tutor/qualifications_view.dart';
import '../../viewmodels/tutor_viewmodel.dart';

class ProfileView extends StatefulWidget {
  final UserModel user;

  const ProfileView({super.key, required this.user});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late UserModel _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSummary(),
              const SizedBox(height: 20),
              Text(
                _currentUser.role == 'student' ? 'Courses for You' : 'Manage Your Activities',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                  children: _currentUser.role == 'student'
                      ? [
                          _dashboardTile(
                            icon: Icons.search,
                            label: 'Browse Tutors',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TutorListView()),
                            ),
                          ),
                          _dashboardTile(
                            icon: Icons.book,
                            label: 'View Bookings',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const StudentBookingListView()),
                            ),
                          ),
                          _courseCard('Frontend Design', '40RM'),
                          _courseCard('Flutter Basics', '60RM'),
                        ]
                      : [
                          _dashboardTile(
                            icon: Icons.calendar_today,
                            label: 'Availability',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TutorAvailabilityView(userId: _currentUser.uid),
                              ),
                            ),
                          ),
                          _dashboardTile(
                            icon: Icons.school,
                            label: 'Qualifications',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider(
                                  create: (_) => TutorViewModel(),
                                  child: QualificationsView(uid: _currentUser.uid),
                                ),
                              ),
                            ),
                          ),
                        ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFe3f2fd),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFF4facfe),
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(_currentUser.email),
                Text('Role: ${_currentUser.role}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboardTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF4facfe),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _courseCard(String title, String price) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFe3f2fd),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Price: $price', style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4facfe),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Enroll'),
            ),
          )
        ],
      ),
    );
  }
}
