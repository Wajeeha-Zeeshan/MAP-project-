import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role;
  final int age;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.age,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    uid: map['uid'] as String,
    email: map['email'] as String,
    name: map['name'] as String,
    role: map['role'] as String,
    age: (map['age'] as num).toInt(),
  );

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'name': name,
    'role': role,
    'age': age,
  };
}

class AuthViewModel with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  bool _busy = false;
  String? _error;
  UserModel? _user;

  bool get loading => _busy;
  String? get error => _error;
  UserModel? get user => _user;

  // ─────────────────────────── SIGN-UP ────────────────────────────
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    required int age,
  }) async => _runBusy(() async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    _user = UserModel(
      uid: cred.user!.uid,
      email: email.trim(),
      name: name,
      role: role,
      age: age,
    );

    await _db.collection('users').doc(_user!.uid).set(_user!.toMap());
  });

  // ─────────────────────────── LOG-IN ─────────────────────────────
  Future<void> login({required String email, required String password}) async =>
      _runBusy(() async {
        await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        final snap =
            await _db.collection('users').doc(_auth.currentUser!.uid).get();

        _user = UserModel.fromMap(snap.data()!);
      });

  // ───────────────────────── PASSWORD RESET ───────────────────────
  Future<void> sendResetEmail(String email) async =>
      _runBusy(() => _auth.sendPasswordResetEmail(email: email.trim()));

  // ─────────────────────────── LOG-OUT ────────────────────────────
  Future<void> logout() => _auth.signOut();

  // ────────────────────────── HELPERS ─────────────────────────────
  Future<void> _runBusy(Future<void> Function() task) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await task();
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
