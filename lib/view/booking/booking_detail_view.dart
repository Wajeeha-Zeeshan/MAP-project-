import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../viewmodels/booking_viewmodel.dart';
import '../../viewmodels/notification_viewmodel.dart';
import '../../models/booking_model.dart';

class BookingDetailView extends StatefulWidget {
  final String tutorName;
  final String tutorId;
  final String studentId;
  final List<String> subjects;
  final Map<String, List<String>> availability;

  const BookingDetailView({
    required this.tutorName,
    required this.tutorId,
    required this.studentId,
    required this.subjects,
    required this.availability,
    super.key,
  });

  @override
  State<BookingDetailView> createState() => _BookingDetailViewState();
}

class _BookingDetailViewState extends State<BookingDetailView> {
  String? selectedSubject;
  String? selectedDayKey;
  String? selectedSlot;
  String? selectedDate;
  bool _isLoading = false;

  late final Map<String, String> next7DayMap;

  @override
  void initState() {
    super.initState();
    next7DayMap = _generateNext7Days();
  }

  Map<String, String> _generateNext7Days() {
    final now = DateTime.now();
    final dayMap = <String, String>{};
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      final dayName = DateFormat('EEEE').format(date);
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      if (widget.availability.containsKey(dayName) &&
          widget.availability[dayName]!.isNotEmpty) {
        dayMap[dayName] = formattedDate;
      }
    }
    return dayMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: Text(
          'Book ${widget.tutorName}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Animation
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    'Schedule a Session',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                      shadows: [
                        Shadow(
                          color: Colors.blue.shade200,
                          blurRadius: 3,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Select the subject, day, and time for your tutoring session.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 24),

                // Subject Selection with Glass Effect
                _buildGlassCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Subject:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: selectedSubject,
                          isExpanded: true,
                          hint: Text(
                            'Choose subject',
                            style: TextStyle(
                              color: Colors.blue.shade400,
                            ),
                          ),
                          items: widget.subjects
                              .map(
                                (subject) => DropdownMenuItem(
                                  value: subject,
                                  child: Text(
                                    subject,
                                    style: TextStyle(
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => selectedSubject = value),
                          underline: const SizedBox(),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Day & Date Selection with Glass Effect
                _buildGlassCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Day & Date:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: selectedDayKey,
                          isExpanded: true,
                          hint: Text(
                            'Choose day',
                            style: TextStyle(
                              color: Colors.blue.shade400,
                            ),
                          ),
                          items: next7DayMap.entries
                              .map(
                                (entry) => DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(
                                    '${entry.key} (${entry.value})',
                                    style: TextStyle(
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() {
                            selectedDayKey = value;
                            selectedDate = next7DayMap[value!];
                            selectedSlot = null;
                          }),
                          underline: const SizedBox(),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Time Slot Selection with Glass Effect (Conditional)
                if (selectedDayKey != null)
                  _buildGlassCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Time Slot:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<String>(
                            value: selectedSlot,
                            isExpanded: true,
                            hint: Text(
                              'Choose time slot',
                              style: TextStyle(
                                color: Colors.blue.shade400,
                              ),
                            ),
                            items: widget.availability[selectedDayKey]!
                                .map(
                                  (slot) => DropdownMenuItem(
                                    value: slot,
                                    child: Text(
                                      slot,
                                      style: TextStyle(
                                        color: Colors.blue.shade800,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => setState(() => selectedSlot = value),
                            underline: const SizedBox(),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Validation Message
                if (!(selectedSubject != null &&
                    selectedDayKey != null &&
                    selectedSlot != null))
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Please select all fields to proceed.',
                      style: TextStyle(
                        color: Colors.redAccent.shade200,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Send Request Button with Modern Styling
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (selectedSubject != null &&
                            selectedDayKey != null &&
                            selectedSlot != null &&
                            !_isLoading)
                        ? _sendBookingRequest
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 16,
                      ),
                      elevation: 5,
                      shadowColor: Colors.blue.shade200,
                      disabledBackgroundColor: Colors.grey.shade400,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Send Request',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendBookingRequest() async {
    setState(() {
      _isLoading = true;
    });

    final bookingViewModel = BookingViewModel();
    final notificationViewModel = NotificationViewModel();

    try {
      final booking = Booking(
        tutorName: widget.tutorName,
        tutorId: widget.tutorId,
        studentId: widget.studentId,
        subject: selectedSubject!,
        day: selectedDayKey!,
        date: selectedDate!,
        timeSlot: selectedSlot!,
        createdAt: DateTime.now(),
        status: 'pending',
      );

      await bookingViewModel.saveBooking(booking);

      // Send notification to tutor
      await notificationViewModel.sendNotification(
        senderId: widget.studentId,
        receiverId: widget.tutorId,
        message:
            'You have received a new booking request for $selectedSubject on $selectedDate at $selectedSlot.',
        type: 'booking_request',
      );

      _showRequestSentDialog();
    } catch (e) {
      print('Error sending booking request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending request: $e'),
          backgroundColor: Colors.redAccent.shade200,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showRequestSentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white.withOpacity(0.95),
        title: const Text(
          'Request Sent',
          style: TextStyle(
            color: Color(0xFF1976D2),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Your booking request for ${widget.tutorName} has been sent and is pending approval.',
          style: TextStyle(
            color: Colors.grey.shade800,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF1976D2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Glass Effect Card Widget
  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade100.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
