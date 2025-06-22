import 'package:flutter/material.dart';
import '../../models/review_model.dart';
import '../../viewmodels/review_viewmodel.dart';

class ReviewListView extends StatelessWidget {
  final String tutorId;
  final String tutorName;
  final ReviewViewModel _viewModel = ReviewViewModel();

  ReviewListView({super.key, required this.tutorId, required this.tutorName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Reviews for $tutorName'),
        backgroundColor: const Color(0xFF4facfe),
      ),
      body: StreamBuilder<List<Review>>(
        stream: _viewModel.getReviewsForTutor(tutorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final reviews = snapshot.data ?? [];

          if (reviews.isEmpty) {
            return const Center(child: Text('No reviews available yet.'));
          }

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    review.comment,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Rating: ${review.rating.toStringAsFixed(1)} ⭐'),
                      Text(
                        'Date: ${review.createdAt.toLocal().toString().split(" ")[0]}',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
