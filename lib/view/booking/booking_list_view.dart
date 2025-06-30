import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/booking_model.dart';

class TutorBookingListView extends StatefulWidget {
  final String tutorId;

  const TutorBookingListView({required this.tutorId, super.key});

  @override
  State<TutorBookingListView> createState() => _TutorBookingListViewState();
}

class _TutorBookingListViewState extends State<TutorBookingListView> {
  final bookingsRef = FirebaseFirestore.instance.collection('bookings');
  final notificationsRef = FirebaseFirestore.instance.collection(
    'notifications',
  );
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings (Tutor)'),
        backgroundColor: const Color(0xFF4facfe),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            bookingsRef
                .where('tutorId', isEqualTo: widget.tutorId)
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

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              try {
                final booking = Booking.fromJson(data);
                final status = data['status'] ?? 'pending';

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student ID: ${booking.studentId}',
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
                          'Status: $status',
                          style: TextStyle(
                            color:
                                status == 'confirmed'
                                    ? Colors.green
                                    : Colors.orange,
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
                        if (status == 'pending') ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                ),
                                label: const Text('Accept'),
                                onPressed:
                                    () => _updateBookingStatus(
                                      doc.id,
                                      'confirmed',
                                      booking,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                label: const Text('Reject'),
                                onPressed: () => _deleteBooking(doc.id),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              } catch (e) {
                print('Error parsing booking: $e');
                return const SizedBox();
              }
            },
          );
        },
      ),
    );
  }

  Future<void> _updateBookingStatus(
    String docId,
    String status,
    Booking booking,
  ) async {
    try {
      await bookingsRef.doc(docId).update({'status': status});

      //  Send notification to student
      await notificationsRef.add({
        'senderId': booking.tutorId,
        'receiverId': booking.studentId,
        'message':
            'Your booking request for ${booking.subject} on ${booking.date} at ${booking.timeSlot} has been approved.',
        'type': 'booking_status',
        'timestamp': Timestamp.now(),
        'isRead': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking marked as $status'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error updating booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteBooking(String docId) async {
    try {
      await bookingsRef.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking rejected and removed'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('Error deleting booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}