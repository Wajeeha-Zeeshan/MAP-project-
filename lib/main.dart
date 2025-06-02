import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<void> addData() async {
    try {
      await FirebaseFirestore.instance.collection('testCollection').add({
        'timestamp': DateTime.now(),
        'message': 'Hello from Flutter!',
      });
      print('Data added successfully');
    } catch (e) {
      print('Error adding data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Test',
      home: Scaffold(
        appBar: AppBar(title: Text('Firestore Test')),
        body: Center(
          child: ElevatedButton(onPressed: addData, child: Text('Add Data')),
        ),
      ),
    );
  }
}
