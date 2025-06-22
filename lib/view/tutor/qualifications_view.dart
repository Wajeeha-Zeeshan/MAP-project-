import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../viewmodels/tutor_viewmodel.dart';

class QualificationsView extends StatefulWidget {
  final String uid;

  const QualificationsView({Key? key, required this.uid}) : super(key: key);

  @override
  State<QualificationsView> createState() => _QualificationsViewState();
}

class _QualificationsViewState extends State<QualificationsView> {
  final TextEditingController _qualificationController =
      TextEditingController();
  final TextEditingController _newQualificationController =
      TextEditingController();

  Map<String, List<Map<String, String>>> _parsedAvailability = {};
  List<String> _subjects = [];
  List<String> _qualifications = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final viewModel = Provider.of<TutorViewModel>(context, listen: false);
    final tutorData = viewModel.filteredTutors.firstWhere(
      (tutor) => tutor['uid'] == widget.uid,
      orElse: () => {},
    );

    _qualificationController.text = tutorData['qualification'] ?? '';
    _subjects = List<String>.from(tutorData['subjects'] ?? []);

    final rawAvailability = tutorData['availability'];
    if (rawAvailability is Map<String, dynamic>) {
      _parsedAvailability = {};
      rawAvailability.forEach((day, value) {
        final slots = value is List ? value : [];
        _parsedAvailability[day] =
            slots.map<Map<String, String>>((slot) {
              if (slot is Map<String, dynamic>) {
                return {
                  'date': slot['date']?.toString() ?? '',
                  'time': slot['time']?.toString() ?? '',
                };
              }
              return {'date': '', 'time': ''};
            }).toList();
      });
    }

    if (tutorData['qualifications'] is List) {
      _qualifications = List<String>.from(tutorData['qualifications']);
    }
  }

  @override
  void dispose() {
    _qualificationController.dispose();
    _newQualificationController.dispose();
    super.dispose();
  }

  void _addQualificationDialog() {
    _newQualificationController.clear();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add Qualification'),
          content: TextField(
            controller: _newQualificationController,
            decoration: const InputDecoration(labelText: 'Enter qualification'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final text = _newQualificationController.text.trim();
                if (text.isNotEmpty) {
                  setState(() {
                    _qualifications.add(text);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editMainQualification() {
    _newQualificationController.text = _qualificationController.text;
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Edit Main Qualification'),
          content: TextField(
            controller: _newQualificationController,
            decoration: const InputDecoration(labelText: 'Main qualification'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _qualificationController.text =
                      _newQualificationController.text.trim();
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TutorViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Qualification'),
        backgroundColor: const Color(0xFF4facfe),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Qualifications',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                itemCount: 1 + _qualifications.length,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final mainQualification = _qualificationController.text;
                    return Card(
                      child: ListTile(
                        title: Text(
                          mainQualification.isEmpty
                              ? '[No main qualification]'
                              : mainQualification,
                        ),
                        subtitle: const Text('Main Qualification'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: _editMainQualification,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _qualificationController.clear();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    final q = _qualifications[index - 1];
                    return Card(
                      child: ListTile(
                        title: Text(q),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _newQualificationController.text = q;
                                showDialog(
                                  context: context,
                                  builder: (_) {
                                    return AlertDialog(
                                      title: const Text('Edit Qualification'),
                                      content: TextField(
                                        controller: _newQualificationController,
                                        decoration: const InputDecoration(
                                          labelText: 'Edit qualification',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            final newText =
                                                _newQualificationController.text
                                                    .trim();
                                            if (newText.isNotEmpty) {
                                              setState(() {
                                                _qualifications[index - 1] =
                                                    newText;
                                              });
                                            }
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Save'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _qualifications.removeAt(index - 1);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add New Qualification'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _addQualificationDialog,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4facfe),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  final mainQualification =
                      _qualificationController.text.trim();
                  if (mainQualification.isEmpty) return;

                  await viewModel.saveTutorData(
                    widget.uid,
                    _subjects,
                    _parsedAvailability,
                    mainQualification,
                  );

                  await FirebaseFirestore.instance
                      .collection('tutors')
                      .doc(widget.uid)
                      .update({'qualifications': _qualifications});

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Qualifications updated')),
                    );
                  }
                },
                child: const Text(
                  'Save All',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}