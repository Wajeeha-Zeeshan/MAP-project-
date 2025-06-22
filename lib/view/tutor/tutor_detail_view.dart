import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../booking/booking_detail_view.dart';
import '../review/review_form_view.dart';

class TutorDetailView extends StatelessWidget {
  final Map<String, dynamic> tutor;

  const TutorDetailView({required this.tutor, super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> subjects = List<String>.from(
      tutor['subjects'] as List<dynamic>? ?? [],
    );

    final Map<String, List<Map<String, String>>> dayBasedAvailability =
        (tutor['availability'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(
            key,
            List<Map<String, String>>.from(
              value.map<Map<String, String>>(
                (item) => Map<String, String>.from(item ?? {}),
              ),
            ),
          ),
        ) ??
        {
          'Monday': [],
          'Tuesday': [],
          'Wednesday': [],
          'Thursday': [],
          'Friday': [],
          'Saturday': [],
          'Sunday': [],
        };

    final Map<String, double> fees =
        (tutor['fees'] as Map?)?.map(
          (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
        ) ??
        {};

    final String tutorId = tutor['uid'] as String? ?? '';
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final String? currentStudentId = authViewModel.user?.uid;

    final Map<String, List<Map<String, String>>> dateBasedAvailability =
        _convertToDateBasedAvailability(dayBasedAvailability);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4facfe),
        elevation: 0,
        title: Text(tutor['name'] as String? ?? 'Tutor Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
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
                          _buildDetailRow(
                            'Name',
                            tutor['name'] as String? ?? 'N/A',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            'Email',
                            tutor['email'] as String? ?? 'N/A',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            'Qualification',
                            tutor['qualification'] as String? ?? 'N/A',
                          ),
                          const SizedBox(height: 8),
                          _buildSubjectsWithFees(subjects, fees),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Availability',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...dateBasedAvailability.keys.map((date) {
                    final timeSlots = dateBasedAvailability[date]!;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.grey[100],
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat(
                                'yyyy-MM-dd (EEEE)',
                              ).format(DateTime.parse(date)),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            timeSlots.isEmpty
                                ? const Text(
                                  'No time slots available.',
                                  style: TextStyle(color: Colors.grey),
                                )
                                : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      timeSlots.map((slotMap) {
                                        final time = slotMap['time'] ?? '';
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                          child: Text(
                                            '• $time',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (currentStudentId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please log in to book a tutor.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => BookingDetailView(
                                      tutorName:
                                          tutor['name'] as String? ?? 'N/A',
                                      tutorId: tutorId,
                                      studentId: currentStudentId,
                                      subjects: subjects,
                                      availability: dayBasedAvailability.map(
                                        (day, slots) => MapEntry(
                                          day,
                                          slots
                                              .map(
                                                (slotMap) =>
                                                    slotMap['time'] ?? '',
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4facfe),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Book Tutor',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (currentStudentId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please log in to review a tutor.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ReviewFormView(
                                      tutorId: tutorId,
                                      studentId: currentStudentId,
                                      tutorName:
                                          tutor['name'] as String? ?? 'N/A',
                                    ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4facfe),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Review Tutor',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, List<Map<String, String>>> _convertToDateBasedAvailability(
    Map<String, List<Map<String, String>>> dayBasedAvailability,
  ) {
    final Map<String, List<Map<String, String>>> dateBasedAvailability = {};
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    const daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    for (var i = 0; i < daysOfWeek.length; i++) {
      final day = daysOfWeek[i];
      final date = startOfWeek.add(Duration(days: i));
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      dateBasedAvailability[formattedDate] = List<Map<String, String>>.from(
        dayBasedAvailability[day] ?? [],
      );
    }

    return dateBasedAvailability;
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectsWithFees(
    List<String> subjects,
    Map<String, double> fees,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subjects: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        subjects.isEmpty
            ? const Text(
              'None',
              style: TextStyle(fontSize: 14, color: Colors.black),
            )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  subjects.map((subject) {
                    final fee = fees[subject] ?? 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '• $subject (RM${fee.toStringAsFixed(2)}/hr)',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
            ),
      ],
    );
  }
}