import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/widgets/app_buttons.dart';
import 'package:luqta/core/widgets/app_text_field.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/review/domain/entities/review_submission.dart';
import 'package:luqta/features/review/review_dependencies.dart';

class WriteReviewScreen extends StatefulWidget {
  final String bookingId;
  final String photographerId;
  final String photographerName;

  const WriteReviewScreen({
    super.key,
    required this.bookingId,
    required this.photographerId,
    required this.photographerName,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  double _overallRating = 0;
  double _qualityRating = 0;
  double _professionalismRating = 0;
  double _communicationRating = 0;
  double _valueRating = 0;

  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool _canSubmit() {
    return _overallRating > 0 && _commentController.text.trim().isNotEmpty;
  }

  Future<void> _submitReview() async {
    if (!_canSubmit()) return;

    setState(() => _isSubmitting = true);

    try {
      final userResult = await AuthDependencies.getCurrentUser().call();
      final userId = userResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final review = ReviewSubmission(
        bookingId: widget.bookingId,
        reviewerId: userId,
        targetId: widget.photographerId,
        rating: _overallRating.toInt(),
        comment: _commentController.text.trim().isNotEmpty
            ? _commentController.text.trim()
            : null,
        createdAt: DateTime.now(),
      );
      final result = await ReviewDependencies.submitReview().call(review);
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ?? 'Failed to submit review',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Write Review')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photographer Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 24, child: Icon(Icons.person)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.photographerName, style: AppTypography.h4),
                        Text(
                          'How was your experience?',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Overall Rating
            Text('Overall Rating', style: AppTypography.h3),
            const SizedBox(height: 12),
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        iconSize: 48,
                        icon: Icon(
                          index < _overallRating
                              ? Icons.star
                              : Icons.star_border,
                          color: AppColors.cta,
                        ),
                        onPressed: () {
                          setState(() => _overallRating = index + 1.0);
                        },
                      );
                    }),
                  ),
                  if (_overallRating > 0)
                    Text(
                      _getRatingText(_overallRating),
                      style: AppTypography.h4.copyWith(color: AppColors.cta),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Detailed Ratings
            Text('Detailed Ratings', style: AppTypography.h3),
            const SizedBox(height: 16),

            _buildRatingSlider(
              'Quality',
              Icons.high_quality,
              _qualityRating,
              (value) => setState(() => _qualityRating = value),
            ),
            const SizedBox(height: 16),

            _buildRatingSlider(
              'Professionalism',
              Icons.business_center,
              _professionalismRating,
              (value) => setState(() => _professionalismRating = value),
            ),
            const SizedBox(height: 16),

            _buildRatingSlider(
              'Communication',
              Icons.chat_bubble,
              _communicationRating,
              (value) => setState(() => _communicationRating = value),
            ),
            const SizedBox(height: 16),

            _buildRatingSlider(
              'Value for Money',
              Icons.payments,
              _valueRating,
              (value) => setState(() => _valueRating = value),
            ),
            const SizedBox(height: 24),

            // Comment
            Text('Your Review', style: AppTypography.h3),
            const SizedBox(height: 12),
            AppTextField(
              controller: _commentController,
              label: 'Tell us about your experience',
              hint: 'Share your thoughts about the photography session...',
              maxLines: 5,
              maxLength: 500,
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: CTAButton(
                text: 'Submit Review',
                onPressed: _canSubmit() && !_isSubmitting
                    ? _submitReview
                    : null,
                isLoading: _isSubmitting,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSlider(
    String label,
    IconData icon,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label, style: AppTypography.bodyLarge),
            const Spacer(),
            if (value > 0)
              Text(
                value.toStringAsFixed(1),
                style: AppTypography.h4.copyWith(color: AppColors.cta),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: 0,
          max: 5,
          divisions: 10,
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
          activeColor: AppColors.cta,
        ),
      ],
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 3.5) return 'Very Good';
    if (rating >= 2.5) return 'Good';
    if (rating >= 1.5) return 'Fair';
    return 'Poor';
  }
}
