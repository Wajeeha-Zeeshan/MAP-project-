class TutorModel {
  final String uid;
  final List<String> subjects;
  final Map<String, List<Map<String, String>>> availability;
  final String qualification;

  TutorModel({
    required this.uid,
    required this.subjects,
    required this.availability,
    required this.qualification,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'subjects': subjects,
      'availability': availability,
      'qualification': qualification,
    };
  }

  factory TutorModel.fromMap(Map<String, dynamic> map, String id) {
    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final rawAvailability = map['availability'] as Map<String, dynamic>? ?? {};
    final parsedAvailability = <String, List<Map<String, String>>>{};

    for (var day in daysOfWeek) {
      final slots = rawAvailability[day];
      final validSlots = <Map<String, String>>[];

      if (slots is List) {
        for (var slot in slots) {
          if (slot is Map) {
            final date = slot['date']?.toString();
            final time = slot['time']?.toString();
            if (date != null && time != null) {
              validSlots.add({'date': date, 'time': time});
            }
          }
        }
      }

      parsedAvailability[day] = validSlots;
    }

    return TutorModel(
      uid: id,
      subjects: List<String>.from(map['subjects'] ?? []),
      availability: parsedAvailability,
      qualification: map['qualification'] ?? '',
    );
  }
}
