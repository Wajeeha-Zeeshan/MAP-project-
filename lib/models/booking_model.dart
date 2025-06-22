import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String? id; // Firestore document ID (optional)
  final String tutorName;
  final String tutorId;
  final String studentId;
  final String subject;
  final String day;
  final String date;
  final String timeSlot;
  final DateTime createdAt;
  final String status; // 'pending', 'accepted', 'rejected', 'paid'
  final bool isPaid;

  Booking({
    this.id,
    required this.tutorName,
    required this.tutorId,
    required this.studentId,
    required this.subject,
    required this.day,
    required this.date,
    required this.timeSlot,
    required this.createdAt,
    this.status = 'pending',
    this.isPaid = false,
  });

  /// Convert Firestore document into Booking object
  factory Booking.fromJson(Map<String, dynamic> json, [String? documentId]) {
    return Booking(
      id: documentId,
      tutorName: json['tutorName'] ?? '',
      tutorId: json['tutorId'] ?? '',
      studentId: json['studentId'] ?? '',
      subject: json['subject'] ?? '',
      day: json['day'] ?? '',
      date: json['date'] ?? '',
      timeSlot: json['timeSlot'] ?? '',
      createdAt:
          json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'pending',
      isPaid: json['isPaid'] ?? false,
    );
  }

  /// Convert Booking object into Firestore-compatible map
  Map<String, dynamic> toJson() {
    return {
      'tutorName': tutorName,
      'tutorId': tutorId,
      'studentId': studentId,
      'subject': subject,
      'day': day,
      'date': date,
      'timeSlot': timeSlot,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'isPaid': isPaid,
    };
  }
}
