import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_model.dart';
import '../tutor/tutor_list_view.dart';
import '../tutor/tutor_availability_view.dart';
import '../booking/students_booking_view.dart';
import '../tutor/qualifications_view.dart';
import '../../view/booking/notification_view.dart';
import '../../viewmodels/tutor_viewmodel.dart';
import '../tutor/subjects_tutors_view.dart';
import '../review/review_list_view.dart';

class ProfileView extends StatefulWidget {
  final UserModel user;

  const ProfileView({super.key, required this.user});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late UserModel _currentUser;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _fetchUnreadNotificationCount();
  }

  Future<void> _fetchUnreadNotificationCount() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('notifications')
            .where('receiverId', isEqualTo: _currentUser.uid)
            .where('isRead', isEqualTo: false)
            .get();

    setState(() {
      _unreadNotifications = snapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.black),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => NotificationView(userId: _currentUser.uid),
                    ),
                  );
                  _fetchUnreadNotificationCount(); // Refresh count after return
                },
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 11,
                  top: 11,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadNotifications',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
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
                _currentUser.role == 'student'
                    ? 'Courses for You'
                    : 'Manage Your Activities',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child:
                    _currentUser.role == 'student'
                        ? SingleChildScrollView(
                          child: Column(
                            children: [
                              GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: 1,
                                children: [
                                  _dashboardTile(
                                    icon: Icons.search,
                                    label: 'Browse Tutors',
                                    onTap:
                                        () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => const TutorListView(),
                                          ),
                                        ),
                                  ),
                                  _dashboardTile(
                                    icon: Icons.book,
                                    label: 'View Bookings',
                                    onTap:
                                        () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    const StudentBookingListView(),
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Subjects',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _subjectChip(context, 'Maths'),
                                  _subjectChip(context, 'English'),
                                  _subjectChip(context, 'Science'),
                                  _subjectChip(context, 'Computer'),
                                  _subjectChip(context, 'History'),
                                ],
                              ),
                            ],
                          ),
                        )
                        : GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1,
                          children: [
                            _dashboardTile(
                              icon: Icons.calendar_today,
                              label: 'Availability',
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => TutorAvailabilityView(
                                            userId: _currentUser.uid,
                                          ),
                                    ),
                                  ),
                            ),
                            _dashboardTile(
                              icon: Icons.school,
                              label: 'Qualifications',
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => ChangeNotifierProvider(
                                            create: (_) => TutorViewModel(),
                                            child: QualificationsView(
                                              uid: _currentUser.uid,
                                            ),
                                          ),
                                    ),
                                  ),
                            ),
                            _dashboardTile(
                              icon: Icons.reviews,
                              label: 'View Reviews',
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => ReviewListView(
                                            tutorId: _currentUser.uid,
                                            tutorName: _currentUser.name,
                                          ),
                                    ),
                                  ),
                            ),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _subjectChip(BuildContext context, String subject) {
    return ActionChip(
      label: Text(subject),
      backgroundColor: Colors.lightBlue[100],
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubjectTutorsView(subject: subject),
          ),
        );
      },
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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

  Widget _dashboardTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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
}