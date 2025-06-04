import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tutor_model.dart';
import '../models/user_model.dart';

class TutorViewModel with ChangeNotifier {
  final List<TutorModel> _tutors = [];
  List<Map<String, dynamic>> _filteredTutors = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get filteredTutors => _filteredTutors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TutorViewModel() {
    fetchTutors();
  }

  Future<void> fetchTutors() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      QuerySnapshot userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'teacher')
              .get();

      _tutors.clear();
      _filteredTutors.clear();

      for (var userDoc in userSnapshot.docs) {
        UserModel user = UserModel.fromMap(
          userDoc.data() as Map<String, dynamic>,
        );

        DocumentSnapshot tutorDoc =
            await FirebaseFirestore.instance
                .collection('tutors')
                .doc(user.uid)
                .get();

        TutorModel tutor;
        if (tutorDoc.exists) {
          tutor = TutorModel.fromMap(
            tutorDoc.data() as Map<String, dynamic>,
            user.uid,
          );
        } else {
          tutor = TutorModel(
            uid: user.uid,
            subjects: [],
            availability: {
              'Monday': [],
              'Tuesday': [],
              'Wednesday': [],
              'Thursday': [],
              'Friday': [],
              'Saturday': [],
              'Sunday': [],
            },
            fees: {},
          );
          await FirebaseFirestore.instance
              .collection('tutors')
              .doc(user.uid)
              .set(tutor.toMap());
        }

        _tutors.add(tutor);
        _filteredTutors.add({
          'uid': tutor.uid,
          'name': user.name,
          'email': user.email,
          'subjects': tutor.subjects,
          'availability': tutor.availability,
          'fees': tutor.fees,
        });
      }
      _filterTutors();
    } catch (e) {
      _errorMessage = 'Error fetching tutors: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveTutorData(
    String uid,
    List<String> subjects,
    Map<String, List<String>> availability,
    Map<String, double> fees,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('tutors').doc(uid).update({
        'subjects': subjects,
        'availability': availability,
        'fees': fees,
      });

      final tutorIndex = _tutors.indexWhere((tutor) => tutor.uid == uid);
      if (tutorIndex != -1) {
        _tutors[tutorIndex] = TutorModel(
          uid: uid,
          subjects: subjects,
          availability: availability,
          fees: fees,
        );
      }

      final filteredIndex = _filteredTutors.indexWhere(
        (tutor) => tutor['uid'] == uid,
      );
      if (filteredIndex != -1) {
        _filteredTutors[filteredIndex] = {
          'uid': uid,
          'name': _filteredTutors[filteredIndex]['name'],
          'email': _filteredTutors[filteredIndex]['email'],
          'subjects': subjects,
          'availability': availability,
          'fees': fees,
        };
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error saving tutor data: $e';
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _filterTutors();
    notifyListeners();
  }

  void _filterTutors() {
    final query = _searchQuery.toLowerCase();
    if (_searchQuery.isEmpty) {
      _filteredTutors = List.from(_filteredTutors);
      return;
    }

    _filteredTutors =
        _filteredTutors.where((tutor) {
          final name = (tutor['name'] as String).toLowerCase();
          final subjects = tutor['subjects'] as List<String>;
          return name.contains(query) ||
              subjects.any((subject) => subject.toLowerCase().contains(query));
        }).toList();
  }
}
