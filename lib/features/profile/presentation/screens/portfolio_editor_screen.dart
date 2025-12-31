import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/models/portfolio_model.dart';
import 'package:luqta/core/widgets/app_buttons.dart';

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final portfolioQuery = await FirebaseFirestore.instance
          .collection('portfolios')
          .where('photographerId', isEqualTo: user.uid)
          .get();

      if (portfolioQuery.docs.isNotEmpty) {
        final portfolio = PortfolioModel.fromFirestore(
          portfolioQuery.docs.first,
        );
        setState(() {
          _portfolioImages = portfolio.images;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load portfolio: $e')));
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
        final file = File(pickedFile.path);
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('photographers')
            .child(user.uid)
            .child('portfolio')
            .child(fileName);

        await storageRef.putFile(
          file,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final downloadUrl = await storageRef.getDownloadURL();

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
          ).showSnackBar(SnackBar(content: Text('Failed to add image: $e')));
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
      final storageRef = FirebaseStorage.instance.refFromURL(imageToRemove.url);
      await storageRef.delete();
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final portfolioData = {
        'photographerId': user.uid,
        'images': _portfolioImages.map((img) => img.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final portfolioQuery = await FirebaseFirestore.instance
          .collection('portfolios')
          .where('photographerId', isEqualTo: user.uid)
          .get();

      if (portfolioQuery.docs.isNotEmpty) {
        // Update existing
        await portfolioQuery.docs.first.reference.update(portfolioData);
      } else {
        // Create new
        await FirebaseFirestore.instance
            .collection('portfolios')
            .add(portfolioData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save portfolio: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                  const Icon(
                    Icons.photo_library,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text('No portfolio images yet', style: AppTypography.h3),
                  const SizedBox(height: 8),
                  Text(
                    'Add up to 20 images to showcase your work',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
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
