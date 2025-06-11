import 'package:flutter/material.dart';
import '../../models/review_model.dart';
import '../../viewmodels/review_viewmodel.dart';


class ReviewFormView extends StatefulWidget {
  final String tutorId;
  final String studentId;
  final String tutorName;

  const ReviewFormView({
    super.key,
    required this.tutorId,
    required this.studentId,
    required this.tutorName,
  });

  @override
  State<ReviewFormView> createState() => _ReviewFormViewState();
}

class _ReviewFormViewState extends State<ReviewFormView> {
  final _formKey = GlobalKey<FormState>();
  String _comment = '';
  final _viewModel = ReviewViewModel();

  void _submitReview() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final review = Review(
        tutorId: widget.tutorId,
        studentId: widget.studentId,
        rating: 0.0,
        comment: _comment,
        createdAt: DateTime.now(),
      );

      await _viewModel.submitReview(review);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Leave a Review for ${widget.tutorName}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4facfe),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Comment',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSaved: (value) => _comment = value ?? '',
                validator: (value) =>
                    value!.isEmpty ? 'Please write a comment' : null,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4facfe),
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _submitReview,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 