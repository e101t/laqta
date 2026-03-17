import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/widgets/app_buttons.dart';
import 'package:laqta/core/widgets/app_text_field.dart';
import 'package:laqta/features/deliveries/deliveries_dependencies.dart';
import 'package:laqta/features/deliveries/domain/entities/delivery.dart';

class DeliveryUploadScreen extends StatefulWidget {
  final String bookingId;
  final String photographerId;
  final String customerId;
  final Delivery? existingDelivery;

  const DeliveryUploadScreen({
    super.key,
    required this.bookingId,
    required this.photographerId,
    required this.customerId,
    this.existingDelivery,
  });

  @override
  State<DeliveryUploadScreen> createState() => _DeliveryUploadScreenState();
}

class _DeliveryUploadScreenState extends State<DeliveryUploadScreen> {
  final TextEditingController _noteController = TextEditingController();
  final List<String> _photoUrls = [];
  final List<String> _videoUrls = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingDelivery != null) {
      _photoUrls.addAll(widget.existingDelivery!.photoUrls);
      _videoUrls.addAll(widget.existingDelivery!.videoUrls);
      _noteController.text = widget.existingDelivery!.note ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files.isEmpty) return;

    setState(() => _isUploading = true);
    try {
      for (final file in files) {
        final result = await DeliveriesDependencies.uploadDeliveryFile().call(
          bookingId: widget.bookingId,
          deliveryId: widget.bookingId,
          filePath: file.path,
        );
        if (result.isSuccess && result.valueOrNull != null) {
          _photoUrls.add(result.valueOrNull!);
        }
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final file = await picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => _isUploading = true);
    try {
      final result = await DeliveriesDependencies.uploadDeliveryFile().call(
        bookingId: widget.bookingId,
        deliveryId: widget.bookingId,
        filePath: file.path,
      );
      if (result.isSuccess && result.valueOrNull != null) {
        _videoUrls.add(result.valueOrNull!);
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _submitDelivery() async {
    final localizations = AppLocalizations.of(context);
    if (_photoUrls.isEmpty && _videoUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.deliveryFilesRequired)),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      final now = DateTime.now();
      final delivery = Delivery(
        id: widget.bookingId,
        bookingId: widget.bookingId,
        photographerId: widget.photographerId,
        customerId: widget.customerId,
        status: 'submitted',
        photoUrls: List<String>.from(_photoUrls),
        videoUrls: List<String>.from(_videoUrls),
        otherUrls: const [],
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        revisionNote: widget.existingDelivery?.revisionNote,
        revisionCount: widget.existingDelivery?.revisionCount ?? 0,
        createdAt: widget.existingDelivery?.createdAt ?? now,
        updatedAt: now,
      );

      final result =
          await DeliveriesDependencies.upsertDelivery().call(delivery);
      if (!result.isSuccess) {
        throw StateError('Delivery upload failed');
      }

      if (mounted) {
        Navigator.pop(context, delivery);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.deliverySubmitFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.uploadDelivery)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.filesLabel,
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isUploading ? null : _pickImages,
                    icon: const Icon(Icons.photo_library),
                    label: Text(localizations.addPhotos),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isUploading ? null : _pickVideo,
                    icon: const Icon(Icons.video_camera_back),
                    label: Text(localizations.addVideo),
                  ),
                ),
              ],
            ),
            if (_photoUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('${localizations.photos} (${_photoUrls.length})'),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _photoUrls[index],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemCount: _photoUrls.length,
                ),
              ),
            ],
            if (_videoUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('${localizations.videos} (${_videoUrls.length})'),
              const SizedBox(height: 8),
              Column(
                children: _videoUrls
                    .map(
                      (url) => ListTile(
                        leading: const Icon(Icons.video_file),
                        title: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            AppTextField(
              controller: _noteController,
              label: localizations.notesOptional,
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: CTAButton(
                text: localizations.submitDelivery,
                isLoading: _isUploading,
                onPressed: _isUploading ? null : _submitDelivery,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
