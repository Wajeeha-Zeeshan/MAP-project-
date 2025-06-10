import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String? id;
  final String tutorId;
  final String studentId;
  final String comment;
  final double rating;
  final DateTime createdAt;

  Review({
    this.id,
    required this.tutorId,
    required this.studentId,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json, String id) {
    return Review(
      id: id,
      tutorId: json['tutorId'] ?? '',
      studentId: json['studentId'] ?? '',
      comment: json['comment'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tutorId': tutorId,
      'studentId': studentId,
      'comment': comment,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
