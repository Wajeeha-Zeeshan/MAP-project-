import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../tutor/tutor_list_view.dart';
import '../booking/students_booking_view.dart';
import '../tutor/subjects_tutors_view.dart';

class StudentView extends StatelessWidget {
  final UserModel user;

  const StudentView({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Courses for You',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 3,
            width: 50,
            color: const Color(0xFF1976D2),
          ),
          const SizedBox(height: 15),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1,
            children: [
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
                  MaterialPageRoute(
                      builder: (_) => const StudentBookingListView()),
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
                color: Color(0xFF1976D2),
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
    );
  }

  Widget _subjectChip(BuildContext context, String subject) {
    return ActionChip(
      label: Text(subject),
      backgroundColor: const Color(0xFFBBDEFB),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      labelStyle: const TextStyle(
          color: Color(0xFF1976D2), fontWeight: FontWeight.w500),
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

  Widget _dashboardTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
