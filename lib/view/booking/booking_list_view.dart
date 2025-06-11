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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings (Tutor)'),
        backgroundColor: const Color(0xFF4facfe),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('tutorId', isEqualTo: widget.tutorId)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .handleError((error, stackTrace) {
              print('Stream error: $error, Stack trace: $stackTrace');
              return null; // Prevents stream from breaking
            })
            .map((snapshot) {
              print('Tutor bookings fetched: ${snapshot?.docs.length ?? 0}');
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
}
