import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingViewModel {
  final CollectionReference bookingsCollection = FirebaseFirestore.instance
      .collection('bookings');

  Future<void> saveBooking(Booking booking) async {
    try {
      await bookingsCollection.add(booking.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Optional: Fetch all bookings (e.g., for admin or tutor view)
  Future<List<Booking>> getAllBookings() async {
    try {
      QuerySnapshot snapshot = await bookingsCollection.get();
      return snapshot.docs.map((doc) {
        return Booking.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
