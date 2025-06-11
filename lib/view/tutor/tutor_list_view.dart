import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/tutor_viewmodel.dart';
import 'tutor_detail_view.dart';

class TutorListView extends StatelessWidget {
  const TutorListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TutorViewModel(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF4facfe),
          elevation: 0,
          title: const Text('Available Tutors'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<TutorViewModel>(
                builder: (context, tutorViewModel, child) {
                  return Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Search Tutors',
                          hintText: 'Enter tutor name or subject',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        onChanged: (query) {
                          tutorViewModel.updateSearchQuery(query);
                        },
                      ),
                      const SizedBox(height: 10),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Available Tutors',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (tutorViewModel.isLoading)
                        const Center(child: CircularProgressIndicator()),
                      if (tutorViewModel.errorMessage != null)
                        Text(
                          tutorViewModel.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: tutorViewModel.filteredTutors.length,
                          itemBuilder: (context, index) {
                            final tutor = tutorViewModel.filteredTutors[index];
                            final subjects = tutor['subjects'] as List<String>;
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: Text(
                                  tutor['name'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tutor['email'] as String,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Subjects: ${subjects.isEmpty ? 'None' : subjects.join(', ')}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: Color(0xFF4facfe),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              TutorDetailView(tutor: tutor),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

