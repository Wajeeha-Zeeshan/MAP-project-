class TutorModel {
  final String uid;
  final List<String> subjects;
  final Map<String, List<String>> availability;

  TutorModel({
    required this.uid,
    required this.subjects,
    required this.availability,
  });

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'subjects': subjects, 'availability': availability};
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
    );
  }
}