/// Fix added 🡒 `fees` ─ holds each subject’s hourly rate.
class TutorModel {
  final String uid;
  final List<String> subjects;
  final Map<String, List<String>> availability;
  final String qualification;
  final Map<String, double> fees; // 🆕 new field

  TutorModel({
    required this.uid,
    required this.subjects,
    required this.availability,
    required this.qualification,
    required this.fees, // 🆕 ctor arg
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'subjects': subjects,
      'availability': availability,
      'qualification': qualification,
      'fees': fees, // 🆕 save to Firestore
    };
  }

  factory TutorModel.fromMap(Map<String, dynamic> map, String id) {
    // Parse fees safely; if not present, empty map.
    final Map<String, double> parsedFees = Map<String, dynamic>.from(
      map['fees'] ?? {},
    ).map((k, v) => MapEntry(k, (v as num).toDouble()));

    return TutorModel(
      uid: id,
      subjects: List<String>.from(map['subjects'] ?? []),
      availability:
          (map['availability'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, List<String>.from(value)),
          ) ??
          {
            'Monday': [],
            'Tuesday': [],
            'Wednesday': [],
            'Thursday': [],
            'Friday': [],
            'Saturday': [],
            'Sunday': [],
          },
      qualification: map['qualification'] ?? '',
      fees: parsedFees, // 🆕 assign
    );
  }
}
