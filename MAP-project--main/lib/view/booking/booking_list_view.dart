import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/booking_model.dart'; // Adjust path based on your project structure

class BookingListView extends StatefulWidget {
  final String tutorName;

  const BookingListView({required this.tutorName, super.key});

  @override
  State<BookingListView> createState() => _BookingListViewState();
}

class _BookingListViewState extends State<BookingListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookings for ${widget.tutorName}'),
        backgroundColor: const Color(0xFF4facfe),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('bookings')
                .where('tutorName', isEqualTo: widget.tutorName)
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading bookings. Please try again.',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No bookings found for this tutor.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final bookings =
              snapshot.data!.docs
                  .map(
                    (doc) =>
                        Booking.fromJson(doc.data() as Map<String, dynamic>),
                  )
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
                        'Subject: ${booking.subject}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                        'Booked on: ${booking.createdAt.toString()}',
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
