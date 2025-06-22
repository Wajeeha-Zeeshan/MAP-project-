import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
      appBar: AppBar(
        title: Text('Book ${widget.tutorName}'),
        backgroundColor: const Color(0xFF4facfe),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Subject:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedSubject,
              isExpanded: true,
              hint: const Text('Choose subject'),
              items:
                  widget.subjects
                      .map(
                        (subject) => DropdownMenuItem(
                          value: subject,
                          child: Text(subject),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => selectedSubject = value),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Day & Date:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedDayKey,
              isExpanded: true,
              hint: const Text('Choose day'),
              items:
                  next7DayMap.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text('${entry.key} (${entry.value})'),
                        ),
                      )
                      .toList(),
              onChanged:
                  (value) => setState(() {
                    selectedDayKey = value;
                    selectedDate = next7DayMap[value!];
                    selectedSlot = null;
                  }),
            ),
            const SizedBox(height: 20),
            if (selectedDayKey != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Time Slot:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: selectedSlot,
                    isExpanded: true,
                    hint: const Text('Choose time slot'),
                    items:
                        widget.availability[selectedDayKey]!
                            .map(
                              (slot) => DropdownMenuItem(
                                value: slot,
                                child: Text(slot),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => setState(() => selectedSlot = value),
                  ),
                ],
              ),
            if (!(selectedSubject != null &&
                selectedDayKey != null &&
                selectedSlot != null))
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Please select all fields to proceed.',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (selectedSubject != null &&
                            selectedDayKey != null &&
                            selectedSlot != null &&
                            !_isLoading)
                        ? _sendBookingRequest
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4facfe),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Send Request',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
              ),
            ),
          ],
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

      // 🟢 Send notification to tutor
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
          backgroundColor: Colors.red,
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
      builder:
          (context) => AlertDialog(
            title: const Text('Request Sent'),
            content: Text(
              'Your booking request for ${widget.tutorName} has been sent and is pending approval.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}