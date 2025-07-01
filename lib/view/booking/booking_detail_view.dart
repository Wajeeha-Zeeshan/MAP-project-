import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFf0f7ff), Color(0xFFe6f0fa)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Select Subject'),
                _buildDropdown(
                  items: widget.subjects
                      .map(
                        (subject) => DropdownMenuItem(
                          value: subject,
                          child: Text(subject),
                        ),
                      )
                      .toList(),
                  value: selectedSubject,
                  hint: 'Choose subject',
                  onChanged: (value) => setState(() => selectedSubject = value),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Select Day & Date'),
                _buildDropdown(
                  items: next7DayMap.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text('${entry.key} (${entry.value})'),
                        ),
                      )
                      .toList(),
                  value: selectedDayKey,
                  hint: 'Choose day',
                  onChanged: (value) => setState(() {
                    selectedDayKey = value;
                    selectedDate = next7DayMap[value!];
                    selectedSlot = null;
                  }),
                ),
                const SizedBox(height: 24),
                if (selectedDayKey != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Select Time Slot'),
                      _buildDropdown(
                        items: widget.availability[selectedDayKey]!
                            .map(
                              (slot) => DropdownMenuItem(
                                value: slot,
                                child: Text(slot),
                              ),
                            )
                            .toList(),
                        value: selectedSlot,
                        hint: 'Choose time slot',
                        onChanged: (value) => setState(() => selectedSlot = value),
                      ),
                    ],
                  ),
                if (!(selectedSubject != null &&
                    selectedDayKey != null &&
                    selectedSlot != null))
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'Please select all fields to proceed.',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                const Spacer(),
                AnimatedScale(
                  scale: _isLoading ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedOpacity(
                    opacity: _isLoading ? 0.7 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (selectedSubject != null &&
                                selectedDayKey != null &&
                                selectedSlot != null &&
                                !_isLoading)
                            ? _sendBookingRequest
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4facfe),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          elevation: 8,
                          shadowColor: const Color(0xFF4facfe).withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Send Request',
                                style: TextStyle(
                                  fontSize: 16,
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
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.grey[900],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required List<DropdownMenuItem<String>> items,
    required String? value,
    required String hint,
    required ValueChanged<String?>? onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF6FAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        hint: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            hint,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
        items: items,
        onChanged: onChanged,
        dropdownColor: Colors.white,
        elevation: 4,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.grey[900],
        ),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Color(0xFF4facfe),
          size: 30,
        ),
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
    );
  }

  Future<void> _sendBookingRequest() async {
    if (!mounted) return; // Prevent state changes if widget is disposed
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

      if (!mounted) return; // Prevent state changes if widget is disposed
      _showRequestSentDialog();
    } catch (e) {
      if (!mounted) return; // Prevent state changes if widget is disposed
      print('Error sending booking request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return; // Prevent state changes if widget is disposed
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showRequestSentDialog() {
    if (!mounted) return; // Prevent dialog if widget is disposed
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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