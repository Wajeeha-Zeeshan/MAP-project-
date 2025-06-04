class Booking {
  final String tutorName;
  final String subject;
  final String day;
  final String timeSlot;
  final DateTime createdAt;

  Booking({
    required this.tutorName,
    required this.subject,
    required this.day,
    required this.timeSlot,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'tutorName': tutorName,
      'subject': subject,
      'day': day,
      'timeSlot': timeSlot,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      tutorName: json['tutorName'],
      subject: json['subject'],
      day: json['day'],
      timeSlot: json['timeSlot'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
