class TutorModel {
  final String uid;
  final List<String> subjects;
  final Map<String, List<String>> availability;
  final String qualification; // ✅ NEW FIELD

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
      'qualification': qualification, // ✅ ADD HERE
    };
  }

  factory TutorModel.fromMap(Map<String, dynamic> map, String id) {
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
      qualification: map['qualification'] ?? '', // ✅ PARSE FROM MAP
    );
  }
}
