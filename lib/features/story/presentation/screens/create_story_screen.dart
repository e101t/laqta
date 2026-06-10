import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/models/story_model.dart';
import 'package:laqta/core/services/backend_media_service.dart';
import 'package:laqta/core/widgets/app_buttons.dart';
import 'package:laqta/core/widgets/app_text_field.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/profile/profile_dependencies.dart';
import 'package:laqta/features/story/story_dependencies.dart';

class CreateStoryScreen extends StatefulWidget {
  final Future<XFile?> Function(ImageSource source)? imagePicker;

  const CreateStoryScreen({super.key, this.imagePicker});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
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
    final picked = widget.imagePicker != null
        ? await widget.imagePicker!(source)
        : await picker.pickImage(source: source);
    if (!mounted) return;
    if (picked != null) {
      setState(() => _selectedImage = picked);
    }
  }

  Future<void> _submitStory() async {
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

      final storyId = const Uuid().v4();
      final contentType = _selectedImage?.mimeType ?? 'image/jpeg';
      final uploadResult = await StoryDependencies.uploadStoryImage().call(
        photographerId: userId,
        storyId: storyId,
        filePath: _selectedImage!.path,
        contentType: contentType,
      );
      if (!uploadResult.isSuccess || uploadResult.valueOrNull == null) {
        _showSnackBar(localizations.error);
        return;
      }
      final stableUrl = uploadResult.valueOrNull!;
      final mediaId = BackendMediaService.requireMediaId(stableUrl);

      final now = DateTime.now();
      final caption = _captionController.text.trim();
      final story = StoryModel(
        storyId: storyId,
        photographerId: userId,
        photographerName: profile.name,
        photographerPhotoUrl: profile.photoUrl,
        mediaId: mediaId,
        imageUrl: stableUrl,
        caption: caption.isEmpty ? null : caption,
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 24)),
        views: const [],
        isActive: true,
      );

      final createResult = await StoryDependencies.createStory().call(
        story: story,
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
      appBar: AppBar(title: Text(localizations.createStory)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.addPhoto, style: textTheme.titleMedium),
            const SizedBox(height: 12),
            GestureDetector(
              key: const Key('create_story_add_photo_picker'),
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
                            Icons.add_a_photo,
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
              text: localizations.shareStory,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _submitStory,
            ),
          ],
        ),
      ),
    );
  }
}
