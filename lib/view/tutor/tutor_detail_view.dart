import 'package:flutter/material.dart';
import '../booking/booking_detail_view.dart'; // Import the booking detail page

class TutorDetailView extends StatelessWidget {
  final Map<String, dynamic> tutor;

  const TutorDetailView({required this.tutor, super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = tutor['subjects'] as List<String>;
    final availability = tutor['availability'] as Map<String, List<String>>;
    final fees = tutor['fees'] as Map<String, double>;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4facfe),
        elevation: 0,
        title: Text(tutor['name'] as String),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8fd3fe), Color(0xFF4facfe)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
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
                          Text(
                            'Tutor Details',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4facfe),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Name', tutor['name'] as String),
                          const SizedBox(height: 8),
                          _buildDetailRow('Email', tutor['email'] as String),
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...availability.keys.map((day) {
                    final timeSlots = availability[day]!;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
                                      timeSlots.map((slot) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                          child: Text(
                                            '• $slot',
                                            style: const TextStyle(
                                              fontSize: 14,
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
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => BookingDetailView(
                                  tutorName: tutor['name'] as String,
                                  subjects: subjects,
                                  availability: availability,
                                ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4facfe),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
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
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        subjects.isEmpty
            ? const Text(
              'None',
              style: TextStyle(fontSize: 14, color: Colors.black87),
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
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
            ),
      ],
    );
  }
}
