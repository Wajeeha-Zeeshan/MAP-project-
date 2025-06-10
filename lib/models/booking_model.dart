import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String? id; // Optional, can be Firestore doc ID
  final String tutorName;
  final String tutorId; // Required field
  final String studentId; // Required field
  final String subject;
  final String day;
  final String timeSlot;
  final DateTime createdAt;

  Booking({
    this.id,
    required this.tutorName,
    required this.tutorId,
    required this.studentId,
    required this.subject,
    required this.day,
    required this.timeSlot,
    required this.createdAt,
  });

  // Factory constructor for creating a Booking from a Firestore document
  factory Booking.fromJson(Map<String, dynamic> json) {
    try {
      return Booking(
        id: json['id'] as String?,
        tutorName: json['tutorName'] as String? ?? 'Unknown Tutor',
        tutorId: json['tutorId'] as String? ?? '', // Handle missing tutorId
        studentId:
            json['studentId'] as String? ?? '', // Handle missing studentId
        subject: json['subject'] as String? ?? 'Unknown Subject',
        day: json['day'] as String? ?? 'Unknown Day',
        timeSlot: json['timeSlot'] as String? ?? 'Unknown Time',
        createdAt:
            (json['createdAt'] is Timestamp)
                ? (json['createdAt'] as Timestamp).toDate()
                : DateTime.parse(
                  json['createdAt'] as String,
                ), // Handle string or Timestamp
      );
    } catch (e) {
      print('Error parsing booking: $e');
      rethrow;
    }
  }

  // Method to convert a Booking to a Firestore document
  Map<String, dynamic> toJson() {
    return {
      'tutorName': tutorName,
      'tutorId': tutorId,
      'studentId': studentId,
      'subject': subject,
      'day': day,
      'timeSlot': timeSlot,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
