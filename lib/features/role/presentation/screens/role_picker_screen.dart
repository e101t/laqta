import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/constants/app_constants.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/router/app_router.dart';
import 'package:luqta/core/utils/responsive.dart';
import 'package:luqta/core/widgets/app_buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luqta/core/models/user_model.dart';

class RolePickerScreen extends StatefulWidget {
  const RolePickerScreen({super.key});

  @override
  State<RolePickerScreen> createState() => _RolePickerScreenState();
}

class _RolePickerScreenState extends State<RolePickerScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  Future<void> _continue() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a role')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final userDoc = await _persistRoleWithRetry(user);
      final userModel = UserModel.fromFirestore(userDoc);

      setState(() => _isLoading = false);

      // Navigate to profile setup or home based on profile completion
      if (!mounted) return;
      if (userModel.profileCompleted) {
        AppRouter.goToHome(context);
      } else {
        AppRouter.goToBasicInfo(context, _selectedRole!);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save role: $e')));
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _persistRoleWithRetry(
    User user,
  ) async {
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    var delay = const Duration(milliseconds: 400);
    const maxAttempts = 3;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final existingDoc = await userDocRef.get();
        final timestamp = FieldValue.serverTimestamp();

        if (existingDoc.exists) {
          await userDocRef.update({
            'role': _selectedRole,
            'updatedAt': timestamp,
          });
        } else {
          await userDocRef.set({
            'uid': user.uid,
            'name': user.displayName ?? '',
            'email': user.email,
            'phone': user.phoneNumber,
            'photoUrl': user.photoURL,
            'role': _selectedRole,
            'username': null,
            'usernameLower': null,
            'gender': null,
            'birthYear': null,
            'age': null,
            'governorate': '',
            'lang': AppConstants.defaultLanguage,
            'profileCompleted': false,
            'over18Confirmed': false,
            'blockedUsers': <String>[],
            'interests': <String>[],
            'createdAt': timestamp,
            'updatedAt': timestamp,
          });
        }

        return await userDocRef.get();
      } on FirebaseException catch (e) {
        final shouldRetry =
            e.code == 'unavailable' && attempt < maxAttempts - 1;
        if (shouldRetry) {
          await Future.delayed(delay);
          delay *= 2;
          continue;
        }
        rethrow;
      }
    }

    throw FirebaseException(
      plugin: 'cloud_firestore',
      message: 'Unable to save role after multiple attempts',
    );
  }

  Widget _buildRoleHero(
    AppLocalizations localizations, {
    bool compact = false,
  }) {
    final height = compact ? 220.0 : 360.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/hero_role.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.06),
                      AppColors.cta.withValues(alpha: 0.2),
                      AppColors.background.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.chooseRole,
                    style: AppTypography.h2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.authSubtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = Responsive.isWideLayout(context);
            final content = isWide
                ? Row(
                    children: [
                      Expanded(child: _buildRoleHero(localizations)),
                      const SizedBox(width: 32),
                      Expanded(child: _buildRoleContent(localizations)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildRoleHero(localizations, compact: true),
                      const SizedBox(height: 24),
                      _buildRoleContent(localizations),
                    ],
                  );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: SizedBox(
                    width: isWide ? 960 : double.infinity,
                    child: content,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoleContent(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          localizations.chooseRole,
          style: AppTypography.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 24),
        _RoleCard(
          icon: Icons.person,
          title: localizations.customer,
          description: localizations.iAmCustomer,
          isSelected: _selectedRole == AppConstants.roleCustomer,
          onTap: () {
            setState(() {
              _selectedRole = AppConstants.roleCustomer;
            });
          },
        ),
        const SizedBox(height: 20),
        _RoleCard(
          icon: Icons.camera_alt,
          title: localizations.photographer,
          description: localizations.iAmPhotographer,
          isSelected: _selectedRole == AppConstants.rolePhotographer,
          onTap: () {
            setState(() {
              _selectedRole = AppConstants.rolePhotographer;
            });
          },
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          text: localizations.next,
          onPressed: _selectedRole != null ? _continue : null,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.h3.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
