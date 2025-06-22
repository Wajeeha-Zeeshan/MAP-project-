import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking_model.dart';

class BookingViewModel {
  final CollectionReference bookingsCollection = FirebaseFirestore.instance
      .collection('bookings');

  // Save a new booking
  Future<void> saveBooking(Booking booking) async {
    try {
      await bookingsCollection.add(booking.toJson());
      print('Booking saved successfully');
    } catch (e) {
      print('Error saving booking: $e');
      rethrow;
    }
  }

  // Get all bookings
  Future<List<Booking>> getAllBookings() async {
    try {
      QuerySnapshot snapshot = await bookingsCollection.get();
      return snapshot.docs
          .map(
            (doc) =>
                Booking.fromJson(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      print('Error fetching all bookings: $e');
      rethrow;
    }
  }

  // Get bookings for a student
  Future<List<Booking>> getStudentBookings(String studentId) async {
    try {
      QuerySnapshot snapshot =
          await bookingsCollection
              .where('studentId', isEqualTo: studentId)
              .orderBy('createdAt', descending: true)
              .get();
      return snapshot.docs
          .map(
            (doc) =>
                Booking.fromJson(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      print('Error fetching student bookings: $e');
      rethrow;
    }
  }

  // Get bookings for a tutor
  Future<List<Booking>> getTutorBookings(String tutorId) async {
    try {
      QuerySnapshot snapshot =
          await bookingsCollection
              .where('tutorId', isEqualTo: tutorId)
              .orderBy('createdAt', descending: true)
              .get();
      return snapshot.docs
          .map(
            (doc) =>
                Booking.fromJson(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      print('Error fetching tutor bookings: $e');
      rethrow;
    }
  }

  // Update booking
  Future<void> updateBooking(String docId, Booking booking) async {
    try {
      await bookingsCollection.doc(docId).update(booking.toJson());
    } catch (e) {
      print('Error updating booking: $e');
      rethrow;
    }
  }

  // Update booking status only
  Future<void> updateBookingStatus(String docId, String newStatus) async {
    try {
      await bookingsCollection.doc(docId).update({'status': newStatus});
    } catch (e) {
      print('Error updating status: $e');
      rethrow;
    }
  }

  // Mark as paid
  Future<void> markBookingAsPaid(String docId) async {
    try {
      await bookingsCollection.doc(docId).update({
        'isPaid': true,
        'status': 'paid',
      });
    } catch (e) {
      print('Error marking as paid: $e');
      rethrow;
    }
  }

  // Delete booking
  Future<void> deleteBooking(String docId) async {
    try {
      await bookingsCollection.doc(docId).delete();
    } catch (e) {
      print('Error deleting booking: $e');
      rethrow;
    }
  }
}
