import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../booking/booking_list_view.dart';

class TutorAvailabilityView extends StatefulWidget {
  final String userId;

  const TutorAvailabilityView({required this.userId, super.key});

  @override
  _TutorAvailabilityViewState createState() => _TutorAvailabilityViewState();
}

class _TutorAvailabilityViewState extends State<TutorAvailabilityView> {
  List<String> _subjects = [];
  Map<String, List<Map<String, String>>> _availability = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };
  Map<String, double> _fees = {};
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
            _availability = availabilityData.map((key, value) {
              final slots = value as List;
              final safeSlots =
                  slots.map<Map<String, String>>((e) {
                    if (e is Map) {
                      final date = e['date']?.toString() ?? '';
                      final time = e['time']?.toString() ?? '';
                      return {'date': date, 'time': time};
                    }
                    return {'date': '', 'time': ''};
                  }).toList();
              return MapEntry(key, safeSlots);
            });
          }

          final feesData = data['fees'] as Map<String, dynamic>?;
          if (feesData != null) {
            _fees = feesData.map(
              (key, value) => MapEntry(
                key,
                value is int ? value.toDouble() : value as double,
              ),
            );
          }

          _isLoading = false;
        });
      } else {
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
          .set({
            'uid': widget.userId,
            'subjects': _subjects,
            'availability': _availability,
            'fees': _fees,
          });
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
          .update({
            'subjects': _subjects,
            'availability': _availability,
            'fees': _fees,
          });
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
    final subjectController = TextEditingController();
    final feeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Subject'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'Subject Name'),
              ),
              TextField(
                controller: feeController,
                decoration: const InputDecoration(
                  labelText: 'Fee per Hour (e.g., 50.0)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final subject = subjectController.text.trim();
                final fee = double.tryParse(feeController.text.trim()) ?? 0.0;
                if (subject.isNotEmpty &&
                    !_subjects.contains(subject) &&
                    fee > 0) {
                  setState(() {
                    _subjects.add(subject);
                    _fees[subject] = fee;
                  });
                  _updateTutorData();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid subject and fee'),
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editFee(String subject) {
    final feeController = TextEditingController(
      text: _fees[subject]?.toString(),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Fee for $subject'),
          content: TextField(
            controller: feeController,
            decoration: const InputDecoration(labelText: 'Fee per Hour'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final fee = double.tryParse(feeController.text.trim()) ?? 0.0;
                if (fee > 0) {
                  setState(() {
                    _fees[subject] = fee;
                  });
                  _updateTutorData();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid fee')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _addAvailability(String day) async {
    final timeController = TextEditingController();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Availability for $day'),
          content: TextField(
            controller: timeController,
            decoration: const InputDecoration(
              labelText: 'Time Slot (e.g., 10:00 AM - 11:00 AM)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final timeSlot = timeController.text.trim();
                if (timeSlot.isNotEmpty) {
                  setState(() {
                    _availability[day]!.add({
                      'date': selectedDate.toIso8601String(),
                      'time': timeSlot,
                    });
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

  void _viewBookings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorBookingListView(tutorId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Added white background here
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        title: const Text('Manage Availability', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 10.0,
                        runSpacing: 10.0,
                        children: _subjects.map((subject) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue[100]!.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  subject,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'RM${_fees[subject]?.toStringAsFixed(2) ?? '0.00'}/hr',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () => _editFee(subject),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _subjects.remove(subject);
                                      _fees.remove(subject);
                                    });
                                    _updateTutorData();
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: _addSubject,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Add Subject', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Availability',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ..._availability.keys.map((day) {
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 15),
                          color: Colors.blue[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      day,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, color: Colors.blue),
                                      onPressed: () => _addAvailability(day),
                                    ),
                                  ],
                                ),
                                if (_availability[day]!.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'No time slots added.',
                                      style: TextStyle(color: Colors.blueGrey),
                                    ),
                                  ),
                                ..._availability[day]!.map((slot) {
                                  final dateStr = slot['date'] ?? '';
                                  final time = slot['time'] ?? '';
                                  String formattedDate = 'Invalid Date';
                                  try {
                                    final date = DateTime.parse(dateStr);
                                    formattedDate =
                                        '${date.day}/${date.month}/${date.year}';
                                  } catch (_) {}

                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      title: Text(
                                        '$formattedDate - $time',
                                        style: const TextStyle(color: Colors.blueGrey),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _availability[day]!.remove(slot);
                                          });
                                          _updateTutorData();
                                        },
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: _viewBookings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'View Bookings',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}