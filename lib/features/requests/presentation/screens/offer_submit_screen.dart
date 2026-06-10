import 'package:flutter/material.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/widgets/app_buttons.dart';
import 'package:laqta/core/widgets/app_text_field.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/notifications/domain/entities/notification_model.dart';
import 'package:laqta/features/notifications/notifications_dependencies.dart';
import 'package:laqta/features/requests/domain/entities/request_deliverables.dart';
import 'package:laqta/features/requests/domain/entities/request_offer.dart';
import 'package:laqta/features/requests/requests_dependencies.dart';

class OfferSubmitScreen extends StatefulWidget {
  final String requestId;
  final Future<void> Function()? onOfferSubmitted;

  const OfferSubmitScreen({
    super.key,
    required this.requestId,
    this.onOfferSubmitted,
  });

  @override
  State<OfferSubmitScreen> createState() => _OfferSubmitScreenState();
}

class _OfferSubmitScreenState extends State<OfferSubmitScreen> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _deliveryDaysController = TextEditingController();
  final TextEditingController _photosCountController = TextEditingController();
  final TextEditingController _videoMinutesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _includesEditing = false;
  bool _includesVideo = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    _deliveryDaysController.dispose();
    _photosCountController.dispose();
    _videoMinutesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitOffer() async {
    if (_isSubmitting) return;
    final localizations = AppLocalizations.of(context);

    final price = double.tryParse(_priceController.text.trim());
    final deliveryDays = int.tryParse(_deliveryDaysController.text.trim());

    if (price == null || deliveryDays == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.offerRequiredFields)),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userResult = await AuthDependencies.getCurrentUser().call();
      final userId = userResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) {
        throw StateError('Missing user');
      }

      final photosCount = int.tryParse(_photosCountController.text.trim());
      final videoMinutes = int.tryParse(_videoMinutesController.text.trim());

      final offer = RequestOffer(
        id: RequestsDependencies.generateOfferId().call(),
        requestId: widget.requestId,
        photographerId: userId,
        price: price,
        currency: AppConstants.currencyIQD,
        deliveryDays: deliveryDays,
        deliverables: RequestDeliverables(
          photosCount: photosCount,
          videoMinutes: videoMinutes,
          includesEditing: _includesEditing,
          includesVideo: _includesVideo,
        ),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        status: 'submitted',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await RequestsDependencies.createOffer().call(offer);
      if (!result.isSuccess) {
        throw StateError('Failed to send offer');
      }
      await _notifyClient(offer);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizations.offerSent)));
        if (widget.onOfferSubmitted != null) {
          await widget.onOfferSubmitted!();
        } else if (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizations.offerFailed)));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _notifyClient(RequestOffer offer) async {
    try {
      final requestResult = await RequestsDependencies.getRequestById().call(
        offer.requestId,
      );
      final clientId = requestResult.valueOrNull?.clientId;
      if (clientId == null || clientId.isEmpty) return;

      final notification = NotificationModel(
        notificationId: '',
        userId: clientId,
        title: 'New offer received',
        body: 'A photographer sent an offer for your request.',
        type: 'offer',
        data: {'requestId': offer.requestId, 'offerId': offer.id},
        createdAt: DateTime.now(),
      );
      await NotificationsDependencies.createNotification().call(notification);
    } catch (_) {
      // Notifications are best-effort.
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.sendOffer)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _priceController,
              label: localizations.priceLabel,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _deliveryDaysController,
              label: localizations.deliveryDays,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Text(localizations.deliverables, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _photosCountController,
                    label: localizations.photosCount,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _videoMinutesController,
                    label: localizations.videoMinutes,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _includesVideo,
              onChanged: (value) => setState(() => _includesVideo = value),
              title: Text(localizations.includeVideo),
            ),
            SwitchListTile(
              value: _includesEditing,
              onChanged: (value) => setState(() => _includesEditing = value),
              title: Text(localizations.includeEditing),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _notesController,
              label: localizations.notesOptional,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: CTAButton(
                text: localizations.sendOffer,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _submitOffer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
