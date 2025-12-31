import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/constants/app_constants.dart';
import 'package:luqta/core/constants/app_animations.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/router/app_router.dart';
import 'package:luqta/core/widgets/enhanced_photographer_card.dart';
import 'package:luqta/core/widgets/loading_widgets.dart';
import 'package:luqta/core/widgets/empty_states.dart';
import 'package:luqta/core/widgets/app_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luqta/core/models/user_model.dart';
import 'package:luqta/core/models/photographer_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String? _errorMessage;
  final List<SearchResultPhotographer> _results = [];
  final List<String> _recentSearches = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.mediumDuration,
      vsync: this,
    );
    _loadRecentSearches();
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final recentSearchesJson = prefs.getString('recent_searches');
    if (recentSearchesJson != null) {
      final List<dynamic> decoded = json.decode(recentSearchesJson);
      setState(() {
        _recentSearches.clear();
        _recentSearches.addAll(decoded.cast<String>());
      });
    } else {
      // Default demo data if no saved searches
      setState(() {
        _recentSearches.addAll(['Wedding', 'Sara Ali', 'Baghdad']);
      });
    }
  }

  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('recent_searches', json.encode(_recentSearches));
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results.clear();
        _isSearching = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() => _isSearching = true);
    _errorMessage = null;

    try {
      // Search in Firestore
      final queryLower = query.toLowerCase();

      // Query users collection for photographers
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'photographer')
          .get();

      // Query photographers collection for additional data
      final photographerQuery = await FirebaseFirestore.instance
          .collection('photographers')
          .get();

      final Map<String, PhotographerModel> photographerMap = {};
      for (var doc in photographerQuery.docs) {
        photographerMap[doc.id] = PhotographerModel.fromFirestore(doc);
      }

      _results.clear();

      for (var userDoc in userQuery.docs) {
        final user = UserModel.fromFirestore(userDoc);
        final photographer = photographerMap[user.uid];

        if (photographer != null) {
          // Check if query matches name, specialties, or governorates
          final matchesName = user.name.toLowerCase().contains(queryLower);
          final matchesSpecialties = photographer.specialties.any(
            (s) => s.toLowerCase().contains(queryLower),
          );
          final matchesGovernorates =
              photographer.governorates.any(
                (g) => g.toLowerCase().contains(queryLower),
              ) ||
              user.governorate.toLowerCase().contains(queryLower);

          if (matchesName || matchesSpecialties || matchesGovernorates) {
            _results.add(
              SearchResultPhotographer(
                id: user.uid,
                name: user.name,
                image: user.photoUrl ?? '',
                specialties: photographer.specialties,
                rating: photographer.rating,
                reviewCount: photographer.reviewsCount,
                startingPrice: photographer.basePrice,
                governorate: user.governorate,
                username: user.username,
                gender: user.gender,
                age: user.age,
              ),
            );
          }
        }
      }

      // Sort results by rating (highest first)
      _results.sort((a, b) => b.rating.compareTo(a.rating));
      _errorMessage = null;
    } catch (e) {
      debugPrint('Search error: $e');
      _results.clear();
      _errorMessage = e.toString();
    }

    setState(() => _isSearching = false);

    // Save to recent searches
    if (!_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 10) {
          _recentSearches.removeLast();
        }
      });
      await _saveRecentSearches();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _results.clear();
      _isSearching = false;
    });
  }

  void _removeRecentSearch(String query) {
    setState(() {
      _recentSearches.remove(query);
    });
    _saveRecentSearches();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final showResults = _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        toolbarHeight: 72,
        title: AppSearchField(
          controller: _searchController,
          hintText: localizations.searchPhotographers,
          autoFocus: true,
          showBackButton: true,
          debounceDuration: const Duration(milliseconds: 450),
          onChanged: (value) {
            if (value.trim().isEmpty) {
              _clearSearch();
            } else {
              _performSearch(value);
            }
          },
          onSubmitted: _performSearch,
          onClear: _clearSearch,
          onBack: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: showResults
          ? _buildSearchResults()
          : _buildRecentSearches(localizations),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: LoadingIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ErrorState(
            title: AppLocalizations.of(context).error,
            message: _errorMessage,
            onRetry: () => _performSearch(_searchController.text),
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: EmptyState(
            icon: Icons.search_off,
            title: AppLocalizations.of(context).noResults,
            message: AppLocalizations.of(context).noData,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final photographer = _results[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: AppAnimations.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: EnhancedPhotographerCard(
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
              onTap: () {
                AppRouter.goToPhotographerProfile(context, photographer.id);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentSearches(AppLocalizations localizations) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick Filters
        Text(localizations.popularSpecialties, style: AppTypography.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.specialtiesAr.take(6).map((specialty) {
            return ActionChip(
              label: Text(specialty),
              onPressed: () {
                _searchController.text = specialty;
                _performSearch(specialty);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Recent Searches
        if (_recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(localizations.recentSearches, style: AppTypography.h3),
              TextButton(
                onPressed: () {
                  setState(() => _recentSearches.clear());
                  _saveRecentSearches();
                },
                child: Text(localizations.clearAll),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(_recentSearches.length, (index) {
            final query = _recentSearches[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.history,
                color: AppColors.textSecondary,
              ),
              title: Text(query),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => _removeRecentSearch(query),
              ),
              onTap: () {
                _searchController.text = query;
                _performSearch(query);
              },
            );
          }),
        ],
      ],
    );
  }
}

class SearchResultPhotographer {
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

  SearchResultPhotographer({
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
