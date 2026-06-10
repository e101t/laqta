import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/widgets/app_buttons.dart';
import 'package:laqta/core/widgets/app_text_field.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/review/domain/entities/review_submission.dart';
import 'package:laqta/features/review/review_dependencies.dart';
import 'package:laqta/features/trust/trust_dependencies.dart';

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
  double _onTimeRating = 0;
  double _communicationRating = 0;
  double _qualityRating = 0;
  double _deliverySpeedRating = 0;
  bool? _recommend;

  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool _canSubmit() {
    return _onTimeRating > 0 &&
        _communicationRating > 0 &&
        _qualityRating > 0 &&
        _deliverySpeedRating > 0;
  }

  int _averageRating() {
    final avg =
        (_onTimeRating +
            _communicationRating +
            _qualityRating +
            _deliverySpeedRating) /
        4;
    return avg.round().clamp(1, 5);
  }

  Future<void> _submitReview() async {
    final localizations = AppLocalizations.of(context);
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
        rating: _averageRating(),
        qualityRating: _qualityRating.round(),
        communicationRating: _communicationRating.round(),
        onTimeRating: _onTimeRating.round(),
        deliverySpeedRating: _deliverySpeedRating.round(),
        recommend: _recommend,
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

      await TrustDependencies.incrementReviewStats().call(
        bookingId: widget.bookingId,
        photographerId: widget.photographerId,
        qualityRating: _qualityRating,
        communicationRating: _communicationRating,
        onTimeRating: _onTimeRating,
        deliverySpeedRating: _deliverySpeedRating,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.reviewSubmitted),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.reviewSubmitFailed),
            backgroundColor: Theme.of(context).colorScheme.error,
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
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.smartReview)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 24, child: Icon(Icons.person)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.photographerName,
                          style: textTheme.titleMedium,
                        ),
                        Text(
                          localizations.smartReviewSubtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildRatingSlider(
              localizations.onTimeDelivery,
              Icons.timer,
              _onTimeRating,
              (value) => setState(() => _onTimeRating = value),
            ),
            const SizedBox(height: 16),
            _buildRatingSlider(
              localizations.communication,
              Icons.chat_bubble,
              _communicationRating,
              (value) => setState(() => _communicationRating = value),
            ),
            const SizedBox(height: 16),
            _buildRatingSlider(
              localizations.quality,
              Icons.high_quality,
              _qualityRating,
              (value) => setState(() => _qualityRating = value),
            ),
            const SizedBox(height: 16),
            _buildRatingSlider(
              localizations.deliverySpeed,
              Icons.local_shipping,
              _deliverySpeedRating,
              (value) => setState(() => _deliverySpeedRating = value),
            ),
            const SizedBox(height: 24),

            Text(localizations.recommendQuestion, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text(localizations.yes),
                    selected: _recommend == true,
                    onSelected: (selected) =>
                        setState(() => _recommend = selected ? true : null),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: Text(localizations.no),
                    selected: _recommend == false,
                    onSelected: (selected) =>
                        setState(() => _recommend = selected ? false : null),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(localizations.commentOptional, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            AppTextField(
              controller: _commentController,
              label: localizations.reviewCommentHint,
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: CTAButton(
                text: localizations.submitReview,
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: scheme.primary),
            const SizedBox(width: 8),
            Text(label, style: textTheme.bodyLarge),
            const Spacer(),
            if (value > 0)
              Text(
                value.toStringAsFixed(1),
                style: textTheme.titleMedium?.copyWith(
                  color: scheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
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
          activeColor: scheme.secondary,
        ),
      ],
    );
  }
}
