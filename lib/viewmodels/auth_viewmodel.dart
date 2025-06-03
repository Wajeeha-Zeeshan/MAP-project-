import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthViewModel with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _user;
  String? _recoveredPassword;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  String? get recoveredPassword => _recoveredPassword;

  Future<void> signup({
    required String email,
    required String password,
    required String name,
    required String role,
    required int age,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      String uid = DateTime.now().millisecondsSinceEpoch.toString();

      UserModel userModel = UserModel(
        uid: uid,
        email: email,
        name: name,
        role: role,
        age: age,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userModel.toMap());

      _user = userModel;
      print('User registered with UID: $uid and email: $email');
    } catch (e) {
      _errorMessage = e.toString();
      print('Signup error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('Attempting login for email: $email');
      QuerySnapshot query =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      print('Query results: ${query.docs.length} documents found');
      if (query.docs.isEmpty) {
        throw Exception('User with email $email not found');
      }

      var userDoc = query.docs.first;
      UserModel userModel = UserModel.fromMap(
        userDoc.data() as Map<String, dynamic>,
      );
      print('Retrieved user: ${userModel.toMap()}');

      if (userModel.password != password.trim()) {
        print(
          'Provided password: ${password.trim()}, Stored password: ${userModel.password}',
        );
        throw Exception('Incorrect password for user $email');
      }

      _user = userModel;
      print(
        'Login successful for user: ${userModel.email} with role: ${userModel.role}',
      );
    } catch (e) {
      _errorMessage = e.toString();
      print('Login error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recoverPassword({required String email}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _recoveredPassword = null;
      notifyListeners();

      print('Attempting password recovery for email: $email');
      QuerySnapshot query =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      print('Query results: ${query.docs.length} documents found');
      if (query.docs.isEmpty) {
        throw Exception('User with email $email not found');
      }

      var userDoc = query.docs.first;
      UserModel userModel = UserModel.fromMap(
        userDoc.data() as Map<String, dynamic>,
      );
      _recoveredPassword = userModel.password;
      print('Password recovered: $_recoveredPassword');
    } catch (e) {
      _errorMessage = e.toString();
      print('Password recovery error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}