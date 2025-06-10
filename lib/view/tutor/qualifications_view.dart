import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewModel = Provider.of<TutorViewModel>(context, listen: false);
    final tutorData = viewModel.filteredTutors.firstWhere(
      (tutor) => tutor['uid'] == widget.uid,
      orElse: () => {},
    );
    _qualificationController.text = tutorData['qualification'] ?? '';
  }

  @override
  void dispose() {
    _qualificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<TutorViewModel>(context);
    final tutorData = viewModel.filteredTutors.firstWhere(
      (tutor) => tutor['uid'] == widget.uid,
      orElse: () => {},
    );

    final List<String> subjects = List<String>.from(
      tutorData['subjects'] ?? [],
    );
    final Map<String, List<String>> availability =
        Map<String, List<String>>.from(tutorData['availability'] ?? {});

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Qualification')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Academic Qualification',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qualificationController,
              decoration: const InputDecoration(
                labelText: 'Qualification',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final text = _qualificationController.text.trim();
                  if (text.isEmpty) return;

                  await viewModel.saveTutorData(
                    widget.uid,
                    subjects,
                    availability,
                    text,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Qualification updated')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
