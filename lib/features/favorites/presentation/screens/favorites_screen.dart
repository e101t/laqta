import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/widgets/loading_widgets.dart';
import 'package:luqta/core/widgets/empty_states.dart';
import 'package:luqta/core/widgets/app_cards.dart';
import 'package:luqta/core/widgets/app_text_field.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/favorites/domain/entities/favorite_photographer.dart';
import 'package:luqta/features/favorites/favorites_dependencies.dart';

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
    final userResult = await AuthDependencies.getCurrentUser().call();
    final userId = userResult.valueOrNull?.id;
    if (userId == null || userId.isEmpty) {
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
      final result = await FavoritesDependencies.getFavorites().call(
        userId: userId,
      );
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ?? 'Failed to load favorites',
        );
      }

      _favorites
        ..clear()
        ..addAll(result.valueOrNull ?? []);

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load favorites: $e';
      });
    }
  }

  Future<void> _removeFavorite(String photographerId) async {
    final userResult = await AuthDependencies.getCurrentUser().call();
    if (!mounted) return;
    final userId = userResult.valueOrNull?.id;
    if (userId == null || userId.isEmpty) {
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
      final result = await FavoritesDependencies.removeFavorite().call(
        userId: userId,
        photographerId: photographerId,
      );
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ?? 'Failed to remove from favorites',
        );
      }

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
