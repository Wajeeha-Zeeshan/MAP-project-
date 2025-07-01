import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFe3f2fd),
              Color(0xFFcce7ff),
            ], // Softer blue gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0), // Reduced from 20.0
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    title: Text(
                      tutor['name'] as String? ?? 'Tutor Details',
                      style: GoogleFonts.poppins(
                        fontSize: 18, // Slightly reduced
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 7, 0, 0),
                      ),
                    ),
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF4facfe),
                            Color(0xFF00d4ff),
                          ], // Vibrant gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12), // Reduced from 20
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white.withOpacity(0.9), // Slight transparency
                    child: Padding(
                      padding: const EdgeInsets.all(12.0), // Reduced from 20.0
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tutor Details',
                            style: GoogleFonts.poppins(
                              fontSize: 20, // Slightly increased for visibility
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2196f3), // Brighter blue
                            ),
                          ),
                          const SizedBox(height: 10), // Reduced from 16
                          _buildDetailRow(
                            'Name',
                            tutor['name'] as String? ?? 'N/A',
                          ),
                          const SizedBox(height: 8), // Reduced from 12
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
                  const SizedBox(height: 16), // Reduced from 24
                  Text(
                    'Availability',
                    style: GoogleFonts.poppins(
                      fontSize: 18, // Slightly reduced
                      fontWeight: FontWeight.w600,
                      color: Colors.black87, // High contrast
                    ),
                  ),
                  const SizedBox(height: 8), // Reduced from 12
                  ...dateBasedAvailability.keys.map((date) {
                    final timeSlots = dateBasedAvailability[date]!;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: const Color(0xFFf0f4f8), // Lighter background
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                      ), // Reduced from 8
                      child: Padding(
                        padding: const EdgeInsets.all(
                          12.0,
                        ), // Reduced from 16.0
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat(
                                'yyyy-MM-dd (EEEE)',
                              ).format(DateTime.parse(date)),
                              style: GoogleFonts.poppins(
                                fontSize: 14, // Reduced for compactness
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6), // Reduced from 10
                            timeSlots.isEmpty
                                ? Text(
                                  'No time slots available.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12, // Reduced
                                    color: Colors.grey,
                                  ),
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
                                            style: GoogleFonts.poppins(
                                              fontSize: 12, // Reduced
                                              color: Colors.black87,
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
                  const SizedBox(height: 16), // Reduced from 24
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: ElevatedButton(
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
                              backgroundColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              shadowColor: const Color(
                                0xFF42a5f5,
                              ).withOpacity(0.4),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF42a5f5),
                                    Color(0xFF00bcd4),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Center(
                                child: Text(
                                  'Book Tutor',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedScale(
                          scale: 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: ElevatedButton(
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
                              backgroundColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              shadowColor: const Color(
                                0xFF42a5f5,
                              ).withOpacity(0.4),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF42a5f5),
                                    Color(0xFF00bcd4),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Center(
                                child: Text(
                                  'Review Tutor',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20), // Reduced from 30
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
          style: GoogleFonts.poppins(
            fontSize: 13, // Slightly reduced
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
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
        Text(
          'Subjects: ',
          style: GoogleFonts.poppins(
            fontSize: 13, // Slightly reduced
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        subjects.isEmpty
            ? Text(
              'None',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
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
                        style: GoogleFonts.poppins(
                          fontSize: 13, // Reduced
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
