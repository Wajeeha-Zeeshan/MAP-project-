import 'package:flutter/material.dart';
import 'admin_users_view.dart';
import 'admin_bookings_view.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF4facfe),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionCard(
            context,
            icon: Icons.group,
            title: 'Manage Users',
            subtitle: 'View all students and tutors',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminUsersView()),
                ),
          ),
          const SizedBox(height: 20),
          _buildSectionCard(
            context,
            icon: Icons.book_online,
            title: 'View Bookings',
            subtitle: 'See all tutoring sessions',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminBookingsView()),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF4facfe),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
