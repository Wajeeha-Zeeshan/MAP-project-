import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  double _rating = 0.0;
  final _viewModel = ReviewViewModel();

  void _submitReview() async {
    if (_formKey.currentState!.validate() && _rating > 0) {
      _formKey.currentState!.save();
      final review = Review(
        tutorId: widget.tutorId,
        studentId: widget.studentId,
        rating: _rating,
        comment: _comment,
        createdAt: DateTime.now(),
      );

      await _viewModel.submitReview(review);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please give a rating')));
    }
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final filled = index < _rating;
        return IconButton(
          icon: Icon(
            filled ? Icons.star : Icons.star_border,
            color: filled ? Colors.amber : Colors.grey,
            size: 32,
          ),
          onPressed: () {
            setState(() {
              _rating = index + 1.0;
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe3f2fd), Color(0xFFcce7ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2196f3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your Rating:',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  _buildStarRating(),
                  const SizedBox(height: 10),
                  TextFormField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Comment',
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF2196f3)),
                      ),
                    ),
                    onSaved: (value) => _comment = value ?? '',
                    validator:
                        (value) => value!.isEmpty ? 'Please write a comment' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196f3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _submitReview,
                        child: Text(
                          'Submit',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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