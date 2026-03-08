import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luqta/core/models/portfolio_model.dart';
import 'package:luqta/core/widgets/app_buttons.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/profile/profile_dependencies.dart';
import 'package:luqta/features/profile/presentation/mappers/profile_presentation_mapper.dart';

class PortfolioEditorScreen extends StatefulWidget {
  const PortfolioEditorScreen({super.key});

  @override
  State<PortfolioEditorScreen> createState() => _PortfolioEditorScreenState();
}

class _PortfolioEditorScreenState extends State<PortfolioEditorScreen> {
  List<PortfolioImage> _portfolioImages = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    final userResult = await AuthDependencies.getCurrentUser().call();
    final userId = userResult.valueOrNull?.id;
    if (userId == null || userId.isEmpty) return;

    try {
      final result = await ProfileDependencies.getPortfolio().call(
        photographerId: userId,
      );
      if (!result.isSuccess) {
        throw StateError(result.failureOrNull?.message ?? 'Load failed');
      }
      final portfolio = result.valueOrNull;
      setState(() {
        _portfolioImages = portfolio == null
            ? []
            : ProfilePresentationMapper.toPortfolioImages(portfolio.images);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load portfolio')),
        );
      }
    }
  }

  Future<void> _addImage() async {
    if (_portfolioImages.length >= 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 20 images allowed')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      setState(() => _isUploading = true);

      try {
        final userResult = await AuthDependencies.getCurrentUser().call();
        final userId = userResult.valueOrNull?.id;
        if (userId == null || userId.isEmpty) return;

        final result = await ProfileDependencies.uploadPortfolioImage().call(
          photographerId: userId,
          filePath: pickedFile.path,
        );
        if (!result.isSuccess || result.valueOrNull == null) {
          throw StateError('Upload failed');
        }
        final downloadUrl = result.valueOrNull!;

        final newImage = PortfolioImage(
          url: downloadUrl,
          createdAt: DateTime.now(),
        );
        setState(() {
          _portfolioImages.add(newImage);
        });

        await _savePortfolio();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Failed to add image')));
        }
      } finally {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _removeImage(int index) async {
    final imageToRemove = _portfolioImages[index];

    // Delete from storage
    try {
      await ProfileDependencies.deleteStorageFile().call(imageToRemove.url);
    } catch (e) {
      // Continue even if storage deletion fails
    }

    setState(() {
      _portfolioImages.removeAt(index);
    });

    await _savePortfolio();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image removed successfully')),
      );
    }
  }

  Future<void> _savePortfolio() async {
    final userResult = await AuthDependencies.getCurrentUser().call();
    final userId = userResult.valueOrNull?.id;
    if (userId == null || userId.isEmpty) return;

    try {
      final result = await ProfileDependencies.savePortfolio().call(
        photographerId: userId,
        images: ProfilePresentationMapper.toDomainImages(_portfolioImages),
      );
      if (!result.isSuccess) {
        throw StateError(result.failureOrNull?.message ?? 'Save failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save portfolio')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Portfolio'),
        actions: [
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.add_photo_alternate),
              onPressed: _addImage,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _portfolioImages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library,
                    size: 64,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text('No portfolio images yet', style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Add up to 20 images to showcase your work',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Add First Image',
                    icon: Icons.add,
                    onPressed: _addImage,
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: _portfolioImages.length,
              itemBuilder: (context, index) {
                final image = _portfolioImages[index];
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(image.url),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => _showDeleteDialog(index),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Image'),
        content: const Text(
          'Are you sure you want to remove this image from your portfolio?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeImage(index);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
