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
  Map<String, List<String>> _availability = {
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
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('tutors').doc(widget.userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _subjects = List<String>.from(data['subjects'] ?? []);
          final availabilityData = data['availability'] as Map<String, dynamic>?;
          if (availabilityData != null) {
            _availability = availabilityData.map((key, value) => MapEntry(key, List<String>.from(value)));
          }
          final feesData = data['fees'] as Map<String, dynamic>?;
          if (feesData != null) {
            _fees = feesData.map((key, value) => MapEntry(key, value as double));
          }
          _isLoading = false;
        });
      } else {
        await _initializeTutorData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeTutorData() async {
    try {
      await FirebaseFirestore.instance.collection('tutors').doc(widget.userId).set({
        'uid': widget.userId,
        'subjects': _subjects,
        'availability': _availability,
        'fees': _fees,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error initializing tutor data: $e')));
    }
  }

  Future<void> _updateTutorData() async {
    try {
      await FirebaseFirestore.instance.collection('tutors').doc(widget.userId).update({
        'subjects': _subjects,
        'availability': _availability,
        'fees': _fees,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating data: $e')));
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
                decoration: const InputDecoration(labelText: 'Fee per Hour (e.g., 50.0)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                final subject = subjectController.text.trim();
                final fee = double.tryParse(feeController.text.trim()) ?? 0.0;
                if (subject.isNotEmpty && !_subjects.contains(subject) && fee > 0) {
                  setState(() {
                    _subjects.add(subject);
                    _fees[subject] = fee;
                  });
                  _updateTutorData();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid subject and fee')),
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
    final feeController = TextEditingController(text: _fees[subject].toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Fee for $subject'),
          content: TextField(
            controller: feeController,
            decoration: const InputDecoration(labelText: 'Fee per Hour (e.g., 50.0)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
                    const SnackBar(content: Text('Please enter a valid fee')),
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

  void _addAvailability(String day) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Availability for $day'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Time Slot (e.g., 9:00 AM - 10:00 AM)'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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

  void _viewBookings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingListView(tutorName: widget.userId),
      ),
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
        color: Colors.white,
        child: _isLoading
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: _subjects.map((subject) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 6),
                                  Text('RM${_fees[subject]?.toStringAsFixed(2) ?? '0.00'}/hr', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                  const SizedBox(width: 8),
                                  GestureDetector(onTap: () => _editFee(subject), child: const Icon(Icons.edit, size: 18, color: Color(0xFF4facfe))),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _subjects.remove(subject);
                                        _fees.remove(subject);
                                      });
                                      _updateTutorData();
                                    },
                                    child: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _addSubject,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4facfe),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Add Subject'),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Availability',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        ..._availability.keys.map((day) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(day, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Colors.black),
                                    onPressed: () => _addAvailability(day),
                                  ),
                                ],
                              ),
                              if (_availability[day]!.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Text('No time slots added.', style: TextStyle(color: Colors.black54)),
                                ),
                              ..._availability[day]!.map((slot) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                                  child: ListTile(
                                    title: Text(slot, style: const TextStyle(color: Colors.black)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
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
                              const Divider(color: Colors.black12),
                            ],
                          );
                        }).toList(),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _viewBookings,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4facfe),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('View Bookings', style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
