<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/tutor_viewmodel.dart';

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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8fd3fe), Color(0xFF4facfe)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<TutorViewModel>(
                builder: (context, tutorViewModel, child) {
                  return Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search Tutors',
                          hintText: 'Enter tutor name',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        onChanged: (query) {
                          tutorViewModel.updateSearchQuery(query);
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Available Tutors',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(tutor['name'] as String),
                                subtitle: Text(tutor['email'] as String),
                                trailing: const Icon(Icons.contact_mail),
                                onTap: () {
                                  // Handle tutor selection
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
=======

>>>>>>> 0f976677689fc1f2011bd67d9a0725792678e398
