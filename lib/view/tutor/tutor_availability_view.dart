<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TutorAvailabilityView extends StatefulWidget {
  final String userId;

  const TutorAvailabilityView({required this.userId, super.key});

  @override
  _TutorAvailabilityViewState createState() => _TutorAvailabilityViewState();
}

class _TutorAvailabilityViewState extends State<TutorAvailabilityView> {
  List<String> _subjects = [];
  Map<String, List<String>> _availability = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTutorData();
  }

  Future<void> _fetchTutorData() async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('tutors')
              .doc(widget.userId)
              .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _subjects = List<String>.from(data['subjects'] ?? []);
          final availabilityData =
              data['availability'] as Map<String, dynamic>?;
          if (availabilityData != null) {
            _availability = availabilityData.map(
              (key, value) => MapEntry(key, List<String>.from(value)),
            );
          }
          _isLoading = false;
        });
      } else {
        // If no tutor document exists, initialize it
        await _initializeTutorData();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeTutorData() async {
    try {
      await FirebaseFirestore.instance
          .collection('tutors')
          .doc(widget.userId)
          .set({'subjects': _subjects, 'availability': _availability});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing tutor data: $e')),
      );
    }
  }

  Future<void> _updateTutorData() async {
    try {
      await FirebaseFirestore.instance
          .collection('tutors')
          .doc(widget.userId)
          .update({'subjects': _subjects, 'availability': _availability});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating data: $e')));
    }
  }

  void _addSubject() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Subject'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Subject Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final subject = controller.text.trim();
                if (subject.isNotEmpty && !_subjects.contains(subject)) {
                  setState(() {
                    _subjects.add(subject);
                  });
                  _updateTutorData();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addAvailability(String day) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Availability for $day'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Time Slot (e.g., 9:00 AM - 10:00 AM)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final timeSlot = controller.text.trim();
                if (timeSlot.isNotEmpty) {
                  setState(() {
                    _availability[day]!.add(timeSlot);
                  });
                  _updateTutorData();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4facfe),
        elevation: 0,
        title: const Text('Manage Availability'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8fd3fe), Color(0xFF4facfe)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Subjects You Teach',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8.0,
                            children:
                                _subjects.map((subject) {
                                  return Chip(
                                    label: Text(subject),
                                    onDeleted: () {
                                      setState(() {
                                        _subjects.remove(subject);
                                      });
                                      _updateTutorData();
                                    },
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _addSubject,
                            child: const Text('Add Subject'),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Availability',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ..._availability.keys.map((day) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      day,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () => _addAvailability(day),
                                    ),
                                  ],
                                ),
                                if (_availability[day]!.isEmpty)
                                  const Text('No time slots added.'),
                                ..._availability[day]!.map((slot) {
                                  return ListTile(
                                    title: Text(slot),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          _availability[day]!.remove(slot);
                                        });
                                        _updateTutorData();
                                      },
                                    ),
                                  );
                                }).toList(),
                                const Divider(),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
      ),
    );
  }
}
=======

>>>>>>> 0f976677689fc1f2011bd67d9a0725792678e398
