import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:luqta/core/constants/app_constants.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/widgets/app_buttons.dart';
import 'package:luqta/core/widgets/app_text_field.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/profile/profile_dependencies.dart';
import 'package:luqta/features/reels/domain/entities/reel_model.dart';
import 'package:luqta/features/reels/reels_dependencies.dart';

class CreatePostScreen extends StatefulWidget {
  final Future<XFile?> Function(ImageSource source)? imagePicker;

  const CreatePostScreen({super.key, this.imagePicker});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  XFile? _selectedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked =
        widget.imagePicker != null
            ? await widget.imagePicker!(source)
            : await picker.pickImage(source: source);
    if (!mounted) return;
    if (picked != null) {
      setState(() => _selectedImage = picked);
    }
  }

  Future<void> _submitPost() async {
    final localizations = AppLocalizations.of(context);
    if (_selectedImage == null) {
      _showSnackBar(localizations.mediaRequired);
      return;
    }

    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final authResult = await AuthDependencies.getCurrentUser().call();
      final userId = authResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) {
        _showSnackBar(localizations.error);
        return;
      }

      final profileResult = await ProfileDependencies.getUserProfile().call(
        userId: userId,
      );
      final profile = profileResult.valueOrNull;
      if (profile == null) {
        _showSnackBar(localizations.error);
        return;
      }
      if (profile.role != AppConstants.rolePhotographer) {
        _showSnackBar(localizations.notPhotographer);
        return;
      }

      final reelId = const Uuid().v4();
      final contentType = _selectedImage?.mimeType ?? 'image/jpeg';
      final uploadResult = await ReelsDependencies.uploadReelMedia().call(
        photographerId: userId,
        reelId: reelId,
        filePath: _selectedImage!.path,
        contentType: contentType,
      );
      if (!uploadResult.isSuccess || uploadResult.valueOrNull == null) {
        _showSnackBar(localizations.error);
        return;
      }

      final caption = _captionController.text.trim();
      final now = DateTime.now();
      final reel = ReelModel(
        reelId: reelId,
        photographerId: userId,
        photographerName: profile.name,
        photographerPhotoUrl: profile.photoUrl,
        videoUrl: '',
        thumbnailUrl: uploadResult.valueOrNull,
        caption: caption,
        tags: const [],
        views: 0,
        likes: 0,
        comments: 0,
        shares: 0,
        createdAt: now,
        isVerified: false,
      );

      final createResult = await ReelsDependencies.createReel().call(
        reel: reel,
      );
      if (!createResult.isSuccess) {
        _showSnackBar(localizations.error);
        return;
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showPickerSheet() {
    final localizations = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(localizations.camera),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(localizations.gallery),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.createPost)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.addPhoto, style: textTheme.titleMedium),
            const SizedBox(height: 12),
            GestureDetector(
              key: const Key('create_post_add_photo_picker'),
              onTap: _showPickerSheet,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 36,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localizations.addPhoto,
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _captionController,
              label: localizations.captionOptional,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            CTAButton(
              text: localizations.sharePost,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _submitPost,
            ),
          ],
        ),
      ),
    );
  }
}
