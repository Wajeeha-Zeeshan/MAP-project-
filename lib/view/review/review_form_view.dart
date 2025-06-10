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
        rating: 0.0, // Default or placeholder since rating is removed
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
    return AlertDialog(
      title: Text('Leave a Review for ${widget.tutorName}'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Comment'),
          onSaved: (value) => _comment = value ?? '',
          validator:
              (value) => value!.isEmpty ? 'Please write a comment' : null,
        ),
      ),
      actions: [
        TextButton(onPressed: _submitReview, child: const Text('Submit')),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
