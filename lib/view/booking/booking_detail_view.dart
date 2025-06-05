import 'package:flutter/material.dart';

import '../../viewmodels/booking_viewmodel.dart';
import '../../models/booking_model.dart';

class BookingDetailView extends StatefulWidget {
  final String tutorName;
  final List<String> subjects;
  final Map<String, List<String>> availability;

  const BookingDetailView({
    required this.tutorName,
    required this.subjects,
    required this.availability,
    super.key,
  });

  @override
  State<BookingDetailView> createState() => _BookingDetailViewState();
}

class _BookingDetailViewState extends State<BookingDetailView> {
  String? selectedSubject;
  String? selectedDay;
  String? selectedSlot;

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
              onChanged: (value) {
                setState(() {
                  selectedSubject = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Day:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedDay,
              isExpanded: true,
              hint: const Text('Choose day'),
              items:
                  widget.availability.keys
                      .where((day) => widget.availability[day]!.isNotEmpty)
                      .map(
                        (day) => DropdownMenuItem(value: day, child: Text(day)),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedDay = value;
                  selectedSlot = null;
                });
              },
            ),
            const SizedBox(height: 20),
            if (selectedDay != null)
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
                        widget.availability[selectedDay]!
                            .map(
                              (slot) => DropdownMenuItem(
                                value: slot,
                                child: Text(slot),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSlot = value;
                      });
                    },
                  ),
                ],
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (selectedSubject != null &&
                            selectedDay != null &&
                            selectedSlot != null)
                        ? () {
                          _navigateToPayment(context);
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4facfe),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  'Make Payment',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPayment(BuildContext context) {
    // Instantiate the BookingViewModel
    final bookingViewModel = BookingViewModel();

    // Simulating a payment screen or process
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Proceed to Payment'),
            content: const Text('This is where payment flow would happen.'),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    // Create a Booking instance
                    final booking = Booking(
                      tutorName: widget.tutorName,
                      subject: selectedSubject!,
                      day: selectedDay!,
                      timeSlot: selectedSlot!,
                      createdAt: DateTime.now(),
                    );
                    // Save the booking to Firestore
                    await bookingViewModel.saveBooking(booking);
                    // Close payment dialog
                    Navigator.of(context).pop();
                    // Show confirmation
                    _showBookingConfirmation(context);
                  } catch (e) {
                    // Handle any errors during saving
                    Navigator.of(context).pop(); // Close payment dialog
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Error'),
                            content: Text('Failed to save booking: $e'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                    );
                  }
                },
                child: const Text('Pay & Confirm'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _showBookingConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Booking Confirmed'),
            content: Text(
              'You have booked ${widget.tutorName} for $selectedSubject on $selectedDay at $selectedSlot.',
            ),
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
