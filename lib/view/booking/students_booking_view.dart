import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/booking_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/booking_viewmodel.dart';

class StudentBookingListView extends StatefulWidget {
  const StudentBookingListView({super.key});

  @override
  State<StudentBookingListView> createState() => _StudentBookingListViewState();
}

class _StudentBookingListViewState extends State<StudentBookingListView> {
  String? _studentId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_studentId == null) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      _studentId = authViewModel.user?.uid;
    }
  }

  void launchPaymentURL(String url) async {
    final Uri paymentUri = Uri.parse(url);

    if (!await launchUrl(paymentUri, mode: LaunchMode.inAppWebView)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open payment page.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void launchWhatsAppGroup() async {
    final Uri whatsappUri = Uri.parse(
      'https://chat.whatsapp.com/YourGroupInviteLink',
    );

    if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open WhatsApp.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_studentId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          backgroundColor: const Color(0xFF4facfe),
        ),
        body: const Center(
          child: Text(
            'User not logged in or student ID not found.',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings (Student)'),
        backgroundColor: const Color(0xFF4facfe),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('bookings')
                .where('studentId', isEqualTo: _studentId)
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading bookings: ${snapshot.error}',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'You have no bookings yet.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final bookings =
              snapshot.data!.docs.map((doc) {
                return Booking.fromJson(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                );
              }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final docId = booking.id!;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tutor: ${booking.tutorName}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Subject: ${booking.subject}'),
                      Text('Day: ${booking.day}'),
                      Text('Date: ${booking.date}'),
                      Text('Time: ${booking.timeSlot}'),
                      const SizedBox(height: 8),
                      Text(
                        'Status: ${booking.status}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:
                              booking.status == 'confirmed'
                                  ? Colors.green
                                  : booking.status == 'pending'
                                  ? Colors.orange
                                  : Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Booked on: ${booking.createdAt.toLocal().toString().split('.')[0]}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (booking.status == 'confirmed' &&
                          booking.isPaid != true)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                launchPaymentURL(
                                  'https://buy.stripe.com/test_aFa5kwgyb1Kea35d7s4Ni00',
                                );
                              },
                              icon: const Icon(Icons.payment),
                              label: const Text('Pay with Stripe'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final viewModel = BookingViewModel();
                                await viewModel.markBookingAsPaid(docId);

                                await FirebaseFirestore.instance
                                    .collection('notifications')
                                    .add({
                                      'senderId': booking.studentId,
                                      'receiverId': booking.tutorId,
                                      'message':
                                          'Payment for your session with student ${booking.studentId} for ${booking.subject} has been completed.',
                                      'type': 'payment_status',
                                      'timestamp': Timestamp.now(),
                                      'isRead': false,
                                    });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Marked as paid!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                setState(() {});

                                // Show WhatsApp popup
                                _showWhatsAppPopup();
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Mark as Paid'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      if (booking.status == 'confirmed' &&
                          booking.isPaid == true)
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Chip(
                            label: Text('Paid'),
                            backgroundColor: Colors.green,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed:
                                () => _showEditDialog(context, docId, booking),
                            child: const Text('Edit'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _showCancelDialog(context, docId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showWhatsAppPopup() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Join WhatsApp Group'),
            content: const Text(
              'Thank you for your payment! You can now join our WhatsApp group for updates.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  launchWhatsAppGroup();
                },
                icon: const Icon(Icons.chat),
                label: const Text('Join WhatsApp'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
    );
  }

  void _showEditDialog(BuildContext context, String docId, Booking booking) {
    final _formKey = GlobalKey<FormState>();
    String subject = booking.subject;
    String day = booking.day;
    String date = booking.date;
    String timeSlot = booking.timeSlot;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Booking'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: subject,
                    decoration: const InputDecoration(labelText: 'Subject'),
                    onSaved: (value) => subject = value!,
                  ),
                  TextFormField(
                    initialValue: day,
                    decoration: const InputDecoration(labelText: 'Day'),
                    onSaved: (value) => day = value!,
                  ),
                  TextFormField(
                    initialValue: date,
                    decoration: const InputDecoration(labelText: 'Date'),
                    onSaved: (value) => date = value!,
                  ),
                  TextFormField(
                    initialValue: timeSlot,
                    decoration: const InputDecoration(labelText: 'Time Slot'),
                    onSaved: (value) => timeSlot = value!,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  _formKey.currentState!.save();
                  final updatedBooking = Booking(
                    id: booking.id,
                    tutorName: booking.tutorName,
                    tutorId: booking.tutorId,
                    studentId: booking.studentId,
                    subject: subject,
                    day: day,
                    date: date,
                    timeSlot: timeSlot,
                    createdAt: booking.createdAt,
                    status: booking.status,
                    isPaid: booking.isPaid,
                  );
                  final viewModel = BookingViewModel();
                  await viewModel.updateBooking(docId, updatedBooking);
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showCancelDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Booking'),
            content: const Text(
              'Are you sure you want to cancel this booking?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  final viewModel = BookingViewModel();
                  await viewModel.deleteBooking(docId);
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text('Yes', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}