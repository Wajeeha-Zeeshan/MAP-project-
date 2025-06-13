import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../viewmodels/tutor_viewmodel.dart';
import 'tutor_detail_view.dart';

class TutorListView extends StatelessWidget {
  const TutorListView({super.key});

  // Average rating display widget
  Widget buildAverageRating(String tutorId) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('reviews')
              .where('tutorId', isEqualTo: tutorId)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final reviews = snapshot.data!.docs;
        if (reviews.isEmpty) {
          return const Text("No ratings", style: TextStyle(fontSize: 12));
        }

        double avgRating =
            reviews
                .map((doc) => (doc['rating'] ?? 0).toDouble())
                .reduce((a, b) => a + b) /
            reviews.length;

        return Row(
          children: [
            RatingBarIndicator(
              rating: avgRating,
              itemBuilder:
                  (context, _) => const Icon(Icons.star, color: Colors.amber),
              itemCount: 5,
              itemSize: 16.0,
              direction: Axis.horizontal,
            ),
            const SizedBox(width: 4),
            Text(
              avgRating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      },
    );
  }

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
                            final subjects = List<String>.from(
                              tutor['subjects'] ?? [],
                            );
                            final tutorId =
                                tutor['uid'] ??
                                ''; // adjust based on your Firestore

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
                                  tutor['name'] ?? 'No Name',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tutor['email'] ?? 'No email',
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
                                    const SizedBox(height: 4),
                                    buildAverageRating(tutorId),
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
