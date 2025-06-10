import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingViewModel {
  final CollectionReference bookingsCollection = FirebaseFirestore.instance
      .collection('bookings');

  // Save booking with debug output
  Future<void> saveBooking(Booking booking) async {
    try {
      await bookingsCollection.add(booking.toJson());
      print('Booking saved successfully: ${booking.toJson()}');
    } catch (e) {
      print('Error saving booking: $e');
      rethrow;
    }
  }

  // Fetch all bookings (e.g., for admin or tutor view)
  Future<List<Booking>> getAllBookings() async {
    try {
      QuerySnapshot snapshot = await bookingsCollection.get();
      return snapshot.docs.map((doc) {
        return Booking.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error fetching all bookings: $e');
      rethrow;
    }
  }

  // Fetch bookings for a specific student
  Future<List<Booking>> getStudentBookings(String studentId) async {
    try {
      QuerySnapshot snapshot =
          await bookingsCollection
              .where('studentId', isEqualTo: studentId)
              .orderBy('createdAt', descending: true)
              .get();
      return snapshot.docs.map((doc) {
        return Booking.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error fetching student bookings: $e');
      rethrow;
    }
  }

  // Update existing booking
  Future<void> updateBooking(String docId, Booking booking) async {
    try {
      await bookingsCollection.doc(docId).update(booking.toJson());
      print('Booking updated successfully: ${booking.toJson()}');
    } catch (e) {
      print('Error updating booking: $e');
      rethrow;
    }
  }

  // Delete a booking
  Future<void> deleteBooking(String docId) async {
    try {
      await bookingsCollection.doc(docId).delete();
      print('Booking deleted successfully: $docId');
    } catch (e) {
      print('Error deleting booking: $e');
      rethrow;
    }
  }
}