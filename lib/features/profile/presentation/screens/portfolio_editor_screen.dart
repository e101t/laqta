import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laqta/core/media/image_picker_service.dart';
import 'package:laqta/core/models/portfolio_model.dart';
import 'package:laqta/core/widgets/app_buttons.dart';
import 'package:laqta/core/widgets/laqta_async_widgets.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/profile/profile_dependencies.dart';
import 'package:laqta/features/profile/presentation/mappers/profile_presentation_mapper.dart';

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
      if (!mounted) return;
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
          const SnackBar(content: Text('تعذر تحميل معرض الأعمال')),
        );
      }
    }
  }

  Future<void> _addImage() async {
    if (_portfolioImages.length >= 20) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الحد الأقصى 20 صورة')));
      return;
    }

    final pickedFile = await ImagePickerService().pickImageToTemp(
      source: ImageSource.gallery,
    );

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
          throw StateError(
            _portfolioUploadErrorMessage(result.failureOrNull?.message),
          );
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
            const SnackBar(content: Text('تمت إضافة الصورة بنجاح')),
          );
        }
      } catch (e) {
        if (mounted) {
          final message = e is StateError
              ? e.message.toString()
              : 'تعذر إضافة الصورة';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
        }
      }
    }
  }

  String _portfolioUploadErrorMessage(String? rawMessage) {
    final normalized = rawMessage?.toLowerCase().trim() ?? '';
    if (normalized.contains('active subscription')) {
      return 'يتطلب رفع المزيد من أعمالك اشتراكًا نشطًا.';
    }
    if (normalized.contains('only photographers')) {
      return 'رفع معرض الأعمال متاح لحسابات المصورين فقط.';
    }
    if (normalized.contains('limit')) {
      return 'وصلت إلى حد معرض الأعمال في خطتك الحالية.';
    }
    return 'تعذر إضافة الصورة';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حذف الصورة بنجاح')));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تعذر حفظ معرض الأعمال')));
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
        title: const Text('معرض الأعمال'),
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
                  Text(
                    'لا توجد صور في معرض الأعمال',
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أضف صورًا تعرض جودة أعمالك للعملاء',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'إضافة أول صورة',
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
                    Positioned.fill(
                      child: LaqtaRemoteImage(
                        imageUrl: image.url,
                        borderRadius: BorderRadius.circular(12),
                        fit: BoxFit.cover,
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
        title: const Text('حذف الصورة'),
        content: const Text('هل تريد حذف هذه الصورة من معرض أعمالك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeImage(index);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
