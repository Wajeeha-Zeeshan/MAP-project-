import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/review_model.dart';

class ReviewViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitReview(Review review) async {
    await _firestore.collection('reviews').add(review.toJson());
  }

  Stream<List<Review>> getReviewsForTutor(String tutorId) {
    return _firestore
        .collection('reviews')
        .where('tutorId', isEqualTo: tutorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Review.fromJson(doc.data(), doc.id))
                  .toList(),
        );
  }

  Future<double> getAverageRating(String tutorId) async {
    final snapshot =
        await _firestore
            .collection('reviews')
            .where('tutorId', isEqualTo: tutorId)
            .get();

    if (snapshot.docs.isEmpty) return 0.0;

    final total = snapshot.docs.fold<double>(
      0.0,
      (sum, doc) => sum + (doc['rating'] as num).toDouble(),
    );

    return total / snapshot.docs.length;
  }
}
