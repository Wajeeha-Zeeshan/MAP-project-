import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
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
      print('Student ID set to: $_studentId');
      if (_studentId == null) {
        print('Warning: AuthViewModel user is null or no UID found');
      }
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
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('studentId', isEqualTo: _studentId)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .handleError((error, stackTrace) {
              print('Stream error: $error, Stack trace: $stackTrace');
              return null; // Prevents stream from breaking
            })
            .map((snapshot) {
              print('Student bookings fetched: ${snapshot?.docs.length ?? 0}');
              return snapshot;
            }),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Snapshot error: ${snapshot.error}');
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
              snapshot.data!.docs
                  .map((doc) {
                    try {
                      return Booking.fromJson(
                        doc.data() as Map<String, dynamic>,
                      );
                    } catch (e) {
                      print('Error parsing booking doc ${doc.id}: $e');
                      return null; // Skip invalid documents
                    }
                  })
                  .whereType<Booking>()
                  .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final docId = snapshot.data!.docs[index].id; // Get document ID
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
                      Text(
                        'Subject: ${booking.subject}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Day: ${booking.day}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Time: ${booking.timeSlot}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Booked on: ${booking.createdAt.toLocal().toString().split('.')[0]}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                            onPressed:
                                () =>
                                    _showCancelDialog(context, docId, booking),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.red, // Red for cancel action
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

  void _showEditDialog(BuildContext context, String docId, Booking booking) {
    final _formKey = GlobalKey<FormState>();
    String tutorName = booking.tutorName;
    String subject = booking.subject;
    String day = booking.day;
    String timeSlot = booking.timeSlot;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Booking'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: tutorName,
                    decoration: const InputDecoration(labelText: 'Tutor Name'),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Please enter tutor name' : null,
                    onSaved: (value) => tutorName = value!,
                  ),
                  TextFormField(
                    initialValue: subject,
                    decoration: const InputDecoration(labelText: 'Subject'),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Please enter subject' : null,
                    onSaved: (value) => subject = value!,
                  ),
                  TextFormField(
                    initialValue: day,
                    decoration: const InputDecoration(labelText: 'Day'),
                    validator:
                        (value) => value!.isEmpty ? 'Please enter day' : null,
                    onSaved: (value) => day = value!,
                  ),
                  TextFormField(
                    initialValue: timeSlot,
                    decoration: const InputDecoration(labelText: 'Time Slot'),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Please enter time slot' : null,
                    onSaved: (value) => timeSlot = value!,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final updatedBooking = Booking(
                    id: booking.id,
                    tutorName: tutorName,
                    tutorId: booking.tutorId,
                    studentId: booking.studentId,
                    subject: subject,
                    day: day,
                    timeSlot: timeSlot,
                    createdAt: booking.createdAt,
                  );
                  final viewModel = BookingViewModel();
                  try {
                    await viewModel.updateBooking(docId, updatedBooking);
                    Navigator.pop(context);
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data updated successfully'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                    setState(() {}); // Refresh the UI
                  } catch (e) {
                    // Handle any errors during update
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating booking: $e'),
                        duration: const Duration(seconds: 3),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, String docId, Booking booking) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: const Text(
            'Are you sure you want to cancel this booking? This action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                final viewModel = BookingViewModel();
                try {
                  await viewModel.deleteBooking(docId);
                  Navigator.pop(context);
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking cancelled successfully'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                  setState(() {}); // Refresh the UI
                } catch (e) {
                  // Handle any errors during deletion
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error cancelling booking: $e'),
                      duration: const Duration(seconds: 3),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
