import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../booking/booking_detail_view.dart';
import '../review/review_form_view.dart';

class TutorDetailView extends StatelessWidget {
  const TutorDetailView({super.key, required this.tutor});

  final Map<String, dynamic> tutor;

  @override
  Widget build(BuildContext context) {
    // ───── Parse subjects ─────
    final subjects = List<String>.from(tutor['subjects'] ?? []);

    // ───── Parse availability safely ─────
    final availability = Map<String, dynamic>.from(
      tutor['availability'] ?? {},
    ).map((d, list) => MapEntry(d, List<String>.from(list as List<dynamic>)));

    // ───── Parse fees → Map<String,double> ─────
    final fees = Map<String, dynamic>.from(
      tutor['fees'] ?? {},
    ).map((k, v) => MapEntry(k, (v as num).toDouble()));

    final tutorId = tutor['uid'] as String? ?? '';

    final auth = context.read<AuthViewModel>();
    final currStudentId = auth.user?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4facfe),
        elevation: 0,
        title: Text(tutor['name'] ?? 'Tutor Details'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _profileCard(subjects, fees),
                const SizedBox(height: 20),
                _availabilitySection(availability),
                const SizedBox(height: 24),
                _actionButtons(
                  context,
                  tutorId: tutorId,
                  studentId: currStudentId,
                  subjects: subjects,
                  availability: availability,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────── Widgets ─────────────────

  Widget _profileCard(List<String> subjects, Map<String, double> fees) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tutor Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4facfe),
              ),
            ),
            const SizedBox(height: 12),
            _row('Name', tutor['name'] ?? 'N/A'),
            _row('Email', tutor['email'] ?? 'N/A'),
            _row('Qualification', tutor['qualification'] ?? 'N/A'),
            _subjectsWithFees(subjects, fees),
          ],
        ),
      ),
    );
  }

  Widget _availabilitySection(Map<String, List<String>> availability) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Availability',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        ...availability.entries.map((e) {
          final day = e.key;
          final slots = e.value;
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.grey[100],
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (slots.isEmpty)
                    const Text(
                      'No time slots available.',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ...slots.map(
                      (s) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '• $s',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _actionButtons(
    BuildContext context, {
    required String tutorId,
    required String? studentId,
    required List<String> subjects,
    required Map<String, List<String>> availability,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            if (studentId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please log in to book a tutor.'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => BookingDetailView(
                      tutorName: tutor['name'] ?? 'N/A',
                      tutorId: tutorId,
                      studentId: studentId,
                      subjects: subjects,
                      availability: availability,
                    ),
              ),
            );
          },
          style: _btnStyle(),
          child: const Text(
            'Book Tutor',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {
            if (studentId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please log in to review a tutor.'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ReviewFormView(
                      tutorId: tutorId,
                      studentId: studentId,
                      tutorName: tutor['name'] ?? 'N/A',
                    ),
              ),
            );
          },
          style: _btnStyle(),
          child: const Text(
            'Review Tutor',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // ───────────────── helpers ─────────────────

  ButtonStyle _btnStyle() => ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF4facfe),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
  );

  Widget _subjectsWithFees(List<String> subjects, Map<String, double> fees) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Subjects:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        if (subjects.isEmpty)
          const Text('None', style: TextStyle(fontSize: 14))
        else
          ...subjects.map((subj) {
            final fee = fees[subj] ?? 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '• $subj (RM${fee.toStringAsFixed(2)}/hr)',
                style: const TextStyle(fontSize: 14),
              ),
            );
          }),
      ],
    );
  }
}
