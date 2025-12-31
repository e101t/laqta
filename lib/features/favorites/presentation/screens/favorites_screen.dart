import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/widgets/loading_widgets.dart';
import 'package:luqta/core/widgets/empty_states.dart';
import 'package:luqta/core/widgets/app_cards.dart';
import 'package:luqta/core/widgets/app_text_field.dart';
import 'package:luqta/core/models/user_model.dart';
import 'package:luqta/core/models/photographer_model.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  final List<FavoritePhotographer> _favorites = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FavoritePhotographer> get _filteredFavorites {
    if (_searchQuery.trim().isEmpty) return _favorites;
    final query = _searchQuery.toLowerCase();
    return _favorites
        .where(
          (photographer) =>
              photographer.name.toLowerCase().contains(query) ||
              photographer.specialties.any(
                (spec) => spec.toLowerCase().contains(query),
              ) ||
              photographer.governorate.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> _loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please log in to view favorites';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch favorites for the current user
      final favoritesQuery = await FirebaseFirestore.instance
          .collection('favorites')
          .where('userId', isEqualTo: user.uid)
          .get();

      final photographerIds = favoritesQuery.docs
          .map((doc) => doc.data()['photographerId'] as String)
          .toList();

      if (photographerIds.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // Fetch user data for each photographer
      final userDocs = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: photographerIds)
          .get();

      // Fetch photographer data for each photographer
      final photographerDocs = await FirebaseFirestore.instance
          .collection('photographers')
          .where(FieldPath.documentId, whereIn: photographerIds)
          .get();

      // Create a map for quick lookup
      final userMap = {
        for (var doc in userDocs.docs) doc.id: UserModel.fromFirestore(doc),
      };
      final photographerMap = {
        for (var doc in photographerDocs.docs)
          doc.id: PhotographerModel.fromFirestore(doc),
      };

      _favorites.clear();
      for (final photographerId in photographerIds) {
        final userData = userMap[photographerId];
        final photographerData = photographerMap[photographerId];

        if (userData != null && photographerData != null) {
          _favorites.add(
            FavoritePhotographer(
              id: photographerId,
              name: userData.name,
              image: userData.photoUrl ?? '',
              specialties: photographerData.specialties,
              rating: photographerData.rate,
              reviewCount: photographerData.reviewsCount,
              startingPrice: photographerData.basePrice,
              governorate: userData.governorate,
              username: userData.username,
              gender: userData.gender,
              age: userData.age,
            ),
          );
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load favorites: $e';
      });
    }
  }

  Future<void> _removeFavorite(String photographerId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to manage favorites')),
      );
      return;
    }

    // Optimistically remove from UI
    final removedPhotographer = _favorites.firstWhere(
      (p) => p.id == photographerId,
    );
    setState(() {
      _favorites.removeWhere((p) => p.id == photographerId);
    });

    try {
      await FirebaseFirestore.instance
          .collection('favorites')
          .doc('${user.uid}_$photographerId')
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Revert the change on error
      if (mounted) {
        setState(() {
          _favorites.add(removedPhotographer);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove from favorites')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(localizations.favorites)),
      body: _isLoading
          ? const LoadingIndicator()
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadFavorites,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _favorites.isEmpty
          ? Center(
              child: EmptyState(
                icon: Icons.favorite_border,
                title: 'No Favorites',
                message:
                    'You haven\'t added any photographers to your favorites yet',
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: AppSearchField(
                    controller: _searchController,
                    hintText: localizations.searchPhotographers,
                    debounceDuration: const Duration(milliseconds: 250),
                    enableSuggestions: false,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    onClear: () {
                      setState(() => _searchQuery = '');
                    },
                  ),
                ),
                Expanded(child: _buildFavoritesList(_filteredFavorites)),
              ],
            ),
    );
  }

  Widget _buildFavoritesList(List<FavoritePhotographer> list) {
    if (list.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.search_off,
          title: 'No results',
          message: 'Try searching by name, specialty, or governorate',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final photographer = list[index];
          return Dismissible(
            key: Key(photographer.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              _removeFavorite(photographer.id);
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PhotographerCard(
                photographerId: photographer.id,
                name: photographer.name,
                photoUrl: photographer.image.isNotEmpty
                    ? photographer.image
                    : null,
                specialties: photographer.specialties,
                rating: photographer.rating,
                reviewsCount: photographer.reviewCount,
                basePrice: photographer.startingPrice,
                governorate: photographer.governorate,
                username: photographer.username,
                gender: photographer.gender,
                age: photographer.age,
                isFavorite: true,
                onFavorite: () {
                  _removeFavorite(photographer.id);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class FavoritePhotographer {
  final String id;
  final String name;
  final String image;
  final List<String> specialties;
  final double rating;
  final int reviewCount;
  final double startingPrice;
  final String governorate;
  final String? username;
  final String? gender;
  final int? age;

  FavoritePhotographer({
    required this.id,
    required this.name,
    required this.image,
    required this.specialties,
    required this.rating,
    required this.reviewCount,
    required this.startingPrice,
    required this.governorate,
    this.username,
    this.gender,
    this.age,
  });
}
